-- Ventilator status and category information with corresponding icu stays

CREATE OR REPLACE TABLE shipal.mimic_iv_ventilation_icu_master AS
SELECT icu.subject_id, icu.stay_id, 
icu.intime as icu_intime, icu.outtime as icu_outtime, 
v.starttime as status_starttime, v.endtime as status_endtime, 
v.ventilation_status, 
CASE
    WHEN v.ventilation_status IN 
					('Tracheostomy', 'InvasiveVent') THEN 'Invasive'
    WHEN v.ventilation_status IN 
					('NonInvasiveVent', 'HFNC', 'SupplementalOxygen') THEN 'NonInvasive'
    ELSE 'None'
END AS ventilation_category
FROM `physionet-data.mimiciv_icu.icustays` icu JOIN 
`physionet-data.mimiciv_derived.ventilation` v
ON icu.stay_id = v.stay_id
ORDER BY icu.subject_id ,icu.stay_id, icu.intime, v.starttime
