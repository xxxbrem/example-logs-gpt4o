WITH ExtractedPackages AS (
    SELECT 
        TRIM(SPLIT_PART(value, ':', 0), '"') AS package_name
    FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS,
    LATERAL FLATTEN(INPUT => TRY_PARSE_JSON("content"):"require")
    WHERE TRY_PARSE_JSON("content") IS NOT NULL
),
PackageFrequency AS (
    SELECT 
        package_name, 
        COUNT(*) AS frequency
    FROM ExtractedPackages
    GROUP BY package_name
)
SELECT *
FROM PackageFrequency
ORDER BY frequency DESC;