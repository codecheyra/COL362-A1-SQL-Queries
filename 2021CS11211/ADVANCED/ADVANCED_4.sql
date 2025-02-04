WITH transfer_chains AS (
    SELECT 
        subject_id, 
        hadm_id, 
        ARRAY_AGG(careunit ORDER BY intime) AS transfers
    FROM 
        transfers
    GROUP BY 
        subject_id, hadm_id
),
longest_chain_length AS (
    SELECT 
        MAX(CARDINALITY(transfers)) AS max_chain_length
    FROM 
        transfer_chains
),
longest_chain_patients AS (
    SELECT 
        tc.subject_id, 
        tc.hadm_id, 
        tc.transfers
    FROM 
        transfer_chains tc
    JOIN 
        longest_chain_length lcl ON CARDINALITY(tc.transfers) = lcl.max_chain_length
)
SELECT 
    subject_id, 
    hadm_id, 
    transfers
FROM 
    longest_chain_patients
ORDER BY 
    CARDINALITY(transfers) ASC, 
    hadm_id ASC, 
    subject_id ASC;