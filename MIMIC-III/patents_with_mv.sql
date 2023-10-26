-- Patients with mechanical ventilation

SELECT DISTINCT i.SUBJECT_ID 
FROM 
`physionet-data.mimiciii_derived.ventdurations` v
JOIN 
`physionet-data.mimiciii_clinical.icustays` i
ON i.ICUSTAY_ID = v.icustay_id
