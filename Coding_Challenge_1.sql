-- 1. Create the database for PetPals
CREATE DATABASE PetPals;

-- Use the PetPals database
USE PetPals;


-- 2. Create tables for pets, shelters, donations, adoption events, and participants
-- Ensure that existing tables do not interfere with the creation of new tables
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Pets')
BEGIN
    CREATE TABLE Pets (
        PetID INT PRIMARY KEY,
        Name VARCHAR(50) NOT NULL,
        Age INT NOT NULL,
        Breed VARCHAR(50) NOT NULL,
        Type VARCHAR(20) NOT NULL,
        AvailableForAdoption BIT NOT NULL,
        OwnerID INT NULL -- To handle pets that may or may not have an owner
    );
END;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Shelters')
BEGIN
    CREATE TABLE Shelters (
        ShelterID INT PRIMARY KEY,
        Name VARCHAR(100) NOT NULL,
        Location VARCHAR(100) NOT NULL
    );
END;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Donations')
BEGIN
    CREATE TABLE Donations (
        DonationID INT PRIMARY KEY,
        DonorName VARCHAR(100) NOT NULL,
        DonationType VARCHAR(50) NOT NULL,
        DonationAmount DECIMAL(10, 2),
        DonationItem VARCHAR(100),
        DonationDate DATETIME NOT NULL
    );
END;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AdoptionEvents')
BEGIN
    CREATE TABLE AdoptionEvents (
        EventID INT PRIMARY KEY,
        EventName VARCHAR(100) NOT NULL,
        EventDate DATETIME NOT NULL,
        Location VARCHAR(100) NOT NULL
    );
END;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Participants')
BEGIN
    CREATE TABLE Participants (
        ParticipantID INT PRIMARY KEY,
        ParticipantName VARCHAR(100) NOT NULL,
        ParticipantType VARCHAR(20) NOT NULL,
        EventID INT,
        FOREIGN KEY (EventID) REFERENCES AdoptionEvents(EventID)
    );
END;

-- 3. Insert sample data into the tables
INSERT INTO Pets (PetID, Name, Age, Breed, Type, AvailableForAdoption) VALUES
(1, 'Buddy', 3, 'Golden Retriever', 'Dog', 1),
(2, 'Mittens', 2, 'Siamese', 'Cat', 1),
(3, 'Charlie', 5, 'Bulldog', 'Dog', 0),
(4, 'Whiskers', 1, 'Persian', 'Cat', 1);

INSERT INTO Shelters (ShelterID, Name, Location) VALUES
(1, 'Happy Tails Shelter', 'Chennai'),
(2, 'Paw Haven', 'Mumbai');

INSERT INTO Donations (DonationID, DonorName, DonationType, DonationAmount, DonationItem, DonationDate) VALUES
(1, 'Alice', 'Cash', 5000.00, NULL, '2023-09-01 10:30:00'),
(2, 'Bob', 'Item', NULL, 'Dog Food', '2023-09-05 14:00:00');

INSERT INTO AdoptionEvents (EventID, EventName, EventDate, Location) VALUES
(1, 'Adopt-a-Pet Day', '2023-10-10 10:00:00', 'Happy Tails Shelter'),
(2, 'Furry Friends Adoption Fair', '2023-11-15 11:00:00', 'Paw Haven');

INSERT INTO Participants (ParticipantID, ParticipantName, ParticipantType, EventID) VALUES
(1, 'Happy Tails Shelter', 'Shelter', 1),
(2, 'John Doe', 'Adopter', 1),
(3, 'Paw Haven', 'Shelter', 2);

-- 5. Query to retrieve a list of available pets
-- Task 5: Retrieve available pets
SELECT Name, Age, Breed, Type 
FROM Pets 
WHERE AvailableForAdoption = 1;

-- 6. Query to retrieve names of participants registered for a specific event
-- Task 6: Retrieve participant names for a specific event
DECLARE @EventID INT = 1; -- Replace with desired EventID
SELECT ParticipantName, ParticipantType 
FROM Participants 
WHERE EventID = @EventID;

-- 7. Stored procedure to update shelter information
-- Task 7: Create stored procedure for updating shelter info
CREATE PROCEDURE UpdateShelter
    @ShelterID INT,
    @NewName NVARCHAR(100),
    @NewLocation NVARCHAR(100)
AS
BEGIN
    -- Update the shelter if it exists
    UPDATE Shelters 
    SET Name = @NewName, Location = @NewLocation 
    WHERE ShelterID = @ShelterID;

    -- Check if any rows were affected
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Error: Shelter ID not found.';
    END
    ELSE
    BEGIN
        PRINT 'Shelter information updated successfully.';
    END
END;

-- Execute the stored procedure as an example
EXEC UpdateShelter @ShelterID = 1, @NewName = 'Happy Paws', @NewLocation = 'New York';

-- 8. Query to calculate total donations by shelter
-- Task 8: Calculate total donations for each shelter
SELECT S.Name AS ShelterName, 
       COALESCE(SUM(D.DonationAmount), 0) AS TotalDonationAmount
FROM Shelters S
LEFT JOIN Donations D ON S.ShelterID = 1 -- Join on ShelterID
GROUP BY S.Name;

-- 9. Query to retrieve pets without an owner
-- Task 9: Retrieve pets without an owner
SELECT Name, Age, Breed, Type 
FROM Pets 
WHERE OwnerID IS NULL;

-- 10. Query to calculate total donations by month and year
-- Task 10: Calculate total donations for each month and year
SELECT FORMAT(DonationDate, 'yyyy-MM') AS MonthYear, 
       SUM(DonationAmount) AS TotalDonationAmount
FROM Donations
GROUP BY FORMAT(DonationDate, 'yyyy-MM');

-- 11. Retrieve distinct breeds of pets aged between 1-3 or older than 5
-- Task 11: Retrieve distinct breeds for certain age groups
SELECT DISTINCT Breed 
FROM Pets 
WHERE (Age BETWEEN 1 AND 3) OR (Age > 5);

-- 12. Retrieve available pets and their shelters
-- Task 12: Retrieve pets available for adoption with shelter names
SELECT P.Name AS PetName, S.Name AS ShelterName 
FROM Pets P 
JOIN Shelters S ON P.OwnerID = S.ShelterID -- Assuming a relationship
WHERE P.AvailableForAdoption = 1;

-- 13. Total participants in events organized by specific city shelters
-- Task 13: Count participants in events organized by specific city shelters
SELECT COUNT(*) AS TotalParticipants 
FROM Participants P 
JOIN Shelters S ON P.EventID = S.ShelterID
WHERE S.Location = 'Chennai';

-- 14. Retrieve unique breeds for pets aged between 1 and 5 years
-- Task 14: Unique breeds for pets aged 1-5 years
SELECT DISTINCT Breed 
FROM Pets 
WHERE Age BETWEEN 1 AND 5;

-- 15. Retrieve pets that have not been adopted
-- Task 15: Retrieve information of pets that have not been adopted
SELECT * 
FROM Pets 
WHERE AvailableForAdoption = 1; 

-- 16. Retrieve adopted pets and their adopters
-- Task 16: Retrieve adopted pets along with adopter names
CREATE TABLE Adoption (
    AdoptionID INT PRIMARY KEY,
    PetID INT,
    AdopterName VARCHAR(100),
    AdoptionDate DATETIME,
    FOREIGN KEY (PetID) REFERENCES Pets(PetID)
);

INSERT INTO Adoption (AdoptionID, PetID, AdopterName, AdoptionDate)
VALUES 
(1, 1, 'John Doe', '2024-09-15'),
(2, 2, 'Alice Smith', '2024-09-20');

SELECT P.Name AS AdoptedPetName, 
       A.AdopterName 
FROM Pets P 
JOIN Adoption A ON P.PetID = A.PetID; 

-- 17. Retrieve shelters along with count of available pets
-- Task 17: List shelters with count of available pets
SELECT S.Name AS ShelterName, 
       COUNT(P.PetID) AS AvailablePetsCount 
FROM Shelters S 
LEFT JOIN Pets P ON S.ShelterID = P.OwnerID AND P.AvailableForAdoption = 1
GROUP BY S.Name;

-- 18. Find pairs of pets from the same shelter with the same breed
-- Task 18: Find pet pairs from the same shelter with same breed
SELECT P1.Name AS Pet1Name, P2.Name AS Pet2Name, S.Name AS ShelterName 
FROM Pets P1 
JOIN Pets P2 ON P1.Breed = P2.Breed AND P1.PetID <> P2.PetID
JOIN Shelters S ON P1.OwnerID = S.ShelterID;

-- 19. List all combinations of shelters and adoption events
-- Task 19: List combinations of shelters and adoption events
SELECT S.Name AS ShelterName, E.EventName AS EventName 
FROM Shelters S, AdoptionEvents E;

-- 20. Determine the shelter with the highest number of adopted pets
-- Task 20: Shelter with highest number of adopted pets
SELECT TOP 1 
    S.Name AS ShelterName, 
    COUNT(A.PetID) AS AdoptedPetsCount
FROM Shelters S 
JOIN Pets P ON S.ShelterID = P.OwnerID  -- Assuming OwnerID references the shelter
JOIN Adoption A ON P.PetID = A.PetID
WHERE P.AvailableForAdoption = 0  -- Ensuring we only count adopted pets
GROUP BY S.Name
ORDER BY AdoptedPetsCount DESC;
