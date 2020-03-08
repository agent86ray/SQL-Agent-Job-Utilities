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
 	j.[name] AS [MONITOR_JOB_NAME]
, 	js.[step_name] AS [MONITOR_JOB_STEP_NAME]
,	e.[JOB_MONITOR_EVENT_DESCRIPTION]
,	j2.[name] AS [JOB_NAME_TO_LAUNCH]
FROM [dbo].[JOB_MONITOR_EVENT_OPTION] o
JOIN [dbo].[JOB_MONITOR] m
	ON m.[JOB_MONITOR_ID] = o.[JOB_MONITOR_ID]
JOIN [msdb].[dbo].[sysjobs] j
	ON j.job_id = m.[JOB_ID]
JOIN [dbo].[JOB_MONITOR_EVENT] e
	ON e.[JOB_MONITOR_EVENT_ID] = o.[JOB_MONITOR_EVENT_ID]
LEFT JOIN [msdb].[dbo].[sysjobsteps] js
	ON js.[job_id] = m.[JOB_ID] 
AND js.[step_uid] = m.JOB_STEP_UID
JOIN [msdb].[dbo].[sysjobs] j2
	ON j2.[job_id] = o.[JOB_ID_TO_LAUNCH];

/*
SAMPLE SQL AGENT jobs:

job name	                job_id
=========================   ====================================
SAMPLE DAILY ETL	        796A3A71-4B93-4DBE-9466-C4BD714C8681
SAMPLE DAILY CUBE PROCESS	9359E080-2084-4218-8F07-4A39071065D4
SAMPLE REFRESH DASHBOARDS	737B2D39-D165-4DCC-9A60-D3C3D773B232

STEPS IN SAMPLE DAILY CUBE PROCESS SQL AGENT job:

step_id	step_name	    step_uid
======= ============    ====================================
1	    PROCESS CUBE	88A30659-392A-4F14-8AF7-FDF243C540F3
2	    BACKUP CUBE	    84BBF582-AE0C-4FDE-88A1-58F089D0D903
*/

	-- Launch SAMPLE DAILY CUBE PROCESS job when SAMPLE DAILY ETL
	-- job completes successfully
	EXEC [dbo].[ADD_JOB_TO_MONITOR]
		@JOB_ID_TO_MONITOR = '796A3A71-4B93-4DBE-9466-C4BD714C8681'
	,	@JOB_ID_TO_LAUNCH = '9359E080-2084-4218-8F07-4A39071065D4'
	,	@JOB_MONITOR_EVENT_ID = 1

	-- Launch SAMPLE REFRESH DASHBOARDS job when step 1 in
	-- SAMPLE DAILY CUBE PROCESS job completes successfully.
	EXEC [dbo].[ADD_JOB_TO_MONITOR]
		@JOB_ID_TO_MONITOR = '9359E080-2084-4218-8F07-4A39071065D4'
	,	@JOB_ID_TO_LAUNCH = '737B2D39-D165-4DCC-9A60-D3C3D773B232'
	,	@JOB_MONITOR_EVENT_ID = 2
	,	@JOB_STEP_UID_TO_MONITOR='88A30659-392A-4F14-8AF7-FDF243C540F3'
	,	@RUN_ONCE = 1

	SELECT * FROM [dbo].[JOB_MONITOR];

	SELECT * FROM [dbo].[JOB_MONITOR_EVENT_OPTION]

