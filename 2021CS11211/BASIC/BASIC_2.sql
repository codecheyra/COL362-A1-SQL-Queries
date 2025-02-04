SELECT COUNT(DISTINCT subject_id) AS count, 
EXTRACT(YEAR FROM admittime::timestamp) AS year
FROM hosp.admissions
GROUP BY year
ORDER BY count DESC, year
LIMIT 5;