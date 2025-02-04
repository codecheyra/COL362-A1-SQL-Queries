SELECT DISTINCT h.hcpcs_cd, 
h.short_description
FROM hosp.hcpcsevents h
JOIN hosp.d_hcpcs d ON h.hcpcs_cd = d.code
WHERE LOWER(d.short_description) LIKE '%hospital observation%'
ORDER BY h.hcpcs_cd, h.short_description;