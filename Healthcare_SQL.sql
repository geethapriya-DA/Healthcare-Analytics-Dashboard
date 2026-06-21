create database healthcare;
use healthcare;


 ### create table
-- =========================================
-- DEPARTMENT TABLE
-- =========================================
CREATE TABLE Department ( 
DepartmentID INT PRIMARY KEY, 
DepartmentName VARCHAR(100), 
SpecialtyCovered VARCHAR(100), 
Location VARCHAR(100), 
DepartmentType VARCHAR(50) 
);

-- =========================================
-- DOCTOR TABLE
-- =========================================

CREATE TABLE Doctor (
    DoctorID INT PRIMARY KEY,
    DoctorName VARCHAR(100),
    Gender VARCHAR(20),
    Specialty VARCHAR(100),
    DepartmentID INT,
    YearsOfExperience INT,
    HospitalAffiliation VARCHAR(150),
    ClinicName VARCHAR(150),
    PhoneNumber VARCHAR(50),
    Email VARCHAR(100),
    LicenseNumber VARCHAR(50),
    IsActive VARCHAR(10),

    FOREIGN KEY (DepartmentID)
    REFERENCES Department(DepartmentID)
);

-- =========================================
-- PATIENT TABLE
-- =========================================

CREATE TABLE Patient (
    PatientID INT PRIMARY KEY,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Gender VARCHAR(20),
    DateOfBirth DATE,
    Age INT,
    BloodType VARCHAR(10),
    PhoneNumber VARCHAR(50),
    AlternatePhoneNumber VARCHAR(50),
    Address TEXT,
    State VARCHAR(100),
    City VARCHAR(100),
    Country VARCHAR(100),
    InsuranceProvider VARCHAR(150),
    PolicyNumber VARCHAR(100),
    MaritalStatus VARCHAR(50),
    Race VARCHAR(50),
    Ethnicity VARCHAR(50),
    ChronicConditions VARCHAR(255),
    Allergies VARCHAR(255),
    MedicalHistory TEXT,
    PatientStatus VARCHAR(50),
    RegistrationDate DATE,
    EmergencyContactName VARCHAR(100),
    EmergencyContactPhone VARCHAR(50)
);

-- =========================================
-- VISIT TABLE
-- =========================================

CREATE TABLE Visit (
    VisitID INT PRIMARY KEY,
    PatientID INT,
    DoctorID INT,
    VisitDate DATE,
    VisitYear INT,
    VisitMonth INT,
    VisitMonthName VARCHAR(20),
    VisitQuarter INT,
    VisitType VARCHAR(50),
    VisitStatus VARCHAR(50),
    Diagnosis VARCHAR(100),
    DiagnosisCode VARCHAR(50),
    ReasonForVisit VARCHAR(100),
    FollowUpRequired VARCHAR(10),
    PrescribedMedications VARCHAR(255),
    VisitDurationMins INT,

    FOREIGN KEY (PatientID)
    REFERENCES Patient(PatientID),

    FOREIGN KEY (DoctorID)
    REFERENCES Doctor(DoctorID)
);

-- =========================================
-- TREATMENT TABLE
-- =========================================

CREATE TABLE Treatment (
    TreatmentID INT PRIMARY KEY,
    VisitID INT,
    TreatmentType VARCHAR(100),
    TreatmentName VARCHAR(150),
    MedicationPrescribed VARCHAR(100),
    Dosage VARCHAR(50),
    Instructions TEXT,
    TreatmentStartDate DATE,
    TreatmentEndDate DATE,
    DurationDays INT,
    Status VARCHAR(50),
    Outcome VARCHAR(50),
    DirectTreatmentCost DECIMAL(10,2),
    TotalEpisodeCost DECIMAL(10,2),
    TreatmentDescription TEXT,

    FOREIGN KEY (VisitID)
    REFERENCES Visit(VisitID)
);

-- =========================================
-- LAB TEST TABLE
-- =========================================

CREATE TABLE LabTest (
    LabResultID INT PRIMARY KEY,
    VisitID INT,
    OrderedByDoctorID INT,
    TestName VARCHAR(100),
    TestDate DATE,
    TestYear INT,
    TestMonth INT,
    TestMonthName VARCHAR(20),
    TestResult VARCHAR(50),
    NumericResultValue DECIMAL(10,2),
    Units VARCHAR(50),
    ReferenceRange VARCHAR(100),
    Comments TEXT,

    FOREIGN KEY (VisitID)
    REFERENCES Visit(VisitID),

    FOREIGN KEY (OrderedByDoctorID)
    REFERENCES Doctor(DoctorID)
);

-- =========================================
-- BILLING TABLE
-- =========================================

CREATE TABLE Billing (
    BillID INT PRIMARY KEY,
    VisitID INT,
    PatientID INT,
    AmountBilled DECIMAL(10,2),
    InsuranceCovered DECIMAL(10,2),
    PatientPaid DECIMAL(10,2),
    Outstanding DECIMAL(10,2),
    PaymentStatus VARCHAR(50),
    BillDate DATE,
    PaymentDate DATE
);


SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

### load data in tables

-- =====================
-- 2. DOCTOR (needs Department)
-- =====================
LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Doctors.csv'
INTO TABLE Doctor
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'secure_file_priv';



-- =====================
-- 3. PATIENT (no dependencies)
-- =====================
LOAD DATA LOCAL INFILE 'C:/temp/Patient.csv'
INTO TABLE Patient
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@PatientID, @FirstName, @LastName, @Gender,
@DateOfBirth, @Age, @BloodType, @PhoneNumber,
@AlternatePhoneNumber, @Address, @State, @City,
@Country, @InsuranceProvider, @PolicyNumber,
@MaritalStatus, @Race, @Ethnicity,
@ChronicConditions, @Allergies, @MedicalHistory,
@PatientStatus, @RegistrationDate,
@EmergencyContactName, @EmergencyContactPhone)
SET
PatientID = @PatientID,
FirstName = @FirstName,
LastName = @LastName,
Gender = @Gender,
DateOfBirth = STR_TO_DATE(NULLIF(@DateOfBirth,''), '%m/%d/%Y'),
Age = @Age,
BloodType = @BloodType,
PhoneNumber = @PhoneNumber,
AlternatePhoneNumber = @AlternatePhoneNumber,
Address = @Address,
State = @State,
City = @City,
Country = @Country,
InsuranceProvider = @InsuranceProvider,
PolicyNumber = @PolicyNumber,
MaritalStatus = @MaritalStatus,
Race = @Race,
Ethnicity = @Ethnicity,
ChronicConditions = @ChronicConditions,
Allergies = @Allergies,
MedicalHistory = @MedicalHistory,
PatientStatus = @PatientStatus,
RegistrationDate = STR_TO_DATE(NULLIF(@RegistrationDate,''), '%m/%d/%Y'),
EmergencyContactName = @EmergencyContactName,
EmergencyContactPhone = @EmergencyContactPhone;

-- Select * from Patient;
SELECT COUNT(*) FROM Patient;

-- =====================
-- 4. VISIT (needs Patient + Doctor)
-- =====================
LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Visit.csv'
INTO TABLE Visit
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@VisitID, @PatientID, @DoctorID, @VisitDate,
@VisitYear, @VisitMonth, @VisitMonthName,
@VisitQuarter, @VisitType, @VisitStatus,
@Diagnosis, @DiagnosisCode, @ReasonForVisit,
@FollowUpRequired, @PrescribedMedications,
@VisitDurationMins)
SET
VisitID = @VisitID,
PatientID = @PatientID,
DoctorID = @DoctorID,
VisitDate = STR_TO_DATE(NULLIF(@VisitDate,''), '%m/%d/%Y'),
VisitYear = @VisitYear,
VisitMonth = @VisitMonth,
VisitMonthName = @VisitMonthName,
VisitQuarter = @VisitQuarter,
VisitType = @VisitType,
VisitStatus = @VisitStatus,
Diagnosis = @Diagnosis,
DiagnosisCode = @DiagnosisCode,
ReasonForVisit = @ReasonForVisit,
FollowUpRequired = @FollowUpRequired,
PrescribedMedications = @PrescribedMedications,
VisitDurationMins = @VisitDurationMins;

-- Select * from Visit;
-- =====================
-- 5. TREATMENT (needs Visit)
-- =====================
LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Treatment.csv'
INTO TABLE Treatment
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@TreatmentID, @VisitID, @TreatmentType,
@TreatmentName, @MedicationPrescribed, @Dosage,
@Instructions, @TreatmentStartDate,
@TreatmentEndDate, @DurationDays, @Status,
@Outcome, @DirectTreatmentCost,
@TotalEpisodeCost, @TreatmentDescription)
SET
TreatmentID = @TreatmentID,
VisitID = @VisitID,
TreatmentType = @TreatmentType,
TreatmentName = @TreatmentName,
MedicationPrescribed = @MedicationPrescribed,
Dosage = @Dosage,
Instructions = @Instructions,
TreatmentStartDate = STR_TO_DATE(NULLIF(@TreatmentStartDate,''), '%m/%d/%Y'),
TreatmentEndDate = STR_TO_DATE(NULLIF(@TreatmentEndDate,''), '%m/%d/%Y'),
DurationDays = @DurationDays,
Status = @Status,
Outcome = @Outcome,
DirectTreatmentCost = @DirectTreatmentCost,
TotalEpisodeCost = @TotalEpisodeCost,
TreatmentDescription = @TreatmentDescription;

-- =====================
-- 6. LABTEST (needs Visit + Doctor)
-- =====================
LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LabTest.csv'
INTO TABLE LabTest
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@LabResultID, @VisitID, @OrderedByDoctorID,
@TestName, @TestDate, @TestYear, @TestMonth,
@TestMonthName, @TestResult, @NumericResultValue,
@Units, @ReferenceRange, @Comments)
SET
LabResultID = @LabResultID,
VisitID = @VisitID,
OrderedByDoctorID = @OrderedByDoctorID,
TestName = @TestName,
TestDate = STR_TO_DATE(NULLIF(@TestDate,''), '%m/%d/%Y'),
TestYear = @TestYear,
TestMonth = @TestMonth,
TestMonthName = @TestMonthName,
TestResult = @TestResult,
NumericResultValue = NULLIF(@NumericResultValue,''),
Units = @Units,
ReferenceRange = @ReferenceRange,
Comments = @Comments;

-- =====================
-- 7. BILLING (needs Visit + Patient)
-- =====================
LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Billing.csv'
INTO TABLE Billing
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@BillID, @VisitID, @PatientID, @AmountBilled,
@InsuranceCovered, @PatientPaid, @Outstanding,
@PaymentStatus, @BillDate, @PaymentDate)
SET
BillID = @BillID,
VisitID = @VisitID,
PatientID = @PatientID,
AmountBilled = @AmountBilled,
InsuranceCovered = @InsuranceCovered,
PatientPaid = @PatientPaid,
Outstanding = @Outstanding,
PaymentStatus = @PaymentStatus,
BillDate = STR_TO_DATE(NULLIF(@BillDate,''), '%m/%d/%Y'),
PaymentDate = STR_TO_DATE(NULLIF(@PaymentDate,''), '%m/%d/%Y');


SELECT 'Department' AS Table_Name, COUNT(*) AS Records FROM Department
UNION ALL
SELECT 'Doctor', COUNT(*) FROM Doctor
UNION ALL
SELECT 'Patient', COUNT(*) FROM Patient
UNION ALL
SELECT 'Visit', COUNT(*) FROM Visit
UNION ALL
SELECT 'Treatment', COUNT(*) FROM Treatment
UNION ALL
SELECT 'LabTest', COUNT(*) FROM LabTest
UNION ALL
SELECT 'Billing', COUNT(*) FROM Billing;
-------------------------------------------------------------------------------------------------------------------------------------
## EDITING THINGS TO MATCH QUERIES OF PROECT


-- Rename Treatment to Treatments
RENAME TABLE Treatment TO Treatments;

-- Rename LabTest to LabResult
RENAME TABLE LabTest TO LabResult;

-- Rename TestResult to Result in LabResult table
ALTER TABLE LabResult 
RENAME COLUMN TestResult TO Result;

-- Rename DirectTreatmentCost to TreatmentCost in Treatments table
ALTER TABLE Treatments 
RENAME COLUMN DirectTreatmentCost TO TreatmentCost;

-- To see chanages
SHOW TABLES;       
DESCRIBE Treatments;
DESCRIBE LabResult;


---------------------------------------------------------------------------------------------------------------------------------------


-- QA Queries
/* 1. Data Count Validation
Ensure record counts match between the database and Power BI reports. */


SELECT COUNT(*) as 'Total Patient' FROM Patient;
Select count(*) as 'Total Doctor' from doctor;
SELECT COUNT(*) as 'Total Visit' FROM Visit;
SELECT COUNT(*)  as 'Total Traetments' FROM Treatments;       
SELECT COUNT(*)  as 'Total Result' FROM LabResult;          








/* 2. Data Completeness Check
Identify missing or null values in key columns. */

SELECT * FROM Patient WHERE FirstName IS NULL OR LastName IS NULL;
SELECT * FROM Visit WHERE VisitType IS NULL OR VisitDate IS NULL;
SELECT * FROM Treatments WHERE TreatmentName IS NULL OR Status IS NULL;
SELECT * FROM LabResult WHERE TestName IS NULL OR Result IS NULL;

/* 3. Data Consistency Check
Ensure data relationships are consistent across tables. */

SELECT v.VisitID, v.PatientID, p.PatientID
FROM Visit v
LEFT JOIN Patient p ON v.PatientID = p.PatientID
WHERE p.PatientID IS NULL;  -- Should return 0 rows

SELECT t.TreatmentID, t.VisitID, v.VisitID
FROM Treatments t
LEFT JOIN Visit v ON t.VisitID = v.VisitID
WHERE v.VisitID IS NULL;  -- Should return 0 rows

/* 4. Duplicate Records Check
Identify duplicate entries in key tables. */

SELECT PatientID, COUNT(*)
FROM Patient
GROUP BY PatientID
HAVING COUNT(*) > 1;

SELECT VisitID, COUNT(*)
FROM Visit
GROUP BY VisitID
HAVING COUNT(*) > 1;



/* 5. Dashboard Aggregation Check
Compare sum or average values between SQL and Power BI. */

SELECT SUM(TreatmentCost) FROM Treatments;  -- Compare with Power BI total cost
SELECT AVG(Age) FROM Patient;  -- Compare with Power BI average age

/* 6. Performance Testing (Query Execution Time)
Check query performance and optimize if needed.
EXPLAIN ANALYZE */

SELECT * FROM Visit WHERE VisitDate BETWEEN '2023-01-01' AND '2023-12-31';

select * from department;

SELECT
    SUM(CASE
            WHEN Result = 'Abnormal'
            THEN 1
            ELSE 0
        END) AS Abnormal_Patients,
    ROUND(
        SUM(CASE
                WHEN Result = 'Abnormal'
                THEN 1
                ELSE 0
            END) * 100.0 / COUNT(*),
        2
    ) AS Abnormal_Rate_Percentage
FROM labresult;






-----------------------------------------------------------------------------------------------------
-- Monthly /Yearly visit count
SELECT
    DATE_FORMAT(VisitDate, '%M %Y') AS Month_Year,
    COUNT(VisitID) AS Total_Visits
FROM Visit
GROUP BY
    YEAR(VisitDate),
    MONTH(VisitDate),
    DATE_FORMAT(VisitDate, '%M %Y')
ORDER BY
    YEAR(VisitDate),
    MONTH(VisitDate);
    
    ----------------------------------------------------------------------------------
    
    
    
    
    
    
-- State wise visit
SELECT
    p.State,
    COUNT(v.VisitID) AS Total_Visits
FROM Patient p
JOIN Visit v
    ON p.PatientID = v.PatientID
GROUP BY p.State
ORDER BY Total_Visits DESC;




