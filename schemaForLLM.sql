-- Instructions for LLM:
-- Write only PostgreSQL SELECT queries.
-- Use Application as the main table.

CREATE TABLE Agency (
    agency_code SMALLINT PRIMARY KEY,
    agency_name TEXT,
    agency_abbr TEXT
);

-- lookup table for the type of loan
CREATE TABLE LoanType (
    loan_type SMALLINT PRIMARY KEY,
    loan_type_name TEXT
);

-- lookup table for the type of property
CREATE TABLE PropertyType (
    property_type SMALLINT PRIMARY KEY,
    property_type_name TEXT
);

-- lookup table for the loan's purpose
CREATE TABLE LoanPurpose (
    loan_purpose SMALLINT PRIMARY KEY,
    loan_purpose_name TEXT
);

-- lookup table for the owner occupancy
CREATE TABLE OwnerOccupancy (
    owner_occupancy SMALLINT PRIMARY KEY,
    owner_occupancy_name TEXT
);

-- lookup table for the preapproval
CREATE TABLE Preapproval (
    preapproval SMALLINT PRIMARY KEY,
    preapproval_name TEXT
);

-- lookup table for the specific action taken
CREATE TABLE ActionTaken (
    action_taken SMALLINT PRIMARY KEY,
    action_taken_name TEXT
);

-- lookup table for the MSAMD
CREATE TABLE MSAMD (
    msamd INT PRIMARY KEY,
    msamd_name TEXT
);

-- lookup table for the specific state
CREATE TABLE State (
    state_code SMALLINT PRIMARY KEY,
    state_name TEXT,
    state_abbr TEXT
);

-- lookup table for the specific county
CREATE TABLE County (
    county_code INT PRIMARY KEY,
    county_name TEXT
);


-- lookup table for the applicant's ethnicity
CREATE TABLE ApplicantEthnicity (
    applicant_ethnicity SMALLINT PRIMARY KEY,
    applicant_ethnicity_name TEXT
);

-- lookup table for the co-applicant's ethnicity
CREATE TABLE CoApplicantEthnicity (
    co_applicant_ethnicity SMALLINT PRIMARY KEY,
    co_applicant_ethnicity_name TEXT
);

-- lookup table for the applicant's sex
CREATE TABLE Sex (
    sex SMALLINT PRIMARY KEY,
    sex_name TEXT
);

-- lookup table for the co-applicant's sex
CREATE TABLE CoApplicantSex (
    co_applicant_sex SMALLINT PRIMARY KEY,
    co_applicant_sex_name TEXT
);

-- lookup table for the type of purchaser
CREATE TABLE PurchaserType (
    purchaser_type SMALLINT PRIMARY KEY,
    purchaser_type_name TEXT
);

-- lookup table for the reason for denial
CREATE TABLE DenialReason (
    denial_reason SMALLINT PRIMARY KEY,
    denial_reason_name TEXT
);

-- lookup table for HOEPA status
CREATE TABLE HOEPAStatus (
    hoepa_status SMALLINT PRIMARY KEY,
    hoepa_status_name TEXT
);

-- lookup tale for lien status
CREATE TABLE LienStatus (
    lien_status SMALLINT PRIMARY KEY,
    lien_status_name TEXT
);

-- lookup table for edit status (edit state has empty values -- NULL-ONLY)
CREATE TABLE EditStatus (
    edit_status SMALLINT PRIMARY KEY,
    edit_status_name TEXT
);

CREATE TABLE Race (
    race SMALLINT PRIMARY KEY,
    race_name TEXT
);

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

-- =================================
-- MAIN APPLICATION TABLE
-- Use Application as the main table for all queries.
-- =================================
CREATE TABLE Application(
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

-- =========================================
-- One application can have multiple applicant races
-- =========================================
CREATE TABLE ApplicantRace (
    application_id INT REFERENCES Application(id),
    race SMALLINT REFERENCES Race(race), 
    race_number SMALLINT,
    PRIMARY KEY (application_id, race_number)
);

-- =========================================
-- One application can have multiple co-applicant races
-- =========================================
CREATE TABLE CoApplicantRace (
    application_id INT REFERENCES Application(id),
    race SMALLINT REFERENCES Race(race), 
    race_number SMALLINT,
    PRIMARY KEY (application_id, race_number)
);

-- =========================================
-- DENIAL REASON LINK TABLE
-- 1NF: unpivot denial_reason_1..3 into rows
-- =========================================
CREATE TABLE DenialReasonLink (
    application_id INT REFERENCES Application(id),
    denial_reason SMALLINT REFERENCES DenialReason,
    reason_number SMALLINT,
    PRIMARY KEY (application_id, reason_number)
);

-- loan_amount_000s is loan amount in thousands of dollars.
-- applicant_income_000s is applicant income in thousands of dollars.
-- action_taken describes whether the loan was approved, denied, withdrawn, etc.

-- Common joins:
-- Application.location_id = Location.location_id
-- Application.agency_code = Agency.agency_code
-- Application.loan_type = LoanType.loan_type
-- Application.property_type = PropertyType.property_type
-- Application.loan_purpose = LoanPurpose.loan_purpose
-- Application.owner_occupancy = OwnerOccupancy.owner_occupancy
-- Application.preapproval = Preapproval.preapproval
-- Application.action_taken = ActionTaken.action_taken
-- Application.applicant_ethnicity = ApplicantEthnicity.applicant_ethnicity
-- Application.co_applicant_ethnicity = CoApplicantEthnicity.co_applicant_ethnicity
-- Application.applicant_sex = Sex.sex
-- Application.co_applicant_sex = CoApplicantSex.co_applicant_sex
-- Application.purchaser_type = PurchaserType.purchaser_type
-- Application.hoepa_status = HOEPAStatus.hoepa_status
-- Application.lien_status = LienStatus.lien_status
-- Application.edit_status = EditStatus.edit_status
-- ApplicantRace.application_id = Application.id
-- ApplicantRace.race = Race.race
-- CoApplicantRace.application_id = Application.id
-- CoApplicantRace.race = Race.race
-- DenialReasonLink.application_id = Application.id
-- DenialReasonLink.denial_reason = DenialReason.denial_reason