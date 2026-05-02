-- Author: Yasaman Saatsaz


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