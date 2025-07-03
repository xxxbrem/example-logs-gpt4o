WITH ValidJSON AS (
    SELECT 
        "id", 
        TRY_PARSE_JSON("content") AS "content_json"
    FROM 
        GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS
    WHERE 
        TRY_PARSE_JSON("content") IS NOT NULL
),
RequireSection AS (
    SELECT 
        "id", 
        "content_json":"require" AS "require_packages"
    FROM 
        ValidJSON
    WHERE 
        "content_json":"require" IS NOT NULL AND TYPEOF("content_json":"require") = 'OBJECT'
),
FlattenedPackages AS (
    SELECT 
        "id",
        VALUE::TEXT AS "package_name"
    FROM 
        RequireSection,
        TABLE(FLATTEN(INPUT => "require_packages"))
)
SELECT 
    "package_name", 
    COUNT(*) AS "frequency"
FROM 
    FlattenedPackages
GROUP BY 
    "package_name"
ORDER BY 
    "frequency" DESC NULLS LAST;