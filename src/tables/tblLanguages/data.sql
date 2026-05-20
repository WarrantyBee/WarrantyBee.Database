SET IDENTITY_INSERT tblLanguages ON;
GO

MERGE INTO tblLanguages AS target
USING (VALUES
    (1, N'English', N'en', N'English'),
    (2, N'Spanish', N'es', N'Español'),
    (3, N'French', N'fr', N'Français'),
    (4, N'German', N'de', N'Deutsch'),
    (5, N'Portuguese', N'pt', N'Português'),
    (6, N'Arabic', N'ar', N'العربية'),
    (7, N'Chinese', N'zh', N'中文'),
    (8, N'Japanese', N'ja', N'日本語'),
    (9, N'Korean', N'ko', N'한국어'),
    (10, N'Hindi', N'hi', N'हिन्दी')
) AS source (id, name, iso_code, native_name)
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET name = source.name, iso_code = source.iso_code, native_name = source.native_name
WHEN NOT MATCHED THEN
    INSERT (id, name, iso_code, native_name)
    VALUES (source.id, source.name, source.iso_code, source.native_name);
GO

SET IDENTITY_INSERT tblLanguages OFF;
GO

DBCC CHECKIDENT ('tblLanguages', RESEED, 10);
GO

PRINT N'tblLanguages data merged successfully.';
GO

