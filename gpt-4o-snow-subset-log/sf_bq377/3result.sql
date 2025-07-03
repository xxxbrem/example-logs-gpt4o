SELECT 
    value:key AS "package_name", 
    COUNT(*) AS "frequency"
FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS,
     LATERAL FLATTEN(input => TRY_PARSE_JSON("content"):"require")
WHERE TRY_PARSE_JSON("content") IS NOT NULL
  AND "content" ILIKE '%"require"%'
GROUP BY value:key
ORDER BY "frequency" DESC NULLS LAST;