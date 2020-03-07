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

	-- insert row into JOB_MONITOR
	INSERT [dbo].[JOB_MONITOR] (
		[JOB_ID]
	,	[JOB_STEP_UID]
	)
	VALUES (
		@JOB_ID_TO_MONITOR
	,	@JOB_STEP_UID_TO_MONITOR
	)

	DECLARE @JOB_MONITOR_ID INT = SCOPE_IDENTITY();

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
	)

END
