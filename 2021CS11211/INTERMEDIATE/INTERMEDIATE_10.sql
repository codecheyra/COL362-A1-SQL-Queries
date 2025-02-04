WITH first_admission AS ( SELECT subject_id, MIN(admittime) AS first_admittime FROM hosp.admissions 
GROUP BY subject_id ),
kidney_diagnosis AS (
SELECT DISTINCT d.hadm_id, d.subject_id FROM hosp.diagnoses_icd d
JOIN hosp.d_icd_diagnoses dd ON d.icd_code = dd.icd_code AND d.icd_version = dd.icd_version
WHERE LOWER(dd.long_title) LIKE '%kidney%' ),
first_kidney_disease_admissions AS (
SELECT fa.subject_id, fa.first_admittime, a.hadm_id FROM first_admission fa 
JOIN hosp.admissions a ON fa.subject_id = a.subject_id AND fa.first_admittime = a.admittime
JOIN kidney_diagnosis kd ON a.hadm_id = kd.hadm_id
),
readmitted_patients AS (
SELECT DISTINCT fa.subject_id FROM first_kidney_disease_admissions fa
JOIN hosp.admissions a ON fa.subject_id = a.subject_id AND a.admittime > fa.first_admittime
)
SELECT rp.subject_id FROM readmitted_patients rp
ORDER BY rp.subject_id
LIMIT 100;