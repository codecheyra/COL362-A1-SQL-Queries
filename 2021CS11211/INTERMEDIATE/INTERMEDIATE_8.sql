SELECT subject_id, TO_CHAR(AVG(AGE(CAST(dischtime AS TIMESTAMP), CAST(admittime AS TIMESTAMP))), 'DD "days," HH24:MI:SS') AS avg_duration
FROM hosp.admissions GROUP BY subject_id ORDER BY subject_id;