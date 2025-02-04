WITH RECURSIVE earliest_admissions AS (
    SELECT * FROM hosp.admissions
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
bfs AS (
    SELECT subject_id1 AS current_node, subject_id2 AS next_node, 1 AS path_length, ARRAY[subject_id1] AS visited_nodes
    FROM overlapping_admissions
    WHERE subject_id1 = 10038081 
    UNION ALL
    SELECT oa.subject_id1 AS current_node, oa.subject_id2 AS next_node, bfs.path_length + 1 AS path_length, bfs.visited_nodes || oa.subject_id2
    FROM overlapping_admissions oa
    JOIN bfs
    ON oa.subject_id1 = bfs.next_node
    WHERE NOT oa.subject_id2 = ANY(bfs.visited_nodes)
)
SELECT COUNT(DISTINCT next_node) AS count
FROM bfs;
