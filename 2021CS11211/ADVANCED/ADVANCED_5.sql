WITH relevant_procedures AS (
    SELECT 
        p.subject_id, 
        p.hadm_id, 
        p.icd_code, 
        TO_DATE(a.admittime::text, 'YYYY-MM-DD') AS procedure_date
    FROM 
        procedures_icd p
    JOIN 
        admissions a ON p.subject_id = a.subject_id AND p.hadm_id = a.hadm_id
    WHERE 
        p.icd_code LIKE '0%' OR p.icd_code LIKE '1%' OR p.icd_code LIKE '2%'
),
relevant_medications AS (
    SELECT 
        pr.subject_id, 
        pr.hadm_id, 
        pr.drug, 
        pr.starttime::date AS med_date
    FROM 
        prescriptions pr
),
procedure_medication_pairs AS (
    SELECT 
        rp.subject_id, 
        rp.hadm_id, 
        rp.icd_code, 
        rp.procedure_date, 
        rm.drug, 
        rm.med_date
    FROM 
        relevant_procedures rp
    JOIN 
        relevant_medications rm ON rp.subject_id = rm.subject_id AND rp.hadm_id = rm.hadm_id
    WHERE 
        rm.med_date BETWEEN rp.procedure_date AND rp.procedure_date + INTERVAL '1 day'
),
eligible_admissions AS (
    SELECT 
        pmp.subject_id, 
        pmp.hadm_id
    FROM 
        procedure_medication_pairs pmp
    GROUP BY 
        pmp.subject_id, pmp.hadm_id
    HAVING 
        COUNT(DISTINCT pmp.drug) >= 2
),
distinct_diagnoses AS (
    SELECT 
        d.subject_id, 
        d.hadm_id, 
        COUNT(DISTINCT d.icd_code) AS distinct_diagnoses
    FROM 
        diagnoses_icd d
    GROUP BY 
        d.subject_id, d.hadm_id
),
distinct_procedures AS (
    SELECT 
        p.subject_id, 
        p.hadm_id, 
        COUNT(DISTINCT p.icd_code) AS distinct_procedures
    FROM 
        procedures_icd p
    GROUP BY 
        p.subject_id, p.hadm_id
),
time_gaps AS (
    SELECT 
        pmp.subject_id, 
        pmp.hadm_id, 
        MIN(pmp.procedure_date) AS first_procedure_date, 
        MAX(rm.med_date) AS last_medication_date,
        MAX(rm.med_date) - MIN(pmp.procedure_date) AS time_gap
    FROM 
        procedure_medication_pairs pmp
    JOIN 
        relevant_medications rm ON pmp.subject_id = rm.subject_id AND pmp.hadm_id = rm.hadm_id
    GROUP BY 
        pmp.subject_id, pmp.hadm_id
)
SELECT 
    ea.subject_id, 
    ea.hadm_id, 
    dd.distinct_diagnoses, 
    dp.distinct_procedures, 
    tg.time_gap
FROM 
    eligible_admissions ea
JOIN 
    distinct_diagnoses dd ON ea.subject_id = dd.subject_id AND ea.hadm_id = dd.hadm_id
JOIN 
    distinct_procedures dp ON ea.subject_id = dp.subject_id AND ea.hadm_id = dp.hadm_id
JOIN 
    time_gaps tg ON ea.subject_id = tg.subject_id AND ea.hadm_id = tg.hadm_id
ORDER BY 
    dd.distinct_diagnoses DESC, 
    dp.distinct_procedures DESC, 
    tg.time_gap ASC, 
    ea.subject_id, 
    ea.hadm_id;