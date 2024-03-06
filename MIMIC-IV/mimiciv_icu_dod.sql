CREATE OR REPLACE TABLE `in-iusm-bhds-depot.shipal.mimiciv_icu_dod` AS
SELECT icu_stays.subject_id, icu_stays.stay_id, patients.dod
FROM `physionet-data.mimiciv_icu.icustays` as icu_stays
JOIN `physionet-data.mimiciv_hosp.patients`as patients 
ON icu_stays.subject_id = patients.subject_id;
