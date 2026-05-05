import re
import getpass
import shlex
import paramiko
import os
from llama_cpp import Llama

SCHEMA_FILE = "schema_llm.sql"

ILAB_HOST = "ilab.cs.rutgers.edu"
ILAB_SCRIPT_PATH = os.getenv(
    "ILAB_SCRIPT_PATH",
    "/common/home/egp59/Desktop/336sp26/project2/ilab_script.py"
)
ILAB_PYTHON = "/common/home/egp59/cs336env/bin/python"

def load_schema():
    with open(SCHEMA_FILE, "r", encoding="utf-8") as f:
        return f.read()


def make_prompt(schema, question):
    return f"""
    You are a PostgreSQL SQL generator.

    Rules:
    - Output only one SQL SELECT query.
    - Use Application as the main table.
    - Only use tables and columns from the schema.
    - Use joins when needed to ensure accuracy of SQL prompt
    - End the query with a semicolon.

    Examples of correct queries:

    Question: How many mortgages have a loan value greater than the applicant income?
    SQL:
    SELECT COUNT(*)
    FROM application
    WHERE loan_amount_000s > applicant_income_000s;

    Question: What is the average income of owner occupied applications?
    SQL:
    SELECT AVG(applicant_income_000s)
    FROM application
    WHERE owner_occupancy = 1;

    Question: What is the most common loan denial reason?
    SQL:
    SELECT denial_reason, COUNT(*) AS denial_count
    FROM denialreasonlink
    GROUP BY denial_reason
    ORDER BY denial_count DESC
    LIMIT 1;
    
    Schema:
    {schema}

    Question:
    {question}

    SQL:
    """.strip()


def extract_sql(text):
    text = text.strip()
    text = text.replace("```sql", "").replace("```", "")

    match = re.search(r"SELECT[\s\S]*?;", text, re.IGNORECASE)
    if not match:
        return None

    sql = match.group(0).strip()

    if not sql.upper().startswith("SELECT"):
        return None

    return sql


def run_llm(llm, schema, question):
    prompt = make_prompt(schema, question)

    response = llm.create_chat_completion(
        messages=[
            {
                "role": "system",
                "content": "You generate only valid PostgreSQL SELECT queries."
            },
            {
                "role": "user",
                "content": prompt
            }
        ],
        temperature=0.1,
        max_tokens=200
    )

    raw = response["choices"][0]["message"]["content"]
    return extract_sql(raw), raw


def run_ilab_script(sql, username, password):
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    client.connect(
        hostname=ILAB_HOST,
        username=username,
        password=password
    )

    quoted_sql = shlex.quote(sql)
    command = f"{ILAB_PYTHON} {ILAB_SCRIPT_PATH} {quoted_sql}"

    stdin, stdout, stderr = client.exec_command(command)

    output = stdout.read().decode()
    error = stderr.read().decode()

    if output:
        return output

    return error

    client.close()


def main():
    print("Loading schema...")
    schema = load_schema()

    print("Loading model...")
    llm = Llama.from_pretrained(
        repo_id="Qwen/Qwen2.5-3B-Instruct-GGUF",
        filename="qwen2.5-3b-instruct-q4_k_m.gguf",
        n_ctx=2048,
        verbose=False
    )

    username = input("ILAB username: ")
    password = getpass.getpass("ILAB password: ")

    print("\nAsk questions about your database. Type exit to quit.\n")

    while True:
        question = input("Question: ")

        if question == "exit":
            break

        if question == "":
            continue

        sql, raw_output = run_llm(llm, schema, question)

        if sql is None:

            print("\nCould not extract SQL.")
            print("Raw model output:")
            print(raw_output)
            continue

        print("\nGenerated SQL:")
        print(sql)

        print("\nResult:")
        result = run_ilab_script(sql, username, password)
        print(result)


if __name__ == "__main__":
    main()