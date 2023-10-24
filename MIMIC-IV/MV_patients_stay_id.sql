-- Required : ventillation setting table
-- Patients with MV along with their ICU stay_id

SELECT DISTINCT subject_id, stay_id 
FROM `physionet-data.mimiciv_derived.ventilator_setting` 
order by subject_id, stay_id
