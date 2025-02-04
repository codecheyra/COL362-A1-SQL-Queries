WITH RECURSIVE earliest_admissions AS (
    SELECT *
    FROM hosp.admissions
    ORDER BY admittime
    LIMIT 200
),
overlapping_admissions AS (
    SELECT DISTINCT
        a1.subject_id AS subject_id1,
        a2.subject_id AS subject_id2
    FROM earliest_admissions a1
    JOIN earliest_admissions a2
    ON a1.subject_id <> a2.subject_id
    AND a1.admittime < a2.dischtime
    AND a2.admittime < a1.dischtime
),

max_path_length AS(
SELECT COUNT(DISTINCT subject_id1) as max_length
FROM overlapping_admissions
),
bfs AS (
    SELECT
        subject_id1 AS current_node,
        subject_id2 AS next_node,
        1 AS path_length
    FROM overlapping_admissions
    WHERE subject_id1 = 10038081
    UNION ALL
    SELECT
        oa.subject_id1 AS current_node,
        oa.subject_id2 AS next_node,
        bfs.path_length + 1 AS path_length
    FROM overlapping_admissions oa
    JOIN bfs
    ON oa.subject_id1 = bfs.next_node
    WHERE bfs.path_length<(SELECT max_length FROM max_path_length )+1
)
SELECT MIN(path_length) AS path_length
FROM bfs
WHERE next_node = 10021487;