﻿/*

	EXEC [dbo].[QUEUE_JOBS_TO_LAUNCH];

	SELECT * FROM [dbo].[QUEUE_JOB_LOG]; 

	SELECT * FROM [dbo].[JOB_LAUNCH_QUEUE];

*/
CREATE PROCEDURE [dbo].[QUEUE_JOBS_TO_LAUNCH]
AS
BEGIN
	DECLARE 
		@RUN_TIME			DATETIME = GETDATE()
	,	@MAX_INSTANCE_ID	INT
	,	@QUEUE_JOB_LOG_ID	INT
	,	@JOBS_QUEUED_COUNT	INT = 0;

	-- Get the MAX_INSTANCE_ID from the last run
	SELECT TOP 1
		@MAX_INSTANCE_ID = MAX_INSTANCE_ID
	FROM [dbo].[QUEUE_JOB_LOG]
	ORDER BY [QUEUE_JOB_LOG_ID] DESC;

	IF @MAX_INSTANCE_ID IS NULL
		SET @MAX_INSTANCE_ID = 0;

	TRUNCATE TABLE [dbo].[JOB_MONITOR_JOB_HISTORY_STAGING];

	--
	-- stage the job steps completed since the last run
	-- rename this table?
	--
	INSERT [dbo].[JOB_MONITOR_JOB_HISTORY_STAGING] (
		[INSTANCE_ID] 
	,	[JOB_ID]
	,	[STEP_ID]
	,	[RUN_STATUS]
	,	[START_TIME]
	,	[END_TIME]	
	,	[SERVER]
	)
	SELECT
		[instance_id]
	,	[job_id]
	,	[step_id]
	,	[run_status]
	,	[msdb].[dbo].[agent_datetime](run_date, run_time) AS [START_TIME]
	,	DATEADD(second, run_duration, [msdb].[dbo].[agent_datetime](run_date, run_time)) AS [END_TIME]
	,	[server]
	FROM [msdb].[dbo].[sysjobhistory]
	WHERE [instance_id] > @MAX_INSTANCE_ID
	AND [run_status] IN (0, 1);

	-- check if any jobs / job steps completed since the last run
	IF NOT EXISTS (
		SELECT 
			TOP 1 *
		FROM [dbo].[JOB_MONITOR_JOB_HISTORY_STAGING]
	)
	BEGIN
		INSERT [dbo].[QUEUE_JOB_LOG] (
			[RUN_TIME]
		,	[MAX_INSTANCE_ID]
		,	[ROW_COUNT]
		)
		VALUES (
			@RUN_TIME
		,	@MAX_INSTANCE_ID
		,	0
		)
		RETURN;	-- nothing to do
	END

	--
	-- queue any jobs that need to be launched based on
	-- jobs completed successfully
	--
	INSERT [dbo].[JOB_LAUNCH_QUEUE] (
		[JOB_MONITOR_EVENT_OPTION_ID]
	)
	SELECT
		o.[JOB_MONITOR_EVENT_OPTION_ID]
	FROM [dbo].[JOB_MONITOR_JOB_HISTORY_STAGING] s
	JOIN [dbo].[JOB_MONITOR] m
		ON m.JOB_ID = s.JOB_ID
	JOIN [dbo].[JOB_MONITOR_EVENT_OPTION] o
		ON o.JOB_MONITOR_ID = m.JOB_MONITOR_ID
	JOIN [dbo].[JOB_MONITOR_EVENT] e
		ON e.[JOB_MONITOR_EVENT_ID] = o.[JOB_MONITOR_EVENT_ID]
	WHERE m.[ENABLED] = 1
	AND o.[ENABLED] = 1
	AND s.[step_id] = 0		-- Job Completion
	AND (
			-- JOB COMPLETED SUCCESSFULLY
			(e.JOB_MONITOR_EVENT_ID = 1	AND s.[run_status] = 1)
	)

	SET @JOBS_QUEUED_COUNT += @@ROWCOUNT;

	-- queue any jobs that need to be launched based on a
	-- job step that completed successfully - check [JOB_STEP_UID] 
	-- from JOB_MONITOR
	INSERT [dbo].[JOB_LAUNCH_QUEUE] (
		[JOB_MONITOR_EVENT_OPTION_ID]
	)
	SELECT
		o.[JOB_MONITOR_EVENT_OPTION_ID]
	FROM [dbo].[JOB_MONITOR_JOB_HISTORY_STAGING] s
	JOIN [msdb].[dbo].[sysjobsteps] j
		ON j.job_id = s.JOB_ID AND j.step_id = s.STEP_ID
	JOIN [dbo].[JOB_MONITOR] m
		ON m.JOB_ID = s.JOB_ID AND m.JOB_STEP_UID = j.step_uid
	JOIN [dbo].[JOB_MONITOR_EVENT_OPTION] o
		ON o.JOB_MONITOR_ID = m.JOB_MONITOR_ID
	JOIN [dbo].[JOB_MONITOR_EVENT] e
		ON e.[JOB_MONITOR_EVENT_ID] = o.[JOB_MONITOR_EVENT_ID]
	WHERE m.[ENABLED] = 1
	AND o.[ENABLED] = 1
	AND s.[step_id] > 0		-- Job Step Completion
	AND (
			-- JOB STEP COMPLETED SUCCESSFULLY
			(e.JOB_MONITOR_EVENT_ID = 2	AND s.[run_status] = 1)
	)

	SET @JOBS_QUEUED_COUNT += @@ROWCOUNT;

	--
	-- update [dbo].[QUEUE_JOB_LOG]
	--
	IF @JOBS_QUEUED_COUNT > 0
	BEGIN
		SELECT
			@MAX_INSTANCE_ID = MAX(INSTANCE_ID)
		FROM [dbo].[JOB_MONITOR_JOB_HISTORY_STAGING];
	END

	INSERT [dbo].[QUEUE_JOB_LOG] (
		[RUN_TIME]
	,	[MAX_INSTANCE_ID]
	,	[ROW_COUNT]
	)
	VALUES (
		@RUN_TIME
	,	@MAX_INSTANCE_ID
	,	@JOBS_QUEUED_COUNT
	);
END

