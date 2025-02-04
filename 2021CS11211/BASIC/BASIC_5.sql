SELECT COUNT(DISTINCT a.hadm_id) AS count
FROM hosp.emar_detail ed
JOIN hosp.admissions a ON ed.subject_id = a.subject_id
WHERE ed.reason_for_no_barcode = 'Barcode Damaged'
AND NOT marital_status = 'MARRIED';