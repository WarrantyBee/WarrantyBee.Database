EXEC dbo.usp_CreateForeignKey N'tblEventDeliveries', N'event_log_id', N'tblEventLogs', N'id';
EXEC dbo.usp_CreateForeignKey N'tblEventDeliveries', N'subscription_id', N'tblEventSubscriptions', N'id';
GO
