WITH prescribed_medications AS (
    SELECT 
        subject_id, 
        hadm_id
    FROM 
        hosp.prescriptions
    WHERE 
        LOWER(drug) IN ('oxycodone (immediate release)', 'insulin')
    GROUP BY 
        subject_id, hadm_id
    HAVING 
        COUNT(DISTINCT LOWER(drug)) = 2
),
bmi_data AS (
    SELECT 
        omr.subject_id, 
        omr.chartdate, 
        omr.result_value::NUMERIC AS bmi
    FROM
        hosp.omr omr
    JOIN 
        prescribed_medications pm ON omr.subject_id = pm.subject_id
    WHERE 
        omr.result_name = 'BMI (kg/m2)'
)
SELECT 
    ROUND(AVG(bmi), 10) AS avg_bmi
FROM 
    bmi_data;