WITH overlapping_admissions AS (
SELECT a.subject_id AS subject_id1, b.subject_id AS subject_id2
FROM hosp.admissions a
JOIN hosp.admissions b ON a.subject_id != b.subject_id AND a.admittime < b.dischtime AND b.admittime < a.dischtime
)
SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END AS path_exists
FROM overlapping_admissions
WHERE subject_id1 = 10006580 OR subject_id2 = 10006580;