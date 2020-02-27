# SQL-Agent-JobUtilities
Collection of utilities for SQL Server Agent

# Job Launcher
In my organization we have hundreds of SQL Agent jobs running daily. Our jobs have many steps, sometimes as many as 50! We would like to implement a solution where we can split our large jobs into multiple smaller ones while respecting the dependencies between the jobs. Our ideal solution would be to automatically launch a SQL Agent job when the job(s) it depends on have completed. We would like the solution to be data-driven where we put these relationships in tables and a SQL Agent job periodically runs to launch jobs when their predecessors have completed.
