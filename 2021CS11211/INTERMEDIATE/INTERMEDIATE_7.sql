WITH first_last_admissions AS (
    SELECT 
        subject_id, 
        MIN(admittime) AS first_admit_time,
        MAX(admittime) AS last_admit_time
    FROM hosp.admissions
    GROUP BY subject_id
),
matching_diagnoses AS (
    SELECT 
        f.subject_id,
        p.gender
    FROM first_last_admissions f
    JOIN hosp.patients p ON f.subject_id = p.subject_id
    JOIN hosp.diagnoses_icd d1 ON f.subject_id = d1.subject_id
    JOIN hosp.admissions a1 ON d1.hadm_id = a1.hadm_id AND a1.admittime = f.first_admit_time
    JOIN hosp.diagnoses_icd d2 ON f.subject_id = d2.subject_id
    JOIN hosp.admissions a2 ON d2.hadm_id = a2.hadm_id AND a2.admittime = f.last_admit_time
    WHERE d1.icd_code = d2.icd_code
    GROUP BY f.subject_id, p.gender
),
gender_distribution AS (
    SELECT 
        gender, 
        COUNT(*) AS count_per_gender,
        (SELECT COUNT(*) FROM matching_diagnoses) AS total_count
    FROM matching_diagnoses
    GROUP BY gender
)
SELECT 
    gender, 
    ROUND((count_per_gender::NUMERIC / total_count) * 100, 2) AS percentage
FROM gender_distribution
ORDER BY percentage DESC;