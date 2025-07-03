-- Extract and count the frequency of all package names listed in the "require" section of JSON-formatted content
SELECT 
    value AS "package_name",
    COUNT(*) AS "frequency"
FROM 
    GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS,
    LATERAL FLATTEN(input => TRY_PARSE_JSON("content"):"require")
WHERE 
    TRY_PARSE_JSON("content") IS NOT NULL
    AND TRY_PARSE_JSON("content"):"require" IS NOT NULL
GROUP BY 
    value
ORDER BY 
    "frequency" DESC NULLS LAST;