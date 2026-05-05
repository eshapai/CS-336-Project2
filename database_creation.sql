-- Author: Yasaman Saatsaz
-- step_2.sql
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

-- step_3.sql


-- =================================
-- STEP 3: Normalization to 3NF
-- =================================

-- prevent timeout for large inserts
SET statement_timeout = 0;

-- ==========================
-- DROP TABLES
-- avoids "existing table" errors for reruns, order matters for foreign keys
-- ==========================
DROP TABLE IF EXISTS ApplicantRace CASCADE;
DROP TABLE IF EXISTS CoApplicantRace CASCADE;
DROP TABLE IF EXISTS DenialReasonLink CASCADE;
DROP TABLE IF EXISTS Location CASCADE;
DROP TABLE IF EXISTS Race CASCADE;


-- =======================
-- RACE LOOKUP TABLE
-- shared code set for both applicant and co-applicant races
-- needed to recover race names when regenerating the CSV in Step 4
-- =======================
CREATE TABLE Race (
    race SMALLINT PRIMARY KEY,
    race_name TEXT
);

INSERT INTO Race
SELECT DISTINCT applicant_race_1::SMALLINT, applicant_race_name_1
FROM Preliminary WHERE applicant_race_1 IS NOT NULL
UNION
SELECT DISTINCT applicant_race_2::SMALLINT, applicant_race_name_2
FROM Preliminary WHERE applicant_race_2 IS NOT NULL
UNION
SELECT DISTINCT applicant_race_3::SMALLINT, applicant_race_name_3
FROM Preliminary WHERE applicant_race_3 IS NOT NULL
UNION
SELECT DISTINCT applicant_race_4::SMALLINT, applicant_race_name_4
FROM Preliminary WHERE applicant_race_4 IS NOT NULL
UNION
SELECT DISTINCT applicant_race_5::SMALLINT, applicant_race_name_5
FROM Preliminary WHERE applicant_race_5 IS NOT NULL
UNION
SELECT DISTINCT co_applicant_race_1::SMALLINT, co_applicant_race_name_1
FROM Preliminary WHERE co_applicant_race_1 IS NOT NULL
UNION
SELECT DISTINCT co_applicant_race_2::SMALLINT, co_applicant_race_name_2
FROM Preliminary WHERE co_applicant_race_2 IS NOT NULL
UNION
SELECT DISTINCT co_applicant_race_3::SMALLINT, co_applicant_race_name_3
FROM Preliminary WHERE co_applicant_race_3 IS NOT NULL
UNION
SELECT DISTINCT co_applicant_race_4::SMALLINT, co_applicant_race_name_4
FROM Preliminary WHERE co_applicant_race_4 IS NOT NULL
UNION
SELECT DISTINCT co_applicant_race_5::SMALLINT, co_applicant_race_name_5
FROM Preliminary WHERE co_applicant_race_5 IS NOT NULL;


-- =======================
-- LOCATION TABLE
-- location table needs a serial primary key per instructions
-- Changed: added foreign keys to MSAMD, State, County
-- =======================
CREATE TABLE Location (
    location_id SERIAL PRIMARY KEY,
    msamd INT REFERENCES MSAMD(msamd),
    state_code SMALLINT REFERENCES State(state_code),
    county_code INT REFERENCES County(county_code),
    census_tract_number NUMERIC,
    population INT,
    minority_population NUMERIC,
    hud_median_family_income INT,
    tract_to_msamd_income NUMERIC,
    number_of_owner_occupied_units INT,
    number_of_1_to_4_family_units INT
);

-- Changed: replaced UNIQUE constraint with COALESCE unique index
-- PostgreSQL UNIQUE treats NULLs as distinct, so plain UNIQUE allows duplicate null rows
CREATE UNIQUE INDEX location_unique_idx ON Location (
    COALESCE(msamd, -1),
    COALESCE(state_code, -1::SMALLINT),
    COALESCE(county_code, -1),
    COALESCE(census_tract_number, -1),
    COALESCE(population, -1),
    COALESCE(minority_population, -1),
    COALESCE(hud_median_family_income, -1),
    COALESCE(tract_to_msamd_income, -1),
    COALESCE(number_of_owner_occupied_units, -1),
    COALESCE(number_of_1_to_4_family_units, -1)
);
-- Original:
--     UNIQUE (
--         msamd, state_code, county_code, census_tract_number,
--         population, minority_population, hud_median_family_income,
--         tract_to_msamd_income, number_of_owner_occupied_units,
--         number_of_1_to_4_family_units
--     )


-- ============================
-- INSERT DISTINCT LOCATIONS
-- fill up the new location table
-- ============================
INSERT INTO Location (
    msamd,
    state_code,
    county_code,
    census_tract_number,
    population,
    minority_population,
    hud_median_family_income,
    tract_to_msamd_income,
    number_of_owner_occupied_units,
    number_of_1_to_4_family_units
)

-- only select distinct values from the application table
SELECT DISTINCT
    msamd,
    state_code,
    county_code,
    census_tract_number,
    population,
    minority_population,
    hud_median_family_income,
    tract_to_msamd_income,
    number_of_owner_occupied_units,
    number_of_1_to_4_family_units
FROM Application;


-- =================================
-- NEW APPLICATION TABLE
-- the new application table replaces the old one and should be in 3NF (reduce functional dependencies)
-- =================================
CREATE TABLE Application_New (
    id INT PRIMARY KEY,
    as_of_year SMALLINT,
    respondent_id TEXT,
    agency_code SMALLINT REFERENCES Agency,
    loan_type SMALLINT REFERENCES LoanType,
    property_type SMALLINT REFERENCES PropertyType,
    loan_purpose SMALLINT REFERENCES LoanPurpose,
    owner_occupancy SMALLINT REFERENCES OwnerOccupancy,
    loan_amount_000s INT,
    preapproval SMALLINT REFERENCES Preapproval,
    action_taken SMALLINT REFERENCES ActionTaken,

    location_id INT REFERENCES Location,

    applicant_ethnicity SMALLINT REFERENCES ApplicantEthnicity,
    co_applicant_ethnicity SMALLINT REFERENCES CoApplicantEthnicity,
    applicant_sex SMALLINT REFERENCES Sex,
    co_applicant_sex SMALLINT REFERENCES CoApplicantSex,

    applicant_income_000s INT,
    purchaser_type SMALLINT REFERENCES PurchaserType,

    rate_spread NUMERIC,
    hoepa_status SMALLINT REFERENCES HOEPAStatus,
    lien_status SMALLINT REFERENCES LienStatus,
    edit_status SMALLINT REFERENCES EditStatus,

    sequence_number INT,
    application_date_indicator SMALLINT
);

-- insert data into the new application table (data is extracted from original application table using alias a)
-- Changed: use IS NOT DISTINCT FROM for NULL-safe comparison on all location columns
INSERT INTO Application_New
SELECT
    a.id,
    a.as_of_year,
    a.respondent_id,
    a.agency_code,
    a.loan_type,
    a.property_type,
    a.loan_purpose,
    a.owner_occupancy,
    a.loan_amount_000s,
    a.preapproval,
    a.action_taken,

    l.location_id,

    a.applicant_ethnicity,
    a.co_applicant_ethnicity,
    a.applicant_sex,
    a.co_applicant_sex,
    a.applicant_income_000s,
    a.purchaser_type,

    a.rate_spread,
    a.hoepa_status,
    a.lien_status,
    a.edit_status,

    a.sequence_number,
    a.application_date_indicator

FROM Application a
JOIN Location l -- data is joined from the location table
ON (
    a.msamd IS NOT DISTINCT FROM l.msamd AND 
    a.state_code IS NOT DISTINCT FROM l.state_code AND 
    a.county_code IS NOT DISTINCT FROM l.county_code AND
    a.census_tract_number IS NOT DISTINCT FROM l.census_tract_number AND 
    a.population IS NOT DISTINCT FROM l.population AND 
    a.minority_population IS NOT DISTINCT FROM l.minority_population AND 
    a.hud_median_family_income IS NOT DISTINCT FROM l.hud_median_family_income AND 
    a.tract_to_msamd_income IS NOT DISTINCT FROM l.tract_to_msamd_income AND 
    a.number_of_owner_occupied_units IS NOT DISTINCT FROM l.number_of_owner_occupied_units AND 
    a.number_of_1_to_4_family_units IS NOT DISTINCT FROM l.number_of_1_to_4_family_units 
);


-- =========================================
-- APPLICANT RACE TABLE
-- 1NF: unpivot applicant_race_1..5 into rows
-- =========================================
CREATE TABLE ApplicantRace (
    application_id INT REFERENCES Application_New(id),
    race SMALLINT REFERENCES Race(race), 
    race_number SMALLINT,
    PRIMARY KEY (application_id, race_number)
);

INSERT INTO ApplicantRace
SELECT p.id, p.applicant_race_1::SMALLINT, 1
FROM Preliminary p
JOIN Application_New a ON p.id = a.id
WHERE p.applicant_race_1 IS NOT NULL

UNION ALL
SELECT p.id, p.applicant_race_2::SMALLINT, 2
FROM Preliminary p
JOIN Application_New a ON p.id = a.id
WHERE p.applicant_race_2 IS NOT NULL

UNION ALL
SELECT p.id, p.applicant_race_3::SMALLINT, 3
FROM Preliminary p
JOIN Application_New a ON p.id = a.id
WHERE p.applicant_race_3 IS NOT NULL

UNION ALL
SELECT p.id, p.applicant_race_4::SMALLINT, 4
FROM Preliminary p
JOIN Application_New a ON p.id = a.id
WHERE p.applicant_race_4 IS NOT NULL

UNION ALL
SELECT p.id, p.applicant_race_5::SMALLINT, 5
FROM Preliminary p
JOIN Application_New a ON p.id = a.id
WHERE p.applicant_race_5 IS NOT NULL;


-- =========================================
-- CO-APPLICANT RACE TABLE
-- 1NF: unpivot co_applicant_race_1..5 into rows
-- =========================================
CREATE TABLE CoApplicantRace (
    application_id INT REFERENCES Application_New(id),
    race SMALLINT REFERENCES Race(race), 
    race_number SMALLINT,
    PRIMARY KEY (application_id, race_number)
);

INSERT INTO CoApplicantRace
SELECT p.id, p.co_applicant_race_1::SMALLINT, 1
FROM Preliminary p
JOIN Application_New a ON p.id = a.id
WHERE p.co_applicant_race_1 IS NOT NULL

UNION ALL
SELECT p.id, p.co_applicant_race_2::SMALLINT, 2
FROM Preliminary p
JOIN Application_New a ON p.id = a.id
WHERE p.co_applicant_race_2 IS NOT NULL

UNION ALL
SELECT p.id, p.co_applicant_race_3::SMALLINT, 3
FROM Preliminary p
JOIN Application_New a ON p.id = a.id
WHERE p.co_applicant_race_3 IS NOT NULL

UNION ALL
SELECT p.id, p.co_applicant_race_4::SMALLINT, 4
FROM Preliminary p
JOIN Application_New a ON p.id = a.id
WHERE p.co_applicant_race_4 IS NOT NULL

UNION ALL
SELECT p.id, p.co_applicant_race_5::SMALLINT, 5
FROM Preliminary p
JOIN Application_New a ON p.id = a.id
WHERE p.co_applicant_race_5 IS NOT NULL;


-- =========================================
-- DENIAL REASON LINK TABLE
-- 1NF: unpivot denial_reason_1..3 into rows
-- =========================================
CREATE TABLE DenialReasonLink (
    application_id INT REFERENCES Application_New(id),
    denial_reason SMALLINT REFERENCES DenialReason,
    reason_number SMALLINT,
    PRIMARY KEY (application_id, reason_number)
);

INSERT INTO DenialReasonLink
SELECT p.id, p.denial_reason_1::SMALLINT, 1
FROM Preliminary p
JOIN Application_New a ON p.id = a.id
WHERE p.denial_reason_1 IS NOT NULL

UNION ALL
SELECT p.id, p.denial_reason_2::SMALLINT, 2
FROM Preliminary p
JOIN Application_New a ON p.id = a.id
WHERE p.denial_reason_2 IS NOT NULL

UNION ALL
SELECT p.id, p.denial_reason_3::SMALLINT, 3
FROM Preliminary p
JOIN Application_New a ON p.id = a.id
WHERE p.denial_reason_3 IS NOT NULL;


-- =========================================
-- CLEANUP
-- drop the original application table and rename
-- =========================================
DROP TABLE Application;
ALTER TABLE Application_New RENAME TO Application;

/* COMMANDS (FOR VIDEO DEMO)

SELECT * FROM Location LIMIT 5;
SELECT * FROM Application LIMIT 5;
SELECT * FROM ApplicantRace LIMIT 5;
SELECT * FROM CoApplicantRace LIMIT 5;
SELECT * FROM DenialReasonLink LIMIT 5;*/

-- step_4.sql

-- STEP 4: Error checking and report generation (CORRECTED)

SET statement_timeout = 0;

-- =========================================================
-- 1) STRONGER ERROR CHECKING
-- =========================================================

ALTER TABLE ApplicantRace
    DROP CONSTRAINT IF EXISTS applicantrace_race_number_chk,
    ADD CONSTRAINT applicantrace_race_number_chk CHECK (race_number BETWEEN 1 AND 5);

ALTER TABLE CoApplicantRace
    DROP CONSTRAINT IF EXISTS coapplicantrace_race_number_chk,
    ADD CONSTRAINT coapplicantrace_race_number_chk CHECK (race_number BETWEEN 1 AND 5);

ALTER TABLE DenialReasonLink
    DROP CONSTRAINT IF EXISTS denialreasonlink_reason_number_chk,
    ADD CONSTRAINT denialreasonlink_reason_number_chk CHECK (reason_number BETWEEN 1 AND 3);

-- Optional but STRONGLY recommended (prevents duplicate slots)
ALTER TABLE ApplicantRace
    DROP CONSTRAINT IF EXISTS unique_app_race,
    ADD CONSTRAINT unique_app_race UNIQUE (application_id, race_number);

ALTER TABLE CoApplicantRace
    DROP CONSTRAINT IF EXISTS unique_coapp_race,
    ADD CONSTRAINT unique_coapp_race UNIQUE (application_id, race_number);

ALTER TABLE DenialReasonLink
    DROP CONSTRAINT IF EXISTS unique_denial_reason,
    ADD CONSTRAINT unique_denial_reason UNIQUE (application_id, reason_number);

-- =========================================================
-- 2) REBUILD ORIGINAL CSV (FIXED JOIN STRATEGY)
-- =========================================================

DROP VIEW IF EXISTS HMDA_Report_Recreated;

CREATE VIEW HMDA_Report_Recreated AS
WITH applicant_race_pivot AS (
    SELECT
        ar.application_id,
        MAX(CASE WHEN race_number = 1 THEN ar.race END) AS applicant_race_1,
        MAX(CASE WHEN race_number = 2 THEN ar.race END) AS applicant_race_2,
        MAX(CASE WHEN race_number = 3 THEN ar.race END) AS applicant_race_3,
        MAX(CASE WHEN race_number = 4 THEN ar.race END) AS applicant_race_4,
        MAX(CASE WHEN race_number = 5 THEN ar.race END) AS applicant_race_5,
        MAX(CASE WHEN race_number = 1 THEN r.race_name END) AS applicant_race_name_1,
        MAX(CASE WHEN race_number = 2 THEN r.race_name END) AS applicant_race_name_2,
        MAX(CASE WHEN race_number = 3 THEN r.race_name END) AS applicant_race_name_3,
        MAX(CASE WHEN race_number = 4 THEN r.race_name END) AS applicant_race_name_4,
        MAX(CASE WHEN race_number = 5 THEN r.race_name END) AS applicant_race_name_5
    FROM ApplicantRace ar
    LEFT JOIN Race r ON r.race = ar.race
    GROUP BY ar.application_id
),
co_applicant_race_pivot AS (
    SELECT
        car.application_id,
        MAX(CASE WHEN race_number = 1 THEN car.race END) AS co_applicant_race_1,
        MAX(CASE WHEN race_number = 2 THEN car.race END) AS co_applicant_race_2,
        MAX(CASE WHEN race_number = 3 THEN car.race END) AS co_applicant_race_3,
        MAX(CASE WHEN race_number = 4 THEN car.race END) AS co_applicant_race_4,
        MAX(CASE WHEN race_number = 5 THEN car.race END) AS co_applicant_race_5,
        MAX(CASE WHEN race_number = 1 THEN r.race_name END) AS co_applicant_race_name_1,
        MAX(CASE WHEN race_number = 2 THEN r.race_name END) AS co_applicant_race_name_2,
        MAX(CASE WHEN race_number = 3 THEN r.race_name END) AS co_applicant_race_name_3,
        MAX(CASE WHEN race_number = 4 THEN r.race_name END) AS co_applicant_race_name_4,
        MAX(CASE WHEN race_number = 5 THEN r.race_name END) AS co_applicant_race_name_5
    FROM CoApplicantRace car
    LEFT JOIN Race r ON r.race = car.race
    GROUP BY car.application_id
),
denial_reason_pivot AS (
    SELECT
        drl.application_id,
        MAX(CASE WHEN reason_number = 1 THEN drl.denial_reason END) AS denial_reason_1,
        MAX(CASE WHEN reason_number = 2 THEN drl.denial_reason END) AS denial_reason_2,
        MAX(CASE WHEN reason_number = 3 THEN drl.denial_reason END) AS denial_reason_3,
        MAX(CASE WHEN reason_number = 1 THEN dr.denial_reason_name END) AS denial_reason_name_1,
        MAX(CASE WHEN reason_number = 2 THEN dr.denial_reason_name END) AS denial_reason_name_2,
        MAX(CASE WHEN reason_number = 3 THEN dr.denial_reason_name END) AS denial_reason_name_3
    FROM DenialReasonLink drl
    LEFT JOIN DenialReason dr ON dr.denial_reason = drl.denial_reason
    GROUP BY drl.application_id
)

SELECT
    COALESCE(a.as_of_year::TEXT, '') AS as_of_year,
    COALESCE(a.respondent_id, '') AS respondent_id,

    COALESCE(ag.agency_name, '') AS agency_name,
    COALESCE(ag.agency_abbr, '') AS agency_abbr,
    COALESCE(a.agency_code::TEXT, '') AS agency_code,

    COALESCE(lt.loan_type_name, '') AS loan_type_name,
    COALESCE(a.loan_type::TEXT, '') AS loan_type,

    COALESCE(pt.property_type_name, '') AS property_type_name,
    COALESCE(a.property_type::TEXT, '') AS property_type,

    COALESCE(lp.loan_purpose_name, '') AS loan_purpose_name,
    COALESCE(a.loan_purpose::TEXT, '') AS loan_purpose,

    COALESCE(oo.owner_occupancy_name, '') AS owner_occupancy_name,
    COALESCE(a.owner_occupancy::TEXT, '') AS owner_occupancy,

    COALESCE(a.loan_amount_000s::TEXT, '') AS loan_amount_000s,

    COALESCE(pa.preapproval_name, '') AS preapproval_name,
    COALESCE(a.preapproval::TEXT, '') AS preapproval,

    COALESCE(at.action_taken_name, '') AS action_taken_name,
    COALESCE(a.action_taken::TEXT, '') AS action_taken,

    COALESCE(m.msamd_name, '') AS msamd_name,
    COALESCE(l.msamd::TEXT, '') AS msamd,

    COALESCE(s.state_name, '') AS state_name,
    COALESCE(s.state_abbr, '') AS state_abbr,
    COALESCE(l.state_code::TEXT, '') AS state_code,

    COALESCE(c.county_name, '') AS county_name,
    COALESCE(l.county_code::TEXT, '') AS county_code,

    COALESCE(l.census_tract_number::TEXT, '') AS census_tract_number,

    COALESCE(ae.applicant_ethnicity_name, '') AS applicant_ethnicity_name,
    COALESCE(a.applicant_ethnicity::TEXT, '') AS applicant_ethnicity,

    COALESCE(cae.co_applicant_ethnicity_name, '') AS co_applicant_ethnicity_name,
    COALESCE(a.co_applicant_ethnicity::TEXT, '') AS co_applicant_ethnicity,

    COALESCE(arp.applicant_race_name_1, '') AS applicant_race_name_1,
    COALESCE(arp.applicant_race_1::TEXT, '') AS applicant_race_1,
    COALESCE(arp.applicant_race_name_2, '') AS applicant_race_name_2,
    COALESCE(arp.applicant_race_2::TEXT, '') AS applicant_race_2,
    COALESCE(arp.applicant_race_name_3, '') AS applicant_race_name_3,
    COALESCE(arp.applicant_race_3::TEXT, '') AS applicant_race_3,
    COALESCE(arp.applicant_race_name_4, '') AS applicant_race_name_4,
    COALESCE(arp.applicant_race_4::TEXT, '') AS applicant_race_4,
    COALESCE(arp.applicant_race_name_5, '') AS applicant_race_name_5,
    COALESCE(arp.applicant_race_5::TEXT, '') AS applicant_race_5,

    COALESCE(carp.co_applicant_race_name_1, '') AS co_applicant_race_name_1,
    COALESCE(carp.co_applicant_race_1::TEXT, '') AS co_applicant_race_1,
    COALESCE(carp.co_applicant_race_name_2, '') AS co_applicant_race_name_2,
    COALESCE(carp.co_applicant_race_2::TEXT, '') AS co_applicant_race_2,
    COALESCE(carp.co_applicant_race_name_3, '') AS co_applicant_race_name_3,
    COALESCE(carp.co_applicant_race_3::TEXT, '') AS co_applicant_race_3,
    COALESCE(carp.co_applicant_race_name_4, '') AS co_applicant_race_name_4,
    COALESCE(carp.co_applicant_race_4::TEXT, '') AS co_applicant_race_4,
    COALESCE(carp.co_applicant_race_name_5, '') AS co_applicant_race_name_5,
    COALESCE(carp.co_applicant_race_5::TEXT, '') AS co_applicant_race_5,

    COALESCE(sx.sex_name, '') AS applicant_sex_name,
    COALESCE(a.applicant_sex::TEXT, '') AS applicant_sex,

    COALESCE(csx.co_applicant_sex_name, '') AS co_applicant_sex_name,
    COALESCE(a.co_applicant_sex::TEXT, '') AS co_applicant_sex,

    COALESCE(a.applicant_income_000s::TEXT, '') AS applicant_income_000s,

    COALESCE(pu.purchaser_type_name, '') AS purchaser_type_name,
    COALESCE(a.purchaser_type::TEXT, '') AS purchaser_type,

    COALESCE(drp.denial_reason_name_1, '') AS denial_reason_name_1,
    COALESCE(drp.denial_reason_1::TEXT, '') AS denial_reason_1,
    COALESCE(drp.denial_reason_name_2, '') AS denial_reason_name_2,
    COALESCE(drp.denial_reason_2::TEXT, '') AS denial_reason_2,
    COALESCE(drp.denial_reason_name_3, '') AS denial_reason_name_3,
    COALESCE(drp.denial_reason_3::TEXT, '') AS denial_reason_3,

    COALESCE(a.rate_spread::TEXT, '') AS rate_spread,

    COALESCE(hs.hoepa_status_name, '') AS hoepa_status_name,
    COALESCE(a.hoepa_status::TEXT, '') AS hoepa_status,

    COALESCE(ls.lien_status_name, '') AS lien_status_name,
    COALESCE(a.lien_status::TEXT, '') AS lien_status,

    CASE WHEN a.edit_status IS NULL THEN '' ELSE COALESCE(es.edit_status_name, '') END AS edit_status_name,
    COALESCE(a.edit_status::TEXT, '') AS edit_status,

    COALESCE(a.sequence_number::TEXT, '') AS sequence_number,

    COALESCE(l.population::TEXT, '') AS population,
    COALESCE(l.minority_population::TEXT, '') AS minority_population,
    COALESCE(l.hud_median_family_income::TEXT, '') AS hud_median_family_income,
    COALESCE(l.tract_to_msamd_income::TEXT, '') AS tract_to_msamd_income,
    COALESCE(l.number_of_owner_occupied_units::TEXT, '') AS number_of_owner_occupied_units,
    COALESCE(l.number_of_1_to_4_family_units::TEXT, '') AS number_of_1_to_4_family_units,

    COALESCE(a.application_date_indicator::TEXT, '') AS application_date_indicator

FROM Application a
LEFT JOIN Agency ag ON ag.agency_code = a.agency_code
LEFT JOIN LoanType lt ON lt.loan_type = a.loan_type
LEFT JOIN PropertyType pt ON pt.property_type = a.property_type
LEFT JOIN LoanPurpose lp ON lp.loan_purpose = a.loan_purpose
LEFT JOIN OwnerOccupancy oo ON oo.owner_occupancy = a.owner_occupancy
LEFT JOIN Preapproval pa ON pa.preapproval = a.preapproval
LEFT JOIN ActionTaken at ON at.action_taken = a.action_taken
LEFT JOIN Location l ON l.location_id = a.location_id
LEFT JOIN MSAMD m ON m.msamd = l.msamd
LEFT JOIN State s ON s.state_code = l.state_code
LEFT JOIN County c ON c.county_code = l.county_code
LEFT JOIN ApplicantEthnicity ae ON ae.applicant_ethnicity = a.applicant_ethnicity
LEFT JOIN CoApplicantEthnicity cae ON cae.co_applicant_ethnicity = a.co_applicant_ethnicity
LEFT JOIN applicant_race_pivot arp ON arp.application_id = a.id
LEFT JOIN co_applicant_race_pivot carp ON carp.application_id = a.id
LEFT JOIN Sex sx ON sx.sex = a.applicant_sex
LEFT JOIN CoApplicantSex csx ON csx.co_applicant_sex = a.co_applicant_sex
LEFT JOIN PurchaserType pu ON pu.purchaser_type = a.purchaser_type
LEFT JOIN denial_reason_pivot drp ON drp.application_id = a.id
LEFT JOIN HOEPAStatus hs ON hs.hoepa_status = a.hoepa_status
LEFT JOIN LienStatus ls ON ls.lien_status = a.lien_status
LEFT JOIN EditStatus es ON es.edit_status = a.edit_status

ORDER BY a.id;

-- =========================================================
-- 3) EXPORT
-- =========================================================

-- fixed so copying can work on your computer, not the server machine
\copy (SELECT * FROM HMDA_Report_Recreated) TO 'hmda_2017_nj_reconstructed.csv' CSV HEADER;

-- =====================================
-- INCORRECT ATTEMPT COMMANDS FOR VIDEO
-- =====================================

-- ATTEMPT 1: invalid property type (foreign key error)
/*
INSERT INTO Application (
    id, as_of_year, respondent_id, agency_code, loan_type, property_type,
    loan_purpose, owner_occupancy, loan_amount_000s, preapproval,
    action_taken, location_id, applicant_ethnicity, co_applicant_ethnicity,
    applicant_sex, co_applicant_sex, applicant_income_000s, purchaser_type,
    rate_spread, hoepa_status, lien_status, edit_status,
    sequence_number, application_date_indicator
) VALUES (
    999999001, 2017, 'TEST1', 1, 1, 99,
    1, 1, 250, 1,
    1, 1, 1, 1,
    1, 1, 80, 0,
    NULL, 1, 1, NULL,
    1, 0
);*/

-- ATTEMPT 2: invalid race number (CHECK constraint)
/*
INSERT INTO ApplicantRace (application_id, race, race_number)
VALUES (1, 1, 7);*/

-- ATTEMPT 3: invalid location id (foreign key error)
/*
INSERT INTO Application (
    id, as_of_year, respondent_id, agency_code, loan_type, property_type,
    loan_purpose, owner_occupancy, loan_amount_000s, preapproval,
    action_taken, location_id, applicant_ethnicity, co_applicant_ethnicity,
    applicant_sex, co_applicant_sex, applicant_income_000s, purchaser_type,
    rate_spread, hoepa_status, lien_status, edit_status,
    sequence_number, application_date_indicator
) VALUES (
    999999002, 2017, 'TEST3', 1, 1, 1,
    1, 1, 250, 1,
    1, 999999, 1, 1,
    1, 1, 80, 0,
    NULL, 1, 1, NULL,
    2, 0
);*/