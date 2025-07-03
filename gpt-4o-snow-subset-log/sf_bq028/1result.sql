WITH LatestVersions AS (
    SELECT 
        "Name" AS "PackageName", 
        "Version", 
        "System", 
        "VersionInfo"
    FROM DEPS_DEV_V1.DEPS_DEV_V1.PACKAGEVERSIONS
    WHERE 
        "System" = 'NPM' 
        AND "VersionInfo" IS NOT NULL
        AND "VersionInfo"::VARIANT:"IsRelease" = TRUE
),
PackageToProject AS (
    SELECT 
        p."PackageName", 
        p."Version", 
        pt."ProjectName"
    FROM LatestVersions p
    JOIN DEPS_DEV_V1.DEPS_DEV_V1.PACKAGEVERSIONTOPROJECT pt
    ON p."PackageName" = pt."Name" 
       AND p."Version" = pt."Version" 
       AND pt."System" = 'NPM'
),
ProjectWithStars AS (
    SELECT 
        pp."PackageName", 
        pp."Version", 
        pr."StarsCount"
    FROM PackageToProject pp
    JOIN DEPS_DEV_V1.DEPS_DEV_V1.PROJECTS pr
    ON pp."ProjectName" = pr."Name"
    WHERE pr."StarsCount" IS NOT NULL
)
SELECT 
    "PackageName", 
    "Version", 
    "StarsCount"
FROM ProjectWithStars
ORDER BY "StarsCount" DESC NULLS LAST
LIMIT 8;