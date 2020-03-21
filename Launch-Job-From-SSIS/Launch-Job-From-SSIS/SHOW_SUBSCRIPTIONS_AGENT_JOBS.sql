SELECT
	j.job_id JOB_ID
,	TRY_CONVERT(uniqueidentifier, j.[name]) JOB_NAME
,	c.[name] REPORT_NAME
FROM ReportServer.dbo.ReportSchedule rs
JOIN msdb.dbo.sysjobs j ON rs.ScheduleID = 
	TRY_CONVERT(uniqueidentifier, j.[name])
JOIN ReportServer.dbo.Subscriptions s ON 
	s.[SubscriptionID] = rs.[SubscriptionID]
JOIN ReportServer.dbo.Catalog c ON c.itemid = s.[Report_OID]






--The JOB_NAME is the SQL Agent job name