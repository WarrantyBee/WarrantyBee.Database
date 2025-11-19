CALL usp_ResetAutoIncrement('tblStates');

INSERT INTO `tblStates`
(
    `name`,
    `iso_code`,
    `capital`,
    `timezone_id`,
    `country_id`
)
VALUES
-- India States and Union Territories (Country ID: 76)
('Andhra Pradesh', 'AP', 'Amaravati', 225, 76),
('Arunachal Pradesh', 'AR', 'Itanagar', 225, 76),
('Assam', 'AS', 'Dispur', 225, 76),
('Bihar', 'BR', 'Patna', 225, 76),
('Chhattisgarh', 'CG', 'Raipur', 225, 76),
('Goa', 'GA', 'Panaji', 225, 76),
('Gujarat', 'GJ', 'Gandhinagar', 225, 76),
('Haryana', 'HR', 'Chandigarh', 225, 76),
('Himachal Pradesh', 'HP', 'Shimla', 225, 76),
('Jharkhand', 'JH', 'Ranchi', 225, 76),
('Karnataka', 'KA', 'Bengaluru', 225, 76),
('Kerala', 'KL', 'Thiruvananthapuram', 225, 76),
('Madhya Pradesh', 'MP', 'Bhopal', 225, 76),
('Maharashtra', 'MH', 'Mumbai', 225, 76),
('Manipur', 'MN', 'Imphal', 225, 76),
('Meghalaya', 'ML', 'Shillong', 225, 76),
('Mizoram', 'MZ', 'Aizawl', 225, 76),
('Nagaland', 'NL', 'Kohima', 225, 76),
('Odisha', 'OR', 'Bhubaneswar', 225, 76),
('Punjab', 'PB', 'Chandigarh', 225, 76),
('Rajasthan', 'RJ', 'Jaipur', 225, 76),
('Sikkim', 'SK', 'Gangtok', 225, 76),
('Tamil Nadu', 'TN', 'Chennai', 225, 76),
('Telangana', 'TG', 'Hyderabad', 225, 76),
('Tripura', 'TR', 'Agartala', 225, 76),
('Uttar Pradesh', 'UP', 'Lucknow', 225, 76),
('Uttarakhand', 'UT', 'Dehradun', 225, 76),
('West Bengal', 'WB', 'Kolkata', 225, 76),
('Andaman and Nicobar Islands', 'AN', 'Port Blair', 225, 76),
('Chandigarh', 'CH', 'Chandigarh', 225, 76),
('Dadra and Nagar Haveli and Daman and Diu', 'DD', 'Daman', 225, 76),
('Delhi', 'DL', 'New Delhi', 225, 76),
('Jammu and Kashmir', 'JK', 'Srinagar', 225, 76),
('Ladakh', 'LA', 'Leh', 225, 76),
('Lakshadweep', 'LD', 'Kavaratti', 225, 76),
('Puducherry', 'PY', 'Pondicherry', 225, 76);

SELECT 'tblStates data inserted successfully.' AS message;