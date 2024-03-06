CREATE OR REPLACE TABLE `in-iusm-bhds-depot.shipal.mimiciv_hourly_ventilation` AS
WITH ranked_data AS (
  SELECT
    stay_id,
    status_starttime,
    status_endtime,
    icu_intime,
    icu_outtime,
    ventilation_status,
    ventilation_category,
    ROW_NUMBER() OVER (PARTITION BY stay_id, status_starttime ORDER BY
      CASE
        WHEN ventilation_status = 'trach' THEN 1
        WHEN ventilation_status = 'mech vent' THEN 2
        WHEN ventilation_status = 'NIV' THEN 3
        WHEN ventilation_status = 'high flow' THEN 4
        WHEN ventilation_status = 'o2' THEN 5
        ELSE 6
      END
    ) AS setting_priority
  FROM
    `in-iusm-bhds-depot.shipal.mimic_iv_ventilation_icu_master`
),

icu_data AS (
  SELECT
    stay_id,
    subject_id,
    intime AS icu_intime,
    outtime AS icu_outtime
  FROM
    physionet-data.mimiciv_icu.icustays
  WHERE stay_id IN (SELECT DISTINCT stay_id FROM ranked_data)
),

hourly_data AS (
  SELECT
    icu.stay_id,
    icu.subject_id,
    icu_intime,
    icu_outtime,
    TIMESTAMP_ADD(icu.icu_intime, INTERVAL n HOUR) AS hourly_timestamp
  FROM
    icu_data icu
  CROSS JOIN
    UNNEST(GENERATE_ARRAY(0, TIMESTAMP_DIFF(icu.icu_outtime, icu.icu_intime, HOUR))) AS n
)
-- subject_id, stay_id, icu in/out time stamps, status start/end time stamps, hourly_timestamp, hour_rownum, ventilation status, ventilation category
SELECT
  hd.subject_id,
  hd.stay_id,
  hd.icu_intime,
  hd.icu_outtime,
  rd.status_starttime,
  rd.status_endtime,
  hd.hourly_timestamp,
  ROW_NUMBER() OVER (PARTITION BY hd.stay_id ORDER BY hd.hourly_timestamp) AS hour_rownum,
  COALESCE(rd.ventilation_status, 'None') AS ventilation_status, 
  CASE
    WHEN ventilation_status IN ('Tracheostomy', 'InvasiveVent') THEN 'Invasive'
    WHEN ventilation_status IN ('NonInvasiveVent', 'HFNC', 'SupplementalOxygen') THEN 'NonInvasive'
    ELSE 'None'
  END AS ventilation_category

  
FROM
  hourly_data hd
LEFT JOIN
  ranked_data rd ON hd.stay_id = rd.stay_id
    AND hd.hourly_timestamp BETWEEN rd.status_starttime AND rd.status_endtime
ORDER BY
  hd.stay_id,
  hd.hourly_timestamp;
