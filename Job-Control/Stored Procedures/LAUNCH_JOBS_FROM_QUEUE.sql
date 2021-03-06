﻿CREATE PROCEDURE [dbo].[LAUNCH_JOBS_FROM_QUEUE]
AS
BEGIN
	DECLARE
		@JOB_LAUNCH_QUEUE_ID	INT
	,	@JOB_MONITOR_EVENT_OPTION_ID	INT
	,	@JOB_ID_TO_LAUNCH		UNIQUEIDENTIFIER
	,	@RUN_ONCE				INT
	,	@DONE					INT = 0
	,	@RC						INT
	,	@RUN_TIME				DATETIME = GETDATE();

	WHILE @DONE = 0
	BEGIN
		SELECT TOP 1
			@JOB_LAUNCH_QUEUE_ID = q.[JOB_LAUNCH_QUEUE_ID]
		,	@JOB_MONITOR_EVENT_OPTION_ID = q.[JOB_MONITOR_EVENT_OPTION_ID]
		,	@JOB_ID_TO_LAUNCH = o.[JOB_ID_TO_LAUNCH]
		,	@RUN_ONCE = o.RUN_ONCE
		FROM [dbo].[JOB_LAUNCH_QUEUE] q
		JOIN [dbo].[JOB_MONITOR_EVENT_OPTION] o
			ON o.[JOB_MONITOR_EVENT_OPTION_ID] = q.[JOB_MONITOR_EVENT_OPTION_ID]
		WHERE q.[JOB_LAUNCH_TIME] IS NULL
		ORDER BY q.[QUEUE_TIME];

		IF @@ROWCOUNT = 0
			SET @DONE = 1;
		ELSE

		BEGIN
			-- TO DO: implement TRY / CATCH to keep going on error
			-- TO DO: implement log

			-- start the SQL Agent job
			EXEC @RC = [msdb].[dbo].[sp_start_job]
							@job_id = @JOB_ID_TO_LAUNCH;

			IF @RC = 0
			BEGIN
				-- mark the job as queued
				UPDATE [dbo].[JOB_LAUNCH_QUEUE]
				SET
					[JOB_LAUNCH_TIME] = GETDATE()
				WHERE [JOB_LAUNCH_QUEUE_ID] = @JOB_LAUNCH_QUEUE_ID;

				-- If RUN_ONCE = 1, set to 0 and set ENABLED = 0
				IF @RUN_ONCE = 1
				BEGIN
					UPDATE [dbo].[JOB_MONITOR_EVENT_OPTION]
					SET
						[RUN_ONCE] = 0
					,	[ENABLED] = 0
					WHERE [JOB_MONITOR_EVENT_OPTION_ID] = @JOB_MONITOR_EVENT_OPTION_ID;
				END

				-- log the job was launched
				INSERT [dbo].[JOB_LAUNCH_LOG] (
					[JOB_LAUNCH_QUEUE_ID]
				,	[RUN_TIME]
				)
				VALUES (
					@JOB_LAUNCH_QUEUE_ID
				,	@RUN_TIME
				);
			END
		END
	END
END