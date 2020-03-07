/*

	-- test monitor for job completed successfully
	EXEC [dbo].[ADD_JOB_TO_MONITOR]
		@JOB_ID_TO_MONITOR = 'FBA49241-3339-49F1-9A29-805E097210E3'
	,	@JOB_ID_TO_LAUNCH = '8ECB9766-9326-4118-B08D-7F4F6D04DF26'
	,	@JOB_MONITOR_EVENT_ID = 1

	-- test monitor for job step completion
	EXEC [dbo].[ADD_JOB_TO_MONITOR]
		@JOB_ID_TO_MONITOR = '8ECB9766-9326-4118-B08D-7F4F6D04DF26'
	,	@JOB_ID_TO_LAUNCH = 'B5B26BDA-C4E4-4501-89B6-17D0CC394498'
	,	@JOB_MONITOR_EVENT_ID = 2
	,	@JOB_STEP_UID_TO_MONITOR='D4305401-41E9-4E93-8AC3-DA2FFA071A60'

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
END
