SELECT DISTINCT i.* 
FROM `physionet-data.mimiciv_derived.ventilator_setting` v 
JOIN physionet-data.mimiciv_icu.icustays i on 
v.subject_id = i.subject_id and v.stay_id = i.stay_id
order by subject_id, stay_id
