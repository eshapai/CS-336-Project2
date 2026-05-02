import sys
import psycopg2
import pandas as pd
import warnings
warnings.filterwarnings("ignore", category=UserWarning)

if len(sys.argv) < 2:
    print("Usage: python3 ilab_script.py \"SELECT ...\"")
    sys.exit(1)

query = sys.argv[1]

if not query.strip().lower().startswith("select"):
    print("Only SELECT queries allowed.")
    sys.exit(1)

conn = psycopg2.connect(
    host="postgres.cs.rutgers.edu",
    database="egp59",
    user="egp59"
)

df = pd.read_sql_query(query, conn)
print(df.to_string(index=False))

conn.close()