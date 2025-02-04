WITH earliest_admissions AS ( SELECT subject_id, hadm_id, admittime, dischtime FROM hosp.admissions
ORDER BY admittime LIMIT 200
) ,
overlapping_admissions AS ( SELECT a.subject_id AS subject_id1, b.subject_id AS subject_id2,
a.hadm_id AS hadm_id1, b.hadm_id AS hadm_id2 FROM earliest_admissions a
JOIN earliest_admissions b ON a.subject_id < b.subject_id AND a.admittime < b.dischtime AND b.admittime < a.dischtime
),
shared_icd AS ( SELECT a.subject_id1, a.subject_id2 FROM overlapping_admissions a
JOIN hosp.diagnoses_icd d1 ON a.hadm_id1 = d1.hadm_id
JOIN hosp.diagnoses_icd d2 ON a.hadm_id2 = d2.hadm_id
WHERE d1.icd_code = d2.icd_code AND d1.icd_version = d2.icd_version
GROUP BY a.subject_id1, a.subject_id2
)
SELECT subject_id1, subject_id2 FROM shared_icd
ORDER BY subject_id1 ASC, subject_id2 ASC;