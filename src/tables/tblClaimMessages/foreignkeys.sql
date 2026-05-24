EXEC dbo.usp_AddForeignKey N'tblClaimMessages', 'claim_id', N'tblClaims', 'id';
EXEC dbo.usp_AddForeignKey N'tblClaimMessages', 'sender_user_id', N'tblUsers', 'id';
GO
