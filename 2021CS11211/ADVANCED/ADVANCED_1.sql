WITH admission_diagnoses AS (
    SELECT 
        subject_id, 
        hadm_id, 
        STRING_AGG(icd_code, ',') AS diagnosis_set
    FROM 
        diagnoses_icd
    GROUP BY 
        subject_id, hadm_id
),
admission_medications AS (
    SELECT 
        subject_id, 
        hadm_id, 
        STRING_AGG(drug, ',') AS medication_set
    FROM 
        prescriptions
    GROUP BY 
        subject_id, hadm_id
),
admission_details AS (
    SELECT 
        a.subject_id, 
        a.hadm_id, 
        ad.diagnosis_set, 
        am.medication_set
    FROM 
        admissions a
    JOIN 
        admission_diagnoses ad ON a.hadm_id = ad.hadm_id
    JOIN 
        admission_medications am ON a.hadm_id = am.hadm_id
),
distinct_sets AS (
    SELECT 
        subject_id, 
        COUNT(DISTINCT diagnosis_set) AS num_distinct_diagnoses_set_count,
        COUNT(DISTINCT medication_set) AS num_distinct_medications_set_count,
        COUNT(*) AS total_admissions
    FROM 
        admission_details
    GROUP BY 
        subject_id
)
SELECT 
    subject_id, 
    total_admissions, 
    num_distinct_diagnoses_set_count, 
    num_distinct_medications_set_count
FROM 
    distinct_sets
WHERE 
    num_distinct_diagnoses_set_count >= 3 OR num_distinct_medications_set_count >= 3
ORDER BY 
    total_admissions DESC, 
    num_distinct_diagnoses_set_count DESC, 
    subject_id ASC;