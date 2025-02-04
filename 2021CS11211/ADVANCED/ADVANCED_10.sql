WITH first_admissions AS (
    SELECT 
        ad.subject_id, 
        ad.hadm_id AS first_hadm_id,
        ad.admittime AS first_admit_time,
        ad.dischtime AS first_discharge_time,
        ROW_NUMBER() OVER (PARTITION BY ad.subject_id ORDER BY ad.admittime) AS rn
    FROM admissions ad
), 
diagnosed_patients AS (
    SELECT DISTINCT d.subject_id, d.hadm_id
    FROM diagnoses_icd d
    WHERE d.icd_code LIKE 'I2%'
), 
readmissions AS (
    SELECT 
        f.subject_id, 
        ra.hadm_id AS second_hadm_id, 
        ra.admittime AS second_admit_time,
        EXTRACT(EPOCH FROM (ra.admittime::timestamp - f.first_discharge_time::timestamp)) AS time_gap_seconds
    FROM first_admissions f
    JOIN admissions ra 
        ON f.subject_id = ra.subject_id 
        AND ra.admittime > f.first_discharge_time 
        AND (ra.admittime::timestamp - f.first_discharge_time::timestamp) <= INTERVAL '180 days'
    WHERE f.rn = 1
    AND f.subject_id IN (SELECT subject_id FROM diagnosed_patients)
)
SELECT 
    r.subject_id, 
    r.second_hadm_id,
    make_interval(secs => r.time_gap_seconds) AS time_gap_between_admissions,
    STRING_AGG(s.curr_service, ', ' ORDER BY s.transfertime) AS services
FROM readmissions r
JOIN services s 
    ON r.second_hadm_id = s.hadm_id
GROUP BY r.subject_id, r.second_hadm_id, r.time_gap_seconds
ORDER BY 
    LENGTH(STRING_AGG(s.curr_service, ', ' ORDER BY s.transfertime)) DESC,
    r.time_gap_seconds DESC, 
    r.subject_id ASC, 
    r.second_hadm_id ASC;