SELECT d.subject_id, COUNT(DISTINCT d.hadm_id) AS count_admissions, 
EXTRACT(YEAR FROM a.admittime::TIMESTAMP) AS year
FROM hosp.diagnoses_icd d
JOIN hosp.admissions a ON d.hadm_id = a.hadm_id
JOIN hosp.d_icd_diagnoses di ON d.icd_code = di.icd_code
WHERE LOWER(di.long_title) LIKE '%infection%'
GROUP BY d.subject_id, EXTRACT(YEAR FROM a.admittime::TIMESTAMP)
HAVING COUNT(DISTINCT d.hadm_id) > 1
ORDER BY year, count_admissions DESC;
