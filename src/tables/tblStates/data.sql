SET IDENTITY_INSERT tblStates ON;
GO

MERGE INTO tblStates AS target
USING (VALUES
    -- India States and Union Territories (Country ID: 76)
(1, N'Andhra Pradesh', N'AP', N'Amaravati', 225, 76),
(2, N'Arunachal Pradesh', N'AR', N'Itanagar', 225, 76),
(3, N'Assam', N'AS', N'Dispur', 225, 76),
(4, N'Bihar', N'BR', N'Patna', 225, 76),
(5, N'Chhattisgarh', N'CG', N'Raipur', 225, 76),
(6, N'Goa', N'GA', N'Panaji', 225, 76),
(7, N'Gujarat', N'GJ', N'Gandhinagar', 225, 76),
(8, N'Haryana', N'HR', N'Chandigarh', 225, 76),
(9, N'Himachal Pradesh', N'HP', N'Shimla', 225, 76),
(10, N'Jharkhand', N'JH', N'Ranchi', 225, 76),
(11, N'Karnataka', N'KA', N'Bengaluru', 225, 76),
(12, N'Kerala', N'KL', N'Thiruvananthapuram', 225, 76),
(13, N'Madhya Pradesh', N'MP', N'Bhopal', 225, 76),
(14, N'Maharashtra', N'MH', N'Mumbai', 225, 76),
(15, N'Manipur', N'MN', N'Imphal', 225, 76),
(16, N'Meghalaya', N'ML', N'Shillong', 225, 76),
(17, N'Mizoram', N'MZ', N'Aizawl', 225, 76),
(18, N'Nagaland', N'NL', N'Kohima', 225, 76),
(19, N'Odisha', N'OR', N'Bhubaneswar', 225, 76),
(20, N'Punjab', N'PB', N'Chandigarh', 225, 76),
(21, N'Rajasthan', N'RJ', N'Jaipur', 225, 76),
(22, N'Sikkim', N'SK', N'Gangtok', 225, 76),
(23, N'Tamil Nadu', N'TN', N'Chennai', 225, 76),
(24, N'Telangana', N'TG', N'Hyderabad', 225, 76),
(25, N'Tripura', N'TR', N'Agartala', 225, 76),
(26, N'Uttar Pradesh', N'UP', N'Lucknow', 225, 76),
(27, N'Uttarakhand', N'UT', N'Dehradun', 225, 76),
(28, N'West Bengal', N'WB', N'Kolkata', 225, 76),
(29, N'Andaman and Nicobar Islands', N'AN', N'Port Blair', 225, 76),
(30, N'Chandigarh', N'CH', N'Chandigarh', 225, 76),
(31, N'Dadra and Nagar Haveli and Daman and Diu', N'DD', N'Daman', 225, 76),
(32, N'Delhi', N'DL', N'New Delhi', 225, 76),
(33, N'Jammu and Kashmir', N'JK', N'Srinagar', 225, 76),
(34, N'Ladakh', N'LA', N'Leh', 225, 76),
(35, N'Lakshadweep', N'LD', N'Kavaratti', 225, 76),
(36, N'Puducherry', N'PY', N'Pondicherry', 225, 76)
) AS source (id, name, iso_code, capital, timezone_id, country_id)
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET 
        name = source.name,
        iso_code = source.iso_code,
        capital = source.capital,
        timezone_id = source.timezone_id,
        country_id = source.country_id
WHEN NOT MATCHED THEN
    INSERT (id, name, iso_code, capital, timezone_id, country_id)
    VALUES (source.id, source.name, source.iso_code, source.capital, source.timezone_id, source.country_id);
GO

SET IDENTITY_INSERT tblStates OFF;
GO

DBCC CHECKIDENT ('tblStates', RESEED, 36);
GO

PRINT N'tblStates data merged successfully.';
GO

