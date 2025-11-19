CALL usp_ResetAutoIncrement('tblLanguages');

INSERT INTO `tblLanguages`
(
    `name`,
    `iso_code`,
    `native_name`
)
VALUES
('English', 'en', 'English'),
('Spanish', 'es', 'Español'),
('French', 'fr', 'Français'),
('German', 'de', 'Deutsch'),
('Portuguese', 'pt', 'Português'),
('Arabic', 'ar', 'العربية'),
('Chinese', 'zh', '中文'),
('Japanese', 'ja', '日本語'),
('Korean', 'ko', '한국어'),
('Hindi', 'hi', 'हिन्दी');

SELECT 'tblLanguages data inserted successfully.' AS message;