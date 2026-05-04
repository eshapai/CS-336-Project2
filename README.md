# CS 336 Project 3

#  Team Members
- Esha P  
- Vishnu M  
- Nick M  
- Sahaj p  

---

#  Project Overview

This project allows a user to ask questions in **natural language**, and the program converts those questions into **SQL queries** that run on a PostgreSQL database.

The system connects a local AI model (LLM) with the Rutgers iLab database using SSH.

---

##  How the Program Works

1. The user types a question (example: "What is the average income?")
2. The LLM converts the question into a SQL query
3. The program extracts the SQL query from the LLM output
4. The SQL query is sent to the iLab server using SSH
5. The query runs on the database
6. The results are returned and printed to the user

---

##  LLM Used

We used a local AI model:

- **Model:** Qwen2.5-3B-Instruct  
- **Library:** llama-cpp-python  

This model meets the requirement of being under 4 billion parameters.

---

## Security

We used the `getpass` library to safely enter passwords:

```python
import getpass
password = getpass.getpass("ILAB password: ")

##Instructions
Run:
\i step_2.sql
\i step_3.sql
\i step_4.sql
to create the Application table.
