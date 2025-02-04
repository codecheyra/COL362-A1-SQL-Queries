WITH drug_prescriptions AS (
    SELECT 
        subject_id, 
        hadm_id,
        CASE 
            WHEN LOWER(drug) = 'amlodipine' THEN 'amlodipine'
            WHEN LOWER(drug) = 'lisinopril' THEN 'lisinopril'
        END AS drug
    FROM
        hosp.prescriptions
    WHERE 
        LOWER(drug) IN ('amlodipine', 'lisinopril')
),
drug_summary AS (
    SELECT 
        subject_id, 
        hadm_id,
        STRING_AGG(drug, ', ') AS drugs
    FROM 
        drug_prescriptions
    GROUP BY 
        subject_id, hadm_id
),
service_transfers AS (
    SELECT 
        subject_id, 
        hadm_id,
        curr_service,
        prev_service,
        ROW_NUMBER() OVER (PARTITION BY subject_id, hadm_id ORDER BY transfertime) AS rn
    FROM 
        hosp.services
),
service_sequence AS (
    SELECT 
        st.subject_id, 
        st.hadm_id,
        ARRAY_AGG(st.curr_service ORDER BY st.rn) AS services
    FROM 
        service_transfers st
    WHERE 
        st.prev_service IS NULL OR st.prev_service != st.curr_service
    GROUP BY 
        st.subject_id, st.hadm_id
)
SELECT 
    ds.subject_id, 
    ds.hadm_id,
    CASE 
        WHEN ds.drugs = 'amlodipine' THEN 'amlodipine'
        WHEN ds.drugs = 'lisinopril' THEN 'lisinopril'
        ELSE 'both'
    END AS drug,
    COALESCE(ss.services, ARRAY[]::text[]) AS services
FROM 
    drug_summary ds
LEFT JOIN 
    service_sequence ss ON ds.subject_id = ss.subject_id AND ds.hadm_id = ss.hadm_id
ORDER BY 
    ds.subject_id ASC, 
    ds.hadm_id ASC;