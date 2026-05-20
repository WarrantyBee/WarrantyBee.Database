EXEC dbo.usp_ResetAutoIncrement N'tblLanguages';
GO

INSERT INTO tblLanguages
(
    name,
    iso_code,
    native_name
)
VALUES
(N'English', N'en', N'English'),
(N'Spanish', N'es', N'Español'),
(N'French', N'fr', N'Français'),
(N'German', N'de', N'Deutsch'),
(N'Portuguese', N'pt', N'Português'),
(N'Arabic', N'ar', N'العربية'),
(N'Chinese', N'zh', N'中文'),
(N'Japanese', N'ja', N'日本語'),
(N'Korean', N'ko', N'한국어'),
(N'Hindi', N'hi', N'हिन्दी');

PRINT N'tblLanguages data inserted successfully.';
GO