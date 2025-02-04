WITH input_output_diff AS (
    SELECT 
        ie.subject_id, 
        ie.stay_id, 
        SUM(ie.amount) AS total_input,
        COALESCE(SUM(oe.value), 0) AS total_output
    FROM 
        inputevents ie
    LEFT JOIN  
        outputevents oe ON ie.subject_id = oe.subject_id AND ie.stay_id = oe.stay_id
    GROUP BY 
        ie.subject_id, ie.stay_id
    HAVING 
        SUM(ie.amount) - COALESCE(SUM(oe.value), 0) > 2000
),
distinct_items AS (
    SELECT 
        ie.subject_id, 
        ie.stay_id, 
        ie.itemid AS item_id, 
        'input' AS input_or_output,
        di.label AS description
    FROM 
        inputevents ie
    JOIN 
        d_items di ON ie.itemid = di.itemid
    WHERE 
        (ie.subject_id, ie.stay_id) IN (SELECT subject_id, stay_id FROM input_output_diff)
    UNION
    SELECT 
        oe.subject_id, 
        oe.stay_id, 
        oe.itemid AS item_id, 
        'output' AS input_or_output,
        di.label AS description
    FROM 
        outputevents oe
    JOIN 
        d_items di ON oe.itemid = di.itemid
    WHERE 
        (oe.subject_id, oe.stay_id) IN (SELECT subject_id, stay_id FROM input_output_diff)
)
SELECT 
    subject_id, 
    stay_id, 
    item_id, 
    input_or_output, 
    description
FROM 
    distinct_items
ORDER BY 
    subject_id ASC, 
    stay_id ASC, 
    item_id ASC, 
    input_or_output ASC;