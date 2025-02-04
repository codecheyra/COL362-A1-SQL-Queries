SELECT ph.pharmacy_id
FROM hosp.pharmacy ph
LEFT JOIN hosp.prescriptions pr ON ph.pharmacy_id = pr.pharmacy_id
WHERE pr.pharmacy_id IS NULL
ORDER BY ph.pharmacy_id;