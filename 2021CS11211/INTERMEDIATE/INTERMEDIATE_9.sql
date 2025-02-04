WITH hi AS (SELECT subject_id, pharmacy_id, COUNT(*) AS c FROM hosp.prescriptions
GROUP BY subject_id, pharmacy_id HAVING COUNT(*) > 1
)
SELECT subject_id, pharmacy_id
FROM hi
ORDER BY c DESC, subject_id, pharmacy_id;