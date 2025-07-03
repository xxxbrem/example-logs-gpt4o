SELECT 
    f.value::string AS "package_name",
    COUNT(*) AS "frequency"
FROM 
    "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS" t,
    LATERAL FLATTEN(input => TRY_PARSE_JSON(t."content"):"require") f
WHERE 
    TRY_PARSE_JSON(t."content") IS NOT NULL
GROUP BY 
    f.value::string
ORDER BY 
    "frequency" DESC NULLS LAST;