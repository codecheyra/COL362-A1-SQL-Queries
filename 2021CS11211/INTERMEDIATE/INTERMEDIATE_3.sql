SELECT 
    COALESCE(p.caregiver_id, c.caregiver_id, d.caregiver_id) AS caregiver_id,
    COALESCE(p.procedureevents_count, 0) AS procedureevents_count,
    COALESCE(c.chartevents_count, 0) AS chartevents_count,
    COALESCE(d.datetimeevents_count, 0) AS datetimeevents_count
FROM 
    (SELECT caregiver_id, COUNT(*) AS procedureevents_count
     FROM icu.procedureevents
     GROUP BY caregiver_id) p
FULL OUTER JOIN 
    (SELECT caregiver_id, COUNT(*) AS chartevents_count
     FROM icu.chartevents
     GROUP BY caregiver_id) c
ON p.caregiver_id = c.caregiver_id
FULL OUTER JOIN 
    (SELECT caregiver_id, COUNT(*) AS datetimeevents_count
     FROM icu.datetimeevents
     GROUP BY caregiver_id) d
ON COALESCE(p.caregiver_id, c.caregiver_id) = d.caregiver_id
ORDER BY 
    caregiver_id, procedureevents_count, chartevents_count, datetimeevents_count;