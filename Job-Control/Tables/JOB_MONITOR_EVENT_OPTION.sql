﻿CREATE TABLE [dbo].[JOB_MONITOR_EVENT_OPTION]
(
	[JOB_MONITOR_EVENT_OPTION_ID]	INT IDENTITY NOT NULL
		CONSTRAINT PK_JOB_MONITOR_EVENT_OPTION PRIMARY KEY CLUSTERED
,	[JOB_MONITOR_ID]				INT NOT NULL
		CONSTRAINT FK_JOB_MONITOR_EVENT_OPTION_JOB_MONITOR_ID
			FOREIGN KEY REFERENCES 
				[dbo].[JOB_MONITOR](JOB_MONITOR_ID)
,	[JOB_MONITOR_EVENT_ID]			INT NOT NULL
		CONSTRAINT FK_JOB_MONITOR_EVENT_OPTION_JOB_MONITOR_EVENT_ID
			FOREIGN KEY REFERENCES 
				[dbo].[JOB_MONITOR_EVENT](JOB_MONITOR_EVENT_ID)
,	[JOB_ID_TO_LAUNCH]				UNIQUEIDENTIFIER NOT NULL
,	[ENABLED]						INT NOT NULL
		CONSTRAINT DF_JOB_MONITOR_EVENT_OPTION_ENABLED
			DEFAULT 1
,	[RUN_ONCE]						INT NOT NULL
		CONSTRAINT DF_JOB_MONITOR_EVENT_OPTION_RUN_ONCE
			DEFAULT 0
,	[LAST_MODIFIED]		DATETIME NOT NULL
		CONSTRAINT DF_JOB_MONITOR_EVENT_OPTION_LAST_MODIFIED
			DEFAULT GETDATE()
)
