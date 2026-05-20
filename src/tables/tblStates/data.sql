EXEC dbo.usp_ResetAutoIncrement N'tblStates';
GO

INSERT INTO tblStates
(
    name,
    iso_code,
    capital,
    timezone_id,
    country_id
)
VALUES
-- India States and Union Territories (Country ID: 76)
(N'Andhra Pradesh', N'AP', N'Amaravati', 225, 76),
(N'Arunachal Pradesh', N'AR', N'Itanagar', 225, 76),
(N'Assam', N'AS', N'Dispur', 225, 76),
(N'Bihar', N'BR', N'Patna', 225, 76),
(N'Chhattisgarh', N'CG', N'Raipur', 225, 76),
(N'Goa', N'GA', N'Panaji', 225, 76),
(N'Gujarat', N'GJ', N'Gandhinagar', 225, 76),
(N'Haryana', N'HR', N'Chandigarh', 225, 76),
(N'Himachal Pradesh', N'HP', N'Shimla', 225, 76),
(N'Jharkhand', N'JH', N'Ranchi', 225, 76),
(N'Karnataka', N'KA', N'Bengaluru', 225, 76),
(N'Kerala', N'KL', N'Thiruvananthapuram', 225, 76),
(N'Madhya Pradesh', N'MP', N'Bhopal', 225, 76),
(N'Maharashtra', N'MH', N'Mumbai', 225, 76),
(N'Manipur', N'MN', N'Imphal', 225, 76),
(N'Meghalaya', N'ML', N'Shillong', 225, 76),
(N'Mizoram', N'MZ', N'Aizawl', 225, 76),
(N'Nagaland', N'NL', N'Kohima', 225, 76),
(N'Odisha', N'OR', N'Bhubaneswar', 225, 76),
(N'Punjab', N'PB', N'Chandigarh', 225, 76),
(N'Rajasthan', N'RJ', N'Jaipur', 225, 76),
(N'Sikkim', N'SK', N'Gangtok', 225, 76),
(N'Tamil Nadu', N'TN', N'Chennai', 225, 76),
(N'Telangana', N'TG', N'Hyderabad', 225, 76),
(N'Tripura', N'TR', N'Agartala', 225, 76),
(N'Uttar Pradesh', N'UP', N'Lucknow', 225, 76),
(N'Uttarakhand', N'UT', N'Dehradun', 225, 76),
(N'West Bengal', N'WB', N'Kolkata', 225, 76),
(N'Andaman and Nicobar Islands', N'AN', N'Port Blair', 225, 76),
(N'Chandigarh', N'CH', N'Chandigarh', 225, 76),
(N'Dadra and Nagar Haveli and Daman and Diu', N'DD', N'Daman', 225, 76),
(N'Delhi', N'DL', N'New Delhi', 225, 76),
(N'Jammu and Kashmir', N'JK', N'Srinagar', 225, 76),
(N'Ladakh', N'LA', N'Leh', 225, 76),
(N'Lakshadweep', N'LD', N'Kavaratti', 225, 76),
(N'Puducherry', N'PY', N'Pondicherry', 225, 76);

PRINT N'tblStates data inserted successfully.';
GO