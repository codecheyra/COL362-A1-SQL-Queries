WITH patient_procedures AS (
    SELECT 
        subject_id, 
        hadm_id, 
        COUNT(DISTINCT icd_code) AS distinct_procedures_count
    FROM 
        procedures_icd
    GROUP BY 
        subject_id, hadm_id
    HAVING 
        COUNT(DISTINCT icd_code) > 1
),
patient_diagnoses AS (
    SELECT 
        subject_id, 
        hadm_id
    FROM 
        diagnoses_icd
    WHERE 
        icd_code LIKE 'T81%'
    GROUP BY 
        subject_id, hadm_id
),
patient_transfers AS (
    SELECT 
        subject_id, 
        hadm_id, 
        COUNT(*) AS transfer_count
    FROM 
        transfers
    GROUP BY 
        subject_id, hadm_id
),
eligible_patients AS (
    SELECT 
        pp.subject_id, 
        pp.hadm_id, 
        pp.distinct_procedures_count, 
        pt.transfer_count
    FROM 
        patient_procedures pp
    JOIN 
        patient_diagnoses pd ON pp.subject_id = pd.subject_id AND pp.hadm_id = pd.hadm_id
    JOIN 
        patient_transfers pt ON pp.subject_id = pt.subject_id AND pp.hadm_id = pt.hadm_id
),
average_transfers AS (
    SELECT 
        subject_id, 
        AVG(transfer_count) AS avg_transfers
    FROM 
        eligible_patients
    GROUP BY 
        subject_id
),
filtered_patients AS (
    SELECT 
        ep.subject_id, 
        ep.distinct_procedures_count, 
        ep.transfer_count
    FROM 
        eligible_patients ep
    JOIN 
        average_transfers at ON ep.subject_id = at.subject_id
    WHERE 
        ep.transfer_count >= at.avg_transfers
)
SELECT 
    subject_id, 
    distinct_procedures_count, 
    AVG(transfer_count) AS average_transfers
FROM 
    filtered_patients
GROUP BY 
    subject_id, distinct_procedures_count
ORDER BY 
    average_transfers DESC, 
    distinct_procedures_count DESC, 
    subject_id ASC;