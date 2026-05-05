# CS 336 Project 3

#  Team Members
- Esha P: Built the main functionality connecting llm to ssh to database, enabling querying of dataset.
- Vishnu M: Created readME and checked everything ensuring it worked.
- Nick M: Build out the extra credit frontend portion of the project.
- Sahaj P: Did not hear from.  

---

#  Project Overview

This project allows a user to ask questions in **natural language**, and the program converts those questions into **SQL queries** that run on a PostgreSQL database. The system connects a local AI model (LLM) with the Rutgers iLab database using SSH.

* The LLM generates a single SELECT query
* database_llm.py sends the query to iLab using SSH (paramiko)
* The query runs remotely and results are returned (SQL script and result are printed)

---

##  File Structure + Running It

├── database_creation.sql   # Run on iLab to create + load database

├── database_llm.py         # Run locally (main script)

├── schema_llm.sql          # Schema passed to LLM


If you pull this remo, update these in database_llm.py:
```python
ILAB_SCRIPT_PATH = "/common/home/egp59/Desktop/336sp26/project2/ilab_script.py"
ILAB_PYTHON = "/common/home/egp59/cs336env/bin/python"
```
Log into ilab and run database_creation.sql. This file combines step_2.sql, step_3.sql, and step_4.sql from Project 2 to intialize the database.

Return to your local environment and run python3 database_llm.py.
Enter iLab credentials when prompted
Ask a question! (ex. What is the average income of owner occupied applications?)

---

##  LLM Used

- **Model:** Qwen2.5-3B-Instruct  
- **Library:** llama-cpp-python  

This model meets the requirement of being under 4 billion parameters.








