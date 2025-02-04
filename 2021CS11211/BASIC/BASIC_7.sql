SELECT p.subject_id, MAX(a.hadm_id) AS latest_hadm_id, p.dod
FROM hosp.patients p
JOIN hosp.admissions a ON p.subject_id = a.subject_id
WHERE p.dod IS NOT NULL
GROUP BY p.subject_id, p.dod
ORDER BY p.subject_id;