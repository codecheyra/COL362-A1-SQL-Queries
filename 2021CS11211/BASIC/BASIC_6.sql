SELECT p.subject_id, 
COUNT(i.stay_id) AS count
FROM hosp.patients p
LEFT JOIN icu.icustays i ON p.subject_id = i.subject_id
GROUP BY p.subject_id
ORDER BY count, p.subject_id;