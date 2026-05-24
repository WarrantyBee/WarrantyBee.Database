EXEC dbo.usp_AddForeignKey N'tblOnboardingLinks', 'target_role_id', N'tblRoles', 'id';
EXEC dbo.usp_AddForeignKey N'tblOnboardingLinks', 'target_business_id', N'tblBusinessProfiles', 'id';
EXEC dbo.usp_AddForeignKey N'tblOnboardingLinks', 'inviter_user_id', N'tblUsers', 'id';
GO
