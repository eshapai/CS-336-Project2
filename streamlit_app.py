import re
import sys
from io import StringIO

import pandas as pd
import streamlit as st

try:
    import pexpect
except ImportError:
    pexpect = None


BACKEND_FILE = "local_app.py"


def extract_sql(text: str) -> str:
    patterns = [
        r"Generated SQL:\s*(SELECT[\s\S]*?;)",
        r"```sql\s*(SELECT[\s\S]*?)```",
        r"(SELECT[\s\S]*?;)",
    ]

    for pattern in patterns:
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            return match.group(1).strip()

    return ""


def extract_result(text: str) -> str:
    match = re.search(
        r"Result:\s*([\s\S]*?)(?:\r?\nQuestion:\s*$|\Z)",
        text,
        re.IGNORECASE,
    )

    if match:
        return match.group(1).strip()

    return text.strip()


def clean_dataframe(df: pd.DataFrame):
    """
    Cleans table parsing results so the UI looks nicer.
    """
    if df is None or df.empty:
        return None

    df = df.dropna(axis=0, how="all")
    df = df.dropna(axis=1, how="all")

    df.columns = [str(col).strip() for col in df.columns]

    for col in list(df.columns):
        if col.lower().startswith("unnamed") or col == "":
            df = df.drop(columns=[col])

    if df.empty:
        return None

    # Convert numeric-looking columns so sorting works correctly.
    for col in df.columns:
        cleaned_values = df[col].astype(str).str.replace(",", "", regex=False).str.strip()
        numeric_values = pd.to_numeric(cleaned_values, errors="coerce")

        if numeric_values.notna().sum() == cleaned_values.ne("").sum():
            df[col] = numeric_values

    return df


def try_parse_pipe_table(result_text: str):
    """
    Parses output that looks like:
    column1 | column2
    --------+--------
    value1  | value2
    """
    lines = [line.rstrip() for line in result_text.splitlines() if line.strip()]

    pipe_lines = [
        line for line in lines
        if "|" in line and not set(line.replace("|", "").strip()) <= {"-", "+"}
    ]

    if len(pipe_lines) < 2:
        return None

    cleaned = "\n".join(pipe_lines)

    try:
        df = pd.read_csv(StringIO(cleaned), sep=r"\s*\|\s*", engine="python")
        return clean_dataframe(df)
    except Exception:
        return None


def try_parse_csv_or_tsv(result_text: str):
    """
    Parses comma-separated or tab-separated result output.
    """
    text = result_text.strip()

    if not text:
        return None

    for separator in [",", "\t"]:
        if separator not in text:
            continue

        try:
            df = pd.read_csv(StringIO(text), sep=separator)
            if len(df.columns) > 1 or len(df) > 1:
                return clean_dataframe(df)
        except Exception:
            pass

    return None


def try_parse_space_aligned_table(result_text: str):
    """
    Parses simple terminal tables where columns are separated by spaces.

    This fixes cases where pandas/Streamlit reads the whole row as one column,
    such as:
    loan_type_name application_count
    Conventional 250133
    FHA-insured 81517
    """
    lines = [line.rstrip() for line in result_text.splitlines() if line.strip()]

    # Remove separator lines like ----- or =====.
    lines = [
        line for line in lines
        if not re.fullmatch(r"[\-\=\+\s]+", line.strip())
    ]

    if len(lines) < 2:
        return None

    header_line = lines[0].strip()
    headers = re.findall(r"\S+", header_line)

    if len(headers) < 2:
        return None

    rows = []

    for line in lines[1:]:
        row_line = line.strip()

        # First try splitting on two or more spaces. This preserves values
        # that contain single spaces.
        parts = re.split(r"\s{2,}", row_line)

        # If that did not work, split from the right. This helps with common
        # grouped query output like: "Conventional 250133".
        if len(parts) != len(headers):
            parts = row_line.rsplit(None, len(headers) - 1)

        # If a pandas index appears in the first column, remove it.
        if len(parts) == len(headers) + 1 and parts[0].isdigit():
            parts = parts[1:]

        if len(parts) == len(headers):
            rows.append(parts)

    if not rows:
        return None

    df = pd.DataFrame(rows, columns=headers)
    return clean_dataframe(df)




def try_parse_fixed_width_table(result_text: str):
    """
    Parses pandas-style printed tables.
    """
    lines = [line.rstrip() for line in result_text.splitlines() if line.strip()]

    if len(lines) < 2:
        return None

    text = "\n".join(lines)

    try:
        df = pd.read_fwf(StringIO(text))

        first_col = df.columns[0]
        first_values = df[first_col].astype(str).str.strip()

        if first_values.str.fullmatch(r"\d+").all():
            df = df.drop(columns=[first_col])

        return clean_dataframe(df)
    except Exception:
        return None


def try_parse_single_value(result_text: str):
    """
    Handles simple one-value output so it can still appear in a small table.
    """
    lines = [line.strip() for line in result_text.splitlines() if line.strip()]

    if not lines:
        return None

    if len(lines) == 2:
        header = lines[0]
        value = lines[1]

        if not any(char in header for char in "|,\t"):
            return pd.DataFrame([{header: value}])

    if len(lines) == 1:
        line = lines[0]

        if len(line.split()) == 1:
            return pd.DataFrame([{"Result": line}])

    return None


def try_make_table(result_text: str):
    """
    Tries several formats. If none work, the frontend keeps plain text output.
    """
    if not result_text or not result_text.strip():
        return None

    parsers = [
        try_parse_pipe_table,
        try_parse_csv_or_tsv,
        try_parse_space_aligned_table,
        try_parse_fixed_width_table,
        try_parse_single_value,
    ]

    for parser in parsers:
        df = parser(result_text)

        if df is not None and not df.empty:
            return df

    return None


def backend_is_running() -> bool:
    child = st.session_state.get("backend_process")

    if child is None:
        return False

    return child.isalive()


def start_backend(username: str, password: str):
    if pexpect is None:
        raise RuntimeError(
            "The pexpect package is missing. Install it with: pip install pexpect"
        )

    child = pexpect.spawn(
        sys.executable,
        [BACKEND_FILE],
        encoding="utf-8",
        timeout=600,
    )

    child.expect("ILAB username:")
    child.sendline(username)

    child.expect("ILAB password:")
    child.sendline(password)

    child.expect("Question:")

    st.session_state.backend_process = child
    st.session_state.connected = True


def reset_backend_after_crash():
    child = st.session_state.get("backend_process")

    if child is not None:
        try:
            child.close(force=True)
        except Exception:
            pass

    st.session_state.backend_process = None
    st.session_state.connected = False


def format_backend_crash_message(backend_output: str) -> str:
    """
    Turns common backend crashes into cleaner frontend messages.
    """
    backend_output = backend_output.strip()

    if "AuthenticationException" in backend_output or "Authentication failed" in backend_output:
        return (
            "iLab authentication failed. Check that your iLab username and password are correct, "
            "then click Connect and try again.\n\n"
            "Use your NetID username, not your full email address.\n\n"
            "Backend output:\n"
            f"{backend_output}"
        )

    return (
        "The backend stopped before it returned another Question prompt.\n\n"
        "Backend output:\n"
        f"{backend_output}"
    )


def ask_backend(question: str) -> dict:
    child = st.session_state.get("backend_process")

    if child is None or not child.isalive():
        raise RuntimeError("The backend is not connected. Click Connect first.")

    child.sendline(question)

    try:
        child.expect("Question:")
    except pexpect.EOF:
        backend_output = child.before.strip() if child.before else ""
        reset_backend_after_crash()
        raise RuntimeError(format_backend_crash_message(backend_output))
    except pexpect.TIMEOUT:
        backend_output = child.before.strip() if child.before else ""
        raise RuntimeError(
            "The backend took too long to respond.\n\n"
            "Backend output so far:\n"
            f"{backend_output}"
        )

    full_output = child.before.strip()
    sql_query = extract_sql(full_output)
    result_text = extract_result(full_output)

    return {
        "question": question,
        "full_output": full_output,
        "sql_query": sql_query,
        "result": result_text,
    }


def clear_result():
    st.session_state.question = ""
    st.session_state.has_result = False
    st.session_state.output = {
        "question": "",
        "full_output": "",
        "sql_query": "",
        "result": "",
    }


def disconnect_backend():
    child = st.session_state.get("backend_process")

    if child is not None and child.isalive():
        try:
            child.sendline("exit")
            child.close(force=True)
        except Exception:
            pass

    st.session_state.backend_process = None
    st.session_state.connected = False
    clear_result()


st.set_page_config(
    page_title="Natural Language to SQL",
    page_icon="🔎",
    layout="centered",
)

st.markdown(
    """
    <style>
    .block-container {
        padding-top: 2.5rem;
        padding-bottom: 3rem;
        max-width: 900px;
    }
    .title-box {
        background-color: #ffffff;
        padding: 1.5rem 1.75rem;
        border-radius: 14px;
        border: 1px solid #e5e7eb;
        margin-bottom: 1.25rem;
    }
    .small-note {
        color: #64748b;
        font-size: 0.95rem;
        margin-top: -0.25rem;
    }
    </style>
    """,
    unsafe_allow_html=True,
)

if "backend_process" not in st.session_state:
    st.session_state.backend_process = None

if "connected" not in st.session_state:
    st.session_state.connected = False

if "question" not in st.session_state:
    st.session_state.question = ""

if "has_result" not in st.session_state:
    st.session_state.has_result = False

if "output" not in st.session_state:
    st.session_state.output = {
        "question": "",
        "full_output": "",
        "sql_query": "",
        "result": "",
    }


st.markdown(
    """
    <div class="title-box">
        <h1 style="margin-bottom: 0.25rem; color: #0f172a;">Natural Language to SQL</h1>
        <p class="small-note">
            Type a question in plain English and view the generated SQL and database result.
        </p>
    </div>
    """,
    unsafe_allow_html=True,
)

st.subheader("iLab Login")

col1, col2 = st.columns(2)

with col1:
    ilab_username = st.text_input(
        "iLab username",
        placeholder="Enter your NetID",
        key="ilab_username",
        disabled=backend_is_running(),
    )

with col2:
    ilab_password = st.text_input(
        "iLab password",
        type="password",
        placeholder="Enter your password",
        key="ilab_password",
        disabled=backend_is_running(),
    )

connect_col, disconnect_col = st.columns([1, 1])

with connect_col:
    connect_clicked = st.button(
        "Connect",
        disabled=backend_is_running(),
        use_container_width=True,
    )

with disconnect_col:
    disconnect_clicked = st.button(
        "Disconnect",
        disabled=not backend_is_running(),
        use_container_width=True,
    )

if connect_clicked:
    if not ilab_username.strip() or not ilab_password:
        st.warning("Please enter your iLab username and password first.")
    else:
        with st.spinner("Starting backend and loading the local LLM..."):
            try:
                start_backend(ilab_username.strip(), ilab_password)
                st.success("Backend started. You can now ask questions.")
            except Exception as error:
                st.session_state.connected = False
                st.session_state.backend_process = None
                st.error(f"Could not start backend: {error}")

if disconnect_clicked:
    disconnect_backend()
    st.info("Disconnected.")

if backend_is_running():
    st.success("Backend connected.")
else:
    st.warning("Backend not connected yet. Enter your iLab login and click Connect.")

st.divider()

with st.form("question_form"):
    question = st.text_area(
        "Enter your question:",
        key="question",
        placeholder="Example: What is the average income of owner occupied applications?",
        height=120,
    )

    submit = st.form_submit_button("Submit")

if submit:
    if not backend_is_running():
        st.warning("Please connect to the backend first.")
    elif not question.strip():
        st.warning("Please enter a question first.")
    else:
        with st.spinner("Running query..."):
            try:
                output = ask_backend(question.strip())
                st.session_state.output = output
                st.session_state.has_result = True
            except Exception as error:
                st.session_state.has_result = False
                st.error(f"Query failed: {error}")

if st.session_state.has_result:
    output = st.session_state.output

    st.markdown("### Original Question")
    st.info(output["question"])

    st.markdown("### Generated SQL")
    if output["sql_query"]:
        st.code(output["sql_query"], language="sql")
    else:
        st.warning("Could not automatically find the generated SQL.")
        st.code(output["full_output"])

    st.markdown("### Database Result")

    result_df = try_make_table(output["result"])

    if result_df is not None:
        st.caption(
            f"Showing {len(result_df)} row(s). "
            "Click a column header to sort ascending or descending."
        )

        st.dataframe(
            result_df,
            use_container_width=True,
            hide_index=True,
        )

        with st.expander("Show raw database result"):
            st.code(output["result"])
    else:
        st.code(output["result"])

    with st.expander("Show full terminal output"):
        st.code(output["full_output"])

    st.button("Ask another question", on_click=clear_result)
