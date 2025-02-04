WITH RECURSIVE overlapping_admissions AS (
    SELECT DISTINCT
        a1.subject_id AS subject_id1,
        a2.subject_id AS subject_id2
    FROM hosp.admissions a1
    JOIN hosp.admissions a2
    ON a1.subject_id <> a2.subject_id
    AND a1.admittime < a2.dischtime
    AND a2.admittime < a1.dischtime
),
shortest_paths AS (
    SELECT 
        10037861 AS start_id, 
        subject_id2 AS connected_id, 
        1 AS path_length, 
        ARRAY[10037861, subject_id2] AS visited_nodes
    FROM overlapping_admissions
    WHERE subject_id1 = 10037861
    UNION ALL
    SELECT 
        sp.start_id, 
        oa.subject_id2 AS connected_id, 
        sp.path_length + 1 AS path_length, 
        sp.visited_nodes || oa.subject_id2
    FROM shortest_paths sp
    JOIN overlapping_admissions oa
    ON sp.connected_id = oa.subject_id1
    WHERE NOT oa.subject_id2 = ANY(sp.visited_nodes)
)
SELECT DISTINCT 
    start_id, 
    connected_id, 
    MIN(path_length) AS path_length
FROM shortest_paths
GROUP BY start_id, connected_id
ORDER BY path_length ASC, connected_id ASC;
