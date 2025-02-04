WITH resistant_patients AS (
    SELECT 
        subject_id, 
        hadm_id, 
        COUNT(DISTINCT micro_specimen_id) AS resistant_antibiotic_count
    FROM hosp.microbiologyevents
    WHERE interpretation = 'R'
    GROUP BY subject_id, hadm_id
    HAVING COUNT(DISTINCT micro_specimen_id) >= 2
),
icu_stays AS (
    SELECT 
        subject_id, 
        hadm_id, 
        ROUND(
            SUM(EXTRACT(EPOCH FROM CAST (outtime AS TIMESTAMP) - CAST(intime AS TIMESTAMP)) / 3600), 2
        ) AS icu_length_of_stay_hours
    FROM icu.icustays
    WHERE hadm_id IS NOT NULL
    GROUP BY subject_id, hadm_id
),
patient_status AS (
    SELECT 
        subject_id, 
        hadm_id, 
        CASE 
            WHEN discharge_location = 'DIED' THEN 1 
            ELSE 0 
        END AS died_in_hospital
    FROM hosp.admissions
    WHERE hadm_id IS NOT NULL
)
SELECT 
    rp.subject_id, 
    rp.hadm_id, 
    rp.resistant_antibiotic_count, 
    COALESCE(icu.icu_length_of_stay_hours, 0) AS icu_length_of_stay_hours, 
    ps.died_in_hospital
FROM resistant_patients rp
LEFT JOIN icu_stays icu 
    ON rp.subject_id = icu.subject_id 
    AND rp.hadm_id = icu.hadm_id
JOIN patient_status ps 
    ON rp.subject_id = ps.subject_id 
    AND rp.hadm_id = ps.hadm_id
ORDER BY 
    ps.died_in_hospital DESC, 
    rp.resistant_antibiotic_count DESC, 
    icu.icu_length_of_stay_hours DESC, 
    rp.subject_id ASC, 
    rp.hadm_id ASC;
