SELECT d.icd_code, d.icd_version
FROM hosp.diagnoses_icd d
INTERSECT
SELECT p.icd_code, p.icd_version
FROM hosp.procedures_icd p
ORDER BY icd_code, icd_version;