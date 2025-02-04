WITH duration_data AS (
    SELECT 
        EXTRACT(EPOCH FROM AVG(a.dischtime::TIMESTAMP - a.admittime::TIMESTAMP)) AS avg_seconds
    FROM hosp.admissions a
    JOIN hosp.diagnoses_icd d ON a.hadm_id = d.hadm_id
    WHERE d.icd_code = '4019' AND d.icd_version = '9'
)
SELECT 
  TRIM(
    LEADING '0 days, ' FROM 
    FLOOR(avg_seconds/86400)::TEXT || ' days, ' ||
    TO_CHAR(
      (make_interval(secs => avg_seconds - FLOOR(avg_seconds/86400)*86400))::time, 
      'HH24:MI:SS'
    )
  ) AS avg_duration
FROM duration_data;
