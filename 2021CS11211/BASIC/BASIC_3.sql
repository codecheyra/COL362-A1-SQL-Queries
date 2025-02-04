SELECT a.hadm_id, p.gender, CONCAT(DATE_PART('day', a.dischtime::timestamp - a.admittime::timestamp), 'days, ', TO_CHAR(a.dischtime::timestamp - a.admittime::timestamp, 'HH24:MI:SS')) AS duration
FROM hosp.admissions a
JOIN hosp.patients p ON a.subject_id = p.subject_id
WHERE a.dischtime IS NOT NULL
ORDER BY duration, a.hadm_id;