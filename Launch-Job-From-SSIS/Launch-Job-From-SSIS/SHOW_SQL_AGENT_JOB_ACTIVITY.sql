DECLARE @RUN_DATE DATE = GETDATE();

SELECT
	j.[name]
,	a.[run_requested_date]
,	a.[last_executed_step_id]
FROM msdb.dbo.sysjobactivity a
JOIN msdb.dbo.sysjobs j ON j.job_id = a.job_id
WHERE a.start_execution_date > @RUN_DATE
AND stop_Execution_date IS NULL
ORDER BY 1

