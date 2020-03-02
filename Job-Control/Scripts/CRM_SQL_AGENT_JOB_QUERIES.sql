
--
-- queries to retrieve job_id and step_uid for our jobs
--
;WITH CTE_JOB_NAME AS (
	SELECT 
		JOB_NAME
	FROM 
	(
		VALUES
			(N'CRM DATA MART DAILY ETL')
		,	(N'CRM SSAS CUBE PROCESS')
		,	(N'CRM DASHBOARD DAILY REFRESH')
	)
	AS JOBS(JOB_NAME)
)

SELECT --*
	j.[name]
,	s.job_id
,	s.step_id
,	s.step_name
,	s.step_uid
FROM msdb.dbo.sysjobsteps s
JOIN msdb.dbo.sysjobs j
	ON j.job_id = s.job_id
JOIN CTE_JOB_NAME n
	ON n.JOB_NAME = j.[name]
ORDER BY j.[name], s.step_id;


