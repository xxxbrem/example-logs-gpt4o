WITH LatestVersions AS (
    SELECT 
        "Name", 
        MAX("Version") AS "LatestVersion"
    FROM 
        DEPS_DEV_V1.DEPS_DEV_V1.PACKAGEVERSIONS
    WHERE 
        "System" = 'NPM' 
        AND "VersionInfo"::VARIANT:"IsRelease" = TRUE
    GROUP BY 
        "Name"
),
PopularPackages AS (
    SELECT 
        p."Name" AS "ProjectName", 
        pkg."Name" AS "PackageName", 
        lv."LatestVersion", 
        p."StarsCount"
    FROM 
        DEPS_DEV_V1.DEPS_DEV_V1.PROJECTS p
    JOIN 
        DEPS_DEV_V1.DEPS_DEV_V1.PACKAGEVERSIONTOPROJECT r
        ON p."Name" = r."ProjectName"
    JOIN 
        LatestVersions lv
        ON r."Name" = lv."Name"
    JOIN 
        DEPS_DEV_V1.DEPS_DEV_V1.PACKAGEVERSIONS pkg
        ON lv."Name" = pkg."Name" AND lv."LatestVersion" = pkg."Version"
    WHERE 
        r."System" = 'NPM' 
        AND r."ProjectType" = 'GITHUB' 
        AND p."StarsCount" > 0
)
SELECT 
    "PackageName", 
    "LatestVersion", 
    "StarsCount"
FROM 
    PopularPackages
ORDER BY 
    "StarsCount" DESC NULLS LAST
LIMIT 8;