WITH e10_e11_diagnoses AS (
    SELECT 
        subject_id, 
        hadm_id
    FROM
        diagnoses_icd
    WHERE 
        icd_code LIKE 'E10%' OR icd_code LIKE 'E11%'
),
n18_diagnoses AS (
    SELECT 
        subject_id, 
        hadm_id
    FROM 
        diagnoses_icd
    WHERE 
        icd_code LIKE 'N18%'
),
eligible_patients AS (
    SELECT 
        e.subject_id, 
        e.hadm_id
    FROM 
        e10_e11_diagnoses e
    JOIN 
        n18_diagnoses n ON e.subject_id = n.subject_id
    WHERE 
        e.hadm_id <= n.hadm_id
),
distinct_diagnoses AS (
    SELECT 
        subject_id, 
        hadm_id, 
        icd_code, 
        'diagnoses' AS diagnoses_or_procedure
    FROM 
        diagnoses_icd
    WHERE 
        (subject_id, hadm_id) IN (SELECT subject_id, hadm_id FROM eligible_patients)
),
distinct_procedures AS (
    SELECT 
        subject_id, 
        hadm_id, 
        icd_code, 
        'procedures' AS diagnoses_or_procedure
    FROM 
        procedures_icd
    WHERE 
        (subject_id, hadm_id) IN (SELECT subject_id, hadm_id FROM eligible_patients)
),
combined_results AS (
    SELECT 
        subject_id, 
        hadm_id, 
        icd_code, 
        diagnoses_or_procedure
    FROM 
        distinct_diagnoses
    UNION
    SELECT 
        subject_id, 
        hadm_id, 
        icd_code, 
        diagnoses_or_procedure
    FROM 
        distinct_procedures
)
SELECT 
    subject_id, 
    hadm_id AS admission_id, 
    diagnoses_or_procedure, 
    icd_code
FROM 
    combined_results
ORDER BY 
    subject_id ASC, 
    admission_id ASC, 
    icd_code, 
    diagnoses_or_procedure ASC;