/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

IF NOT EXISTS (
	SELECT 1 
	FROM [dbo].[JOB_MONITOR_EVENT]
	WHERE [JOB_MONITOR_EVENT_DESCRIPTION] = 'JOB COMPLETED SUCCESSFULLY'
)
INSERT [dbo].[JOB_MONITOR_EVENT] (
	[JOB_MONITOR_EVENT_DESCRIPTION]
)
VALUES (
	'JOB COMPLETED SUCCESSFULLY'
);
GO


IF NOT EXISTS (
	SELECT 1 
	FROM [dbo].[JOB_MONITOR_EVENT]
	WHERE [JOB_MONITOR_EVENT_DESCRIPTION] = 'JOB STEP COMPLETED SUCCESSFULLY'
)
INSERT [dbo].[JOB_MONITOR_EVENT] (
	[JOB_MONITOR_EVENT_DESCRIPTION]
)
VALUES (
	'JOB STEP COMPLETED SUCCESSFULLY'
);
GO

