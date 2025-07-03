SELECT 
    json_data.key AS package_name,
    COUNT(*) AS frequency
FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS c,
     LATERAL FLATTEN(input => TRY_PARSE_JSON(c."content"):"require") json_data
GROUP BY json_data.key
ORDER BY frequency DESC NULLS LAST;