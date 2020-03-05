--
-- SETUP_JOB_LAUNCH.sql
--

-- 
-- Launch CRM SSAS CUBE PROCESS job when CRM DATA MART DAILY ETL job
-- completes duccussfully
--

SELECT *
FROM [dbo].[JOB_MONITOR_EVENT];

-- monitor the CRM DATA MART DAILY ETL job for completed successfully
-- insert row into [dbo].[JOB_MONITOR] for the job_id
INSERT [dbo].[JOB_MONITOR] (
	[JOB_ID]
)
VALUES (
	'FBA49241-3339-49F1-9A29-805E097210E3'
)

SELECT *
FROM [dbo].[JOB_MONITOR];
 
-- insert row into [dbo].[JOB_MONITOR_EVENT_OPTION] for the job_id, JOB_MONITOR_ID
INSERT [dbo].[JOB_MONITOR_EVENT_OPTION] (
	[JOB_MONITOR_ID]
,	[JOB_MONITOR_EVENT_ID]	
)
VALUES (
	1
,	1
)


SELECT --* 
	o.[JOB_MONITOR_EVENT_OPTION_ID]
,	m.[JOB_ID]
,	j.[name]
,	e.[JOB_MONITOR_EVENT_DESCRIPTION]
FROM [dbo].[JOB_MONITOR_EVENT_OPTION] o
JOIN [dbo].[JOB_MONITOR] m
	ON m.[JOB_MONITOR_ID] = o.[JOB_MONITOR_ID]
JOIN [msdb].[dbo].[sysjobs] j
	ON j.job_id = m.[JOB_ID]
JOIN [dbo].[JOB_MONITOR_EVENT] e
	ON e.[JOB_MONITOR_EVENT_ID] = o.[JOB_MONITOR_EVENT_ID]



-- Monitor job step completion
-- JOB: CRM SSAS CUBE PROCESS  STEP: PROCESS CUBE 
-- Doing update because row existed (normally do insert)
UPDATE [dbo].[JOB_MONITOR]
SET
	JOB_ID = '8ECB9766-9326-4118-B08D-7F4F6D04DF26'
,	JOB_STEP_UID = 'D4305401-41E9-4E93-8AC3-DA2FFA071A60'
WHERE JOB_MONITOR_ID = 2


-- insert row into [dbo].[JOB_MONITOR_EVENT_OPTION] for the job_id, JOB_MONITOR_ID
INSERT [dbo].[JOB_MONITOR_EVENT_OPTION] (
	[JOB_MONITOR_ID]
,	[JOB_MONITOR_EVENT_ID]	
)
VALUES (
	2
,	2	-- step completed successfully
)

