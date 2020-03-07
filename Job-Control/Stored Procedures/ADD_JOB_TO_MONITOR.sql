/*

	See SETUP_JOB_LAUNCH script for examples that call this stored procedure.

*/
CREATE PROCEDURE [dbo].[ADD_JOB_TO_MONITOR]
	@JOB_ID_TO_MONITOR			UNIQUEIDENTIFIER
,	@JOB_ID_TO_LAUNCH			UNIQUEIDENTIFIER
,	@JOB_MONITOR_EVENT_ID		INT
,	@JOB_STEP_UID_TO_MONITOR	UNIQUEIDENTIFIER = NULL
,	@ENABLED					INT = 1
,	@RUN_ONCE					INT = 0
AS
BEGIN
	DECLARE 
		@ERROR_MSG			NVARCHAR(MAX);

	-- Validate JOB_IDs and JOB_STEP_UID

	-- Validate @JOB_ID_TO_MONITOR
	IF NOT EXISTS (
		SELECT 1 FROM [msdb].[dbo].[sysjobs]
		WHERE job_id = @JOB_ID_TO_MONITOR 
	)
	BEGIN
		SET @ERROR_MSG = 
			CONCAT(
				N'JOB_ID to monitor '
			,	TRY_CONVERT(NVARCHAR(50), @JOB_ID_TO_MONITOR)
			,	N' does not exist.'
		);
		THROW 2147483647, @ERROR_MSG, 1;
	END

	-- Validate @JOB_ID_TO_LAUNCH
	IF NOT EXISTS (
		SELECT 1 FROM [msdb].[dbo].[sysjobs]
		WHERE job_id = @JOB_ID_TO_LAUNCH 
	)
	BEGIN
		SET @ERROR_MSG = 
			CONCAT(
				N'JOB_ID to monitor '
			,	TRY_CONVERT(NVARCHAR(50), @JOB_ID_TO_LAUNCH)
			,	N' does not exist.'
		);
		THROW 2147483647, @ERROR_MSG, 1;
	END

	-- Validate @JOB_MONITOR_EVENT_ID
	-- 1=Job completed successfully
	-- 2=Job step completed successfully
	IF @JOB_MONITOR_EVENT_ID NOT IN (1, 2)
	BEGIN
		SET @ERROR_MSG = 
			CONCAT(
				N'@JOB_MONITOR_EVENT_ID '
			,	TRY_CONVERT(NVARCHAR(50), @JOB_MONITOR_EVENT_ID)
			,	N' is not valid. Value can be 1 or 2'
		);
		THROW 2147483647, @ERROR_MSG, 1;
	END

	-- Validate 
	IF @JOB_MONITOR_EVENT_ID = 2	-- job step completed successfully
	BEGIN
	IF NOT EXISTS (
		SELECT 1 FROM [msdb].[dbo].[sysjobsteps]
		WHERE job_id = @JOB_ID_TO_MONITOR 
		AND step_uid = @JOB_STEP_UID_TO_MONITOR
	)
		BEGIN
			SET @ERROR_MSG = 
				CONCAT(
					N'@JOB_STEP_UID_TO_MONITOR to monitor '
				,	TRY_CONVERT(NVARCHAR(50), @JOB_STEP_UID_TO_MONITOR)
				,	N' does not exist in the @JOB_ID_TO_MONITOR='
				,	TRY_CONVERT(NVARCHAR(50), @JOB_ID_TO_MONITOR)
			);
			THROW 2147483647, @ERROR_MSG, 1;
		END
	END

	DECLARE 
		@JOB_MONITOR_ID						INT
	,	@JOB_MONITOR_EXISTS					BIT
	,	@JOB_MONITOR_EVENT_OPTION_EXISTS	BIT = 0;

	-- Check if row already exists
	SELECT 
		@JOB_MONITOR_ID = [JOB_MONITOR_ID]
	FROM [dbo].[JOB_MONITOR]
	WHERE [JOB_ID] = @JOB_ID_TO_MONITOR
	AND (
		@JOB_STEP_UID_TO_MONITOR IS NULL OR
		[JOB_STEP_UID] = @JOB_STEP_UID_TO_MONITOR
	)

	IF @JOB_MONITOR_ID IS NULL
	BEGIN
		SET @JOB_MONITOR_EXISTS = 0;
		-- Insert row into JOB_MONITOR if it doesn't already exist. You can
		-- have multiple jobs get launched based on a job or job step
		-- completing successfully.
		INSERT [dbo].[JOB_MONITOR] (
			[JOB_ID]
		,	[JOB_STEP_UID]
		)
		VALUES (
			@JOB_ID_TO_MONITOR
		,	@JOB_STEP_UID_TO_MONITOR
		)

		SET @JOB_MONITOR_ID = SCOPE_IDENTITY();
	END

	ELSE
		SET @JOB_MONITOR_EXISTS = 1;
	
	IF @JOB_MONITOR_EXISTS = 1
	BEGIN
		-- check if [JOB_MONITOR_EVENT_OPTION] row already exists
		IF NOT EXISTS (
			SELECT 1
			FROM [dbo].[JOB_MONITOR_EVENT_OPTION]
			WHERE JOB_MONITOR_ID = @JOB_MONITOR_ID
			AND [JOB_MONITOR_EVENT_ID] = @JOB_MONITOR_EVENT_ID
			AND [JOB_ID_TO_LAUNCH] = @JOB_ID_TO_LAUNCH
		)
			SET @JOB_MONITOR_EVENT_OPTION_EXISTS = 0;
		ELSE
			SET @JOB_MONITOR_EVENT_OPTION_EXISTS = 1;
	END

	IF @JOB_MONITOR_EVENT_OPTION_EXISTS = 0
	BEGIN
		-- insert row into [dbo].[JOB_MONITOR_EVENT_OPTION] 
		INSERT [dbo].[JOB_MONITOR_EVENT_OPTION] (
			[JOB_MONITOR_ID]
		,	[JOB_MONITOR_EVENT_ID]	
		,	[JOB_ID_TO_LAUNCH]
		)
		VALUES (
			@JOB_MONITOR_ID
		,	@JOB_MONITOR_EVENT_ID
		,	@JOB_ID_TO_LAUNCH
		);
	END
END
