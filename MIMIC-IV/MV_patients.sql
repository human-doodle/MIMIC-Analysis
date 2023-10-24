-- required: ventilator_setting table
-- Subject_id (patients) recieving Mechanical Ventillation
SELECT DISTINCT subject_id FROM `physionet-data.mimiciv_derived.ventilator_setting` 
