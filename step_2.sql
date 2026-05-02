-- Author: Yasaman Saatsaz

-- ==========================================
-- STEP 2: Normalizing the Preliminary table
-- ==========================================

-- prevent timeout for large inserts
SET statement_timeout = 0;

-- ========================================================
-- DROP TABLES (TO AVOID PREXISTING TABLES WHEN RERUNNING)
-- ========================================================
DROP TABLE IF EXISTS Application CASCADE;
DROP TABLE IF EXISTS Preliminary CASCADE;

DROP TABLE IF EXISTS Agency CASCADE;
DROP TABLE IF EXISTS LoanType CASCADE;
DROP TABLE IF EXISTS PropertyType CASCADE;
DROP TABLE IF EXISTS LoanPurpose CASCADE;
DROP TABLE IF EXISTS OwnerOccupancy CASCADE;
DROP TABLE IF EXISTS Preapproval CASCADE;
DROP TABLE IF EXISTS ActionTaken CASCADE;
DROP TABLE IF EXISTS MSAMD CASCADE;
DROP TABLE IF EXISTS State CASCADE;
DROP TABLE IF EXISTS County CASCADE;
DROP TABLE IF EXISTS ApplicantEthnicity CASCADE;
DROP TABLE IF EXISTS CoApplicantEthnicity CASCADE;
DROP TABLE IF EXISTS Sex CASCADE;
DROP TABLE IF EXISTS CoApplicantSex CASCADE;
DROP TABLE IF EXISTS PurchaserType CASCADE;
DROP TABLE IF EXISTS DenialReason CASCADE;
DROP TABLE IF EXISTS HOEPAStatus CASCADE;
DROP TABLE IF EXISTS LienStatus CASCADE;
DROP TABLE IF EXISTS EditStatus CASCADE;


-- =========================
-- CREATE PRELIMINARY TABLE
-- Reuse the code from preliminary.sql (from project 0) to transform the CSV into a SQL table
-- =========================
CREATE TABLE Preliminary (
    as_of_year TEXT,
    respondent_id TEXT,
    agency_name TEXT,
    agency_abbr TEXT,
    agency_code TEXT,
    loan_type_name TEXT,
    loan_type TEXT,
    property_type_name TEXT,
    property_type TEXT,
    loan_purpose_name TEXT,
    loan_purpose TEXT,
    owner_occupancy_name TEXT,
    owner_occupancy TEXT,
    loan_amount_000s TEXT,
    preapproval_name TEXT,
    preapproval TEXT,
    action_taken_name TEXT,
    action_taken TEXT,
    msamd_name TEXT,
    msamd TEXT,
    state_name TEXT,
    state_abbr TEXT,
    state_code TEXT,
    county_name TEXT,
    county_code TEXT,
    census_tract_number TEXT,
    applicant_ethnicity_name TEXT,
    applicant_ethnicity TEXT,
    co_applicant_ethnicity_name TEXT,
    co_applicant_ethnicity TEXT,
    applicant_race_name_1 TEXT,
    applicant_race_1 TEXT,
    applicant_race_name_2 TEXT,
    applicant_race_2 TEXT,
    applicant_race_name_3 TEXT,
    applicant_race_3 TEXT,
    applicant_race_name_4 TEXT,
    applicant_race_4 TEXT,
    applicant_race_name_5 TEXT,
    applicant_race_5 TEXT,
    co_applicant_race_name_1 TEXT,
    co_applicant_race_1 TEXT,
    co_applicant_race_name_2 TEXT,
    co_applicant_race_2 TEXT,
    co_applicant_race_name_3 TEXT,
    co_applicant_race_3 TEXT,
    co_applicant_race_name_4 TEXT,
    co_applicant_race_4 TEXT,
    co_applicant_race_name_5 TEXT,
    co_applicant_race_5 TEXT,
    applicant_sex_name TEXT,
    applicant_sex TEXT,
    co_applicant_sex_name TEXT,
    co_applicant_sex TEXT,
    applicant_income_000s TEXT,
    purchaser_type_name TEXT,
    purchaser_type TEXT,
    denial_reason_name_1 TEXT,
    denial_reason_1 TEXT,
    denial_reason_name_2 TEXT,
    denial_reason_2 TEXT,
    denial_reason_name_3 TEXT,
    denial_reason_3 TEXT,
    rate_spread TEXT,
    hoepa_status_name TEXT,
    hoepa_status TEXT,
    lien_status_name TEXT,
    lien_status TEXT,
    edit_status_name TEXT,
    edit_status TEXT,
    sequence_number TEXT,
    population TEXT,
    minority_population TEXT,
    hud_median_family_income TEXT,
    tract_to_msamd_income TEXT,
    number_of_owner_occupied_units TEXT,
    number_of_1_to_4_family_units TEXT,
    application_date_indicator TEXT
);

\copy Preliminary FROM '/common/home/egp59/Desktop/336sp26/project2/nj_hmda_2017.csv' CSV HEADER;

ALTER TABLE Preliminary ADD COLUMN ID SERIAL PRIMARY KEY;


-- =================================
-- CLEAN UP THE DATA IN PRELIMINARY
-- Replace empty string values with NULL values
-- =================================

UPDATE Preliminary SET
    agency_code = NULLIF(agency_code, ''),
    loan_type = NULLIF(loan_type, ''),
    property_type = NULLIF(property_type, ''),
    loan_purpose = NULLIF(loan_purpose, ''),
    owner_occupancy = NULLIF(owner_occupancy, ''),
    loan_amount_000s = NULLIF(loan_amount_000s, ''),
    preapproval = NULLIF(preapproval, ''),
    action_taken = NULLIF(action_taken, ''),
    msamd = NULLIF(msamd, ''),
    state_code = NULLIF(state_code, ''),
    county_code = NULLIF(county_code, ''),
    census_tract_number = NULLIF(census_tract_number, ''),
    applicant_ethnicity = NULLIF(applicant_ethnicity, ''),
    co_applicant_ethnicity = NULLIF(co_applicant_ethnicity, ''),
    applicant_race_1 = NULLIF(applicant_race_1, ''),
    applicant_race_2 = NULLIF(applicant_race_2, ''),
    applicant_race_3 = NULLIF(applicant_race_3, ''),
    applicant_race_4 = NULLIF(applicant_race_4, ''),
    applicant_race_5 = NULLIF(applicant_race_5, ''),
    co_applicant_race_1 = NULLIF(co_applicant_race_1, ''),
    co_applicant_race_2 = NULLIF(co_applicant_race_2, ''),
    co_applicant_race_3 = NULLIF(co_applicant_race_3, ''),
    co_applicant_race_4 = NULLIF(co_applicant_race_4, ''),
    co_applicant_race_5 = NULLIF(co_applicant_race_5, ''),
    applicant_sex = NULLIF(applicant_sex, ''),
    co_applicant_sex = NULLIF(co_applicant_sex, ''),
    applicant_income_000s = NULLIF(applicant_income_000s, ''),
    purchaser_type = NULLIF(purchaser_type, ''),
    denial_reason_1 = NULLIF(denial_reason_1, ''),
    denial_reason_2 = NULLIF(denial_reason_2, ''),
    denial_reason_3 = NULLIF(denial_reason_3, ''),
    rate_spread = NULLIF(rate_spread, ''),
    hoepa_status = NULLIF(hoepa_status, ''),
    lien_status = NULLIF(lien_status, ''),
    edit_status = NULLIF(edit_status, ''),
    sequence_number = NULLIF(sequence_number, ''),
    population = NULLIF(population, ''),
    minority_population = NULLIF(minority_population, ''),
    hud_median_family_income = NULLIF(hud_median_family_income, ''),
    tract_to_msamd_income = NULLIF(tract_to_msamd_income, ''),
    number_of_owner_occupied_units = NULLIF(number_of_owner_occupied_units, ''),
    number_of_1_to_4_family_units = NULLIF(number_of_1_to_4_family_units, ''),
    application_date_indicator = NULLIF(application_date_indicator, '');


-- ===========================================
-- LOOKUP TABLES (FOR FUNCTIONAL DEPENDENCIES)
-- ===========================================

-- lookup table for the agency
CREATE TABLE Agency (
    agency_code SMALLINT PRIMARY KEY,
    agency_name TEXT,
    agency_abbr TEXT
);

INSERT INTO Agency
SELECT DISTINCT agency_code::SMALLINT, agency_name, agency_abbr
FROM Preliminary WHERE agency_code IS NOT NULL;


-- lookup table for the type of loan
CREATE TABLE LoanType (
    loan_type SMALLINT PRIMARY KEY,
    loan_type_name TEXT
);

INSERT INTO LoanType
SELECT DISTINCT loan_type::SMALLINT, loan_type_name
FROM Preliminary WHERE loan_type IS NOT NULL;


-- lookup table for the type of property
CREATE TABLE PropertyType (
    property_type SMALLINT PRIMARY KEY,
    property_type_name TEXT
);

INSERT INTO PropertyType
SELECT DISTINCT property_type::SMALLINT, property_type_name
FROM Preliminary WHERE property_type IS NOT NULL;


-- lookup table for the loan's purpose
CREATE TABLE LoanPurpose (
    loan_purpose SMALLINT PRIMARY KEY,
    loan_purpose_name TEXT
);

INSERT INTO LoanPurpose
SELECT DISTINCT loan_purpose::SMALLINT, loan_purpose_name
FROM Preliminary WHERE loan_purpose IS NOT NULL;


-- lookup table for the owner occupancy
CREATE TABLE OwnerOccupancy (
    owner_occupancy SMALLINT PRIMARY KEY,
    owner_occupancy_name TEXT
);

INSERT INTO OwnerOccupancy
SELECT DISTINCT owner_occupancy::SMALLINT, owner_occupancy_name
FROM Preliminary WHERE owner_occupancy IS NOT NULL;


-- lookup table for the preapproval
CREATE TABLE Preapproval (
    preapproval SMALLINT PRIMARY KEY,
    preapproval_name TEXT
);

INSERT INTO Preapproval
SELECT DISTINCT preapproval::SMALLINT, preapproval_name
FROM Preliminary WHERE preapproval IS NOT NULL;


-- lookup table for the specific action taken
CREATE TABLE ActionTaken (
    action_taken SMALLINT PRIMARY KEY,
    action_taken_name TEXT
);

INSERT INTO ActionTaken
SELECT DISTINCT action_taken::SMALLINT, action_taken_name
FROM Preliminary WHERE action_taken IS NOT NULL;


-- lookup table for the MSAMD
CREATE TABLE MSAMD (
    msamd INT PRIMARY KEY,
    msamd_name TEXT
);

INSERT INTO MSAMD
SELECT DISTINCT msamd::INT, msamd_name
FROM Preliminary WHERE msamd IS NOT NULL;


-- lookup table for the specific state
CREATE TABLE State (
    state_code SMALLINT PRIMARY KEY,
    state_name TEXT,
    state_abbr TEXT
);

INSERT INTO State
SELECT DISTINCT state_code::SMALLINT, state_name, state_abbr
FROM Preliminary WHERE state_code IS NOT NULL;


-- lookup table for the specific county
CREATE TABLE County (
    county_code INT PRIMARY KEY,
    county_name TEXT
);

INSERT INTO County
SELECT DISTINCT county_code::INT, county_name
FROM Preliminary WHERE county_code IS NOT NULL;


-- lookup table for the applicant's ethnicity
CREATE TABLE ApplicantEthnicity (
    applicant_ethnicity SMALLINT PRIMARY KEY,
    applicant_ethnicity_name TEXT
);

INSERT INTO ApplicantEthnicity
SELECT DISTINCT applicant_ethnicity::SMALLINT, applicant_ethnicity_name
FROM Preliminary WHERE applicant_ethnicity IS NOT NULL;


-- lookup table for the co-applicant's ethnicity
CREATE TABLE CoApplicantEthnicity (
    co_applicant_ethnicity SMALLINT PRIMARY KEY,
    co_applicant_ethnicity_name TEXT
);

INSERT INTO CoApplicantEthnicity
SELECT DISTINCT co_applicant_ethnicity::SMALLINT, co_applicant_ethnicity_name
FROM Preliminary WHERE co_applicant_ethnicity IS NOT NULL;


-- lookup table for the applicant's sex
CREATE TABLE Sex (
    sex SMALLINT PRIMARY KEY,
    sex_name TEXT
);

INSERT INTO Sex
SELECT DISTINCT applicant_sex::SMALLINT, applicant_sex_name
FROM Preliminary WHERE applicant_sex IS NOT NULL;


-- lookup table for the co-applicant's sex
CREATE TABLE CoApplicantSex (
    co_applicant_sex SMALLINT PRIMARY KEY,
    co_applicant_sex_name TEXT
);

INSERT INTO CoApplicantSex
SELECT DISTINCT co_applicant_sex::SMALLINT, co_applicant_sex_name
FROM Preliminary WHERE co_applicant_sex IS NOT NULL;


-- lookup table for the type of purchaser
CREATE TABLE PurchaserType (
    purchaser_type SMALLINT PRIMARY KEY,
    purchaser_type_name TEXT
);

INSERT INTO PurchaserType
SELECT DISTINCT purchaser_type::SMALLINT, purchaser_type_name
FROM Preliminary WHERE purchaser_type IS NOT NULL;


-- lookup table for the reason for denial
CREATE TABLE DenialReason (
    denial_reason SMALLINT PRIMARY KEY,
    denial_reason_name TEXT
);

INSERT INTO DenialReason
SELECT DISTINCT denial_reason_1::SMALLINT, denial_reason_name_1
FROM Preliminary WHERE denial_reason_1 IS NOT NULL
UNION
SELECT DISTINCT denial_reason_2::SMALLINT, denial_reason_name_2
FROM Preliminary WHERE denial_reason_2 IS NOT NULL
UNION
SELECT DISTINCT denial_reason_3::SMALLINT, denial_reason_name_3
FROM Preliminary WHERE denial_reason_3 IS NOT NULL;


-- lookup table for HOEPA status
CREATE TABLE HOEPAStatus (
    hoepa_status SMALLINT PRIMARY KEY,
    hoepa_status_name TEXT
);

INSERT INTO HOEPAStatus
SELECT DISTINCT hoepa_status::SMALLINT, hoepa_status_name
FROM Preliminary WHERE hoepa_status IS NOT NULL;


-- lookup tale for lien status
CREATE TABLE LienStatus (
    lien_status SMALLINT PRIMARY KEY,
    lien_status_name TEXT
);

INSERT INTO LienStatus
SELECT DISTINCT lien_status::SMALLINT, lien_status_name
FROM Preliminary WHERE lien_status IS NOT NULL;


-- lookup table for edit status (edit state has empty values -- NULL-ONLY)
CREATE TABLE EditStatus (
    edit_status SMALLINT PRIMARY KEY,
    edit_status_name TEXT
);

INSERT INTO EditStatus VALUES (0, 'No Data');


-- =========================
-- MAIN APPLICATION TABLE
-- =========================
CREATE TABLE Application (
    id INT PRIMARY KEY,
    as_of_year SMALLINT,
    respondent_id TEXT,
    agency_code SMALLINT REFERENCES Agency,
    loan_type SMALLINT REFERENCES LoanType,
    property_type SMALLINT REFERENCES PropertyType,
    loan_purpose SMALLINT,
    owner_occupancy SMALLINT,
    loan_amount_000s INT,
    preapproval SMALLINT,
    action_taken SMALLINT,
    msamd INT,
    state_code SMALLINT,
    county_code INT,
    census_tract_number NUMERIC,
    applicant_ethnicity SMALLINT,
    co_applicant_ethnicity SMALLINT,
    applicant_sex SMALLINT,
    co_applicant_sex SMALLINT,
    applicant_income_000s INT,
    purchaser_type SMALLINT,
    denial_reason_1 SMALLINT,
    denial_reason_2 SMALLINT,
    denial_reason_3 SMALLINT,
    rate_spread NUMERIC,
    hoepa_status SMALLINT,
    lien_status SMALLINT,
    edit_status SMALLINT,
    sequence_number INT,
    population INT,
    minority_population NUMERIC,
    hud_median_family_income INT,
    tract_to_msamd_income NUMERIC,
    number_of_owner_occupied_units INT,
    number_of_1_to_4_family_units INT,
    application_date_indicator SMALLINT
);


-- =============================
-- INSERT DATA INTO APPLICATION
-- cast the data based on their data type
-- =============================
INSERT INTO Application
SELECT
    id,
    as_of_year::SMALLINT,
    respondent_id,
    agency_code::SMALLINT,
    loan_type::SMALLINT,
    property_type::SMALLINT,
    loan_purpose::SMALLINT,
    owner_occupancy::SMALLINT,
    loan_amount_000s::INT,
    preapproval::SMALLINT,
    action_taken::SMALLINT,
    msamd::INT,
    state_code::SMALLINT,
    county_code::INT,
    census_tract_number::NUMERIC,
    applicant_ethnicity::SMALLINT,
    co_applicant_ethnicity::SMALLINT,
    applicant_sex::SMALLINT,
    co_applicant_sex::SMALLINT,
    applicant_income_000s::INT,
    purchaser_type::SMALLINT,
    denial_reason_1::SMALLINT,
    denial_reason_2::SMALLINT,
    denial_reason_3::SMALLINT,
    rate_spread::NUMERIC,
    hoepa_status::SMALLINT,
    lien_status::SMALLINT,
    edit_status::SMALLINT,
    sequence_number::INT,
    population::INT,
    minority_population::NUMERIC,
    hud_median_family_income::INT,
    tract_to_msamd_income::NUMERIC,
    number_of_owner_occupied_units::INT,
    number_of_1_to_4_family_units::INT,
    application_date_indicator::SMALLINT
FROM Preliminary;
