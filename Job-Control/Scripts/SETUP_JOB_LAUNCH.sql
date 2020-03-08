--
-- SETUP_JOB_LAUNCH.sql
--

/*
	Create sample SQL Agent jobs

*/

-- Details on the sample SQL Agent jobs
SELECT 
 	[name]
,	[job_id]
FROM [msdb].[dbo].[sysjobs]
WHERE [name] LIKE 'SAMPLE%'


-- Details on the steps for the SAMPLE DAILY CUBE PROCESS job
SELECT
	[step_id]
,	[step_name]
,	[step_uid]
FROM [msdb].[dbo].[sysjobsteps]
WHERE [job_id] = '9359E080-2084-4218-8F07-4A39071065D4'
ORDER BY [step_id]


-- 
-- Script to add jobs and job steps to monitor
--


	SELECT * FROM [dbo].[JOB_MONITOR]

	-- list jobs / job steps monitored and jobs to launch
	SELECT
		m.[JOB_ID]	AS [MONITOR_JOB_ID]
	,	j.[name] AS [MONITOR_JOB_NAME]
	,	e.[JOB_MONITOR_EVENT_DESCRIPTION]
	,	o.[JOB_ID_TO_LAUNCH]
	,	j2.[name] AS [JOB_NAME_TO_LAUNCH]
	FROM [dbo].[JOB_MONITOR_EVENT_OPTION] o
	JOIN [dbo].[JOB_MONITOR] m
		ON m.[JOB_MONITOR_ID] = o.[JOB_MONITOR_ID]
	JOIN [msdb].[dbo].[sysjobs] j
		ON j.job_id = m.[JOB_ID]
	JOIN [dbo].[JOB_MONITOR_EVENT] e
		ON e.[JOB_MONITOR_EVENT_ID] = o.[JOB_MONITOR_EVENT_ID]
	JOIN [msdb].[dbo].[sysjobs] j2
		ON j2.[job_id] = o.[JOB_ID_TO_LAUNCH];


	-- test monitor for job completed successfully
	EXEC [dbo].[ADD_JOB_TO_MONITOR]
		@JOB_ID_TO_MONITOR = 'FBA49241-3339-49F1-9A29-805E097210E3'
	,	@JOB_ID_TO_LAUNCH = '8ECB9766-9326-4118-B08D-7F4F6D04DF26'
	,	@JOB_MONITOR_EVENT_ID = 1

	SELECT * FROM [dbo].[JOB_MONITOR_EVENT_OPTION]

	SELECT * FROM [dbo].[JOB_MONITOR]

	-- test monitor for job step completion
	EXEC [dbo].[ADD_JOB_TO_MONITOR]
		@JOB_ID_TO_MONITOR = '8ECB9766-9326-4118-B08D-7F4F6D04DF26'
	,	@JOB_ID_TO_LAUNCH = 'B5B26BDA-C4E4-4501-89B6-17D0CC394498'
	,	@JOB_MONITOR_EVENT_ID = 2
	,	@JOB_STEP_UID_TO_MONITOR='D4305401-41E9-4E93-8AC3-DA2FFA071A60'
	,	@RUN_ONCE = 1

	SELECT * FROM [dbo].[JOB_MONITOR_EVENT_OPTION]

	-- add job to monitor for completion; job already exists in JOB_MONITOR
	EXEC [dbo].[ADD_JOB_TO_MONITOR]
		@JOB_ID_TO_MONITOR = 'FBA49241-3339-49F1-9A29-805E097210E3'
	,	@JOB_ID_TO_LAUNCH = '09D9314E-295B-4A33-A264-128EB3D1B242'
	,	@JOB_MONITOR_EVENT_ID = 1
