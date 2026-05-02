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