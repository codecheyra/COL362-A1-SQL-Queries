WITH i10_diagnoses AS (
    SELECT 
        subject_id, 
        hadm_id, 
        ROW_NUMBER() OVER (PARTITION BY subject_id ORDER BY hadm_id) AS rn
    FROM 
        diagnoses_icd
    WHERE 
        icd_code LIKE 'I10%'
),
i50_diagnoses AS (
    SELECT 
        subject_id, 
        hadm_id, 
        ROW_NUMBER() OVER (PARTITION BY subject_id ORDER BY hadm_id) AS rn
    FROM 
        diagnoses_icd
    WHERE 
        icd_code LIKE 'I50%'
),
eligible_patients AS (
    SELECT 
        i10.subject_id, 
        i10.hadm_id AS i10_hadm_id, 
        i50.hadm_id AS i50_hadm_id
    FROM 
        i10_diagnoses i10
    JOIN 
        i50_diagnoses i50 ON i10.subject_id = i50.subject_id
    WHERE 
        i10.rn = 1 AND i50.rn = (SELECT COUNT(*) FROM i50_diagnoses WHERE subject_id = i10.subject_id)
        AND (SELECT COUNT(DISTINCT hadm_id) FROM admissions WHERE subject_id = i10.subject_id AND hadm_id BETWEEN i10.hadm_id AND i50.hadm_id) >= 2
),
intermediate_admissions AS (
    SELECT 
        a.subject_id, 
        a.hadm_id
    FROM 
        admissions a
    JOIN 
        eligible_patients ep ON a.subject_id = ep.subject_id
    WHERE 
        a.hadm_id > ep.i10_hadm_id AND a.hadm_id < ep.i50_hadm_id
),
distinct_drugs AS (
    SELECT 
        pr.subject_id, 
        pr.hadm_id, 
        pr.drug
    FROM 
        prescriptions pr
    JOIN 
        intermediate_admissions ia ON pr.subject_id = ia.subject_id AND pr.hadm_id = ia.hadm_id
)
SELECT 
    subject_id, 
    hadm_id AS admission_id, 
    drug
FROM 
    distinct_drugs
ORDER BY 
    subject_id ASC, 
    admission_id ASC, 
    drug ASC;