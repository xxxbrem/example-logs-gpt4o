WITH LatestReleasedVersions AS (
    SELECT DISTINCT 
        PV."Name", 
        PV."Version", 
        PV."VersionInfo"::VARIANT:"IsRelease"::BOOLEAN AS "IsRelease",
        P."StarsCount"
    FROM 
        "DEPS_DEV_V1"."DEPS_DEV_V1"."PACKAGEVERSIONS" PV
    LEFT JOIN 
        "DEPS_DEV_V1"."DEPS_DEV_V1"."PACKAGEVERSIONTOPROJECT" PVTP
        ON PV."Name" = PVTP."Name" AND PV."Version" = PVTP."Version"
    LEFT JOIN 
        "DEPS_DEV_V1"."DEPS_DEV_V1"."PROJECTS" P
        ON PVTP."ProjectType" = P."Type" AND PVTP."ProjectName" = P."Name"
    WHERE 
        PV."System" = 'NPM' 
        AND PV."VersionInfo"::VARIANT:"IsRelease"::BOOLEAN = TRUE
),
RankedPackages AS (
    SELECT 
        "Name", 
        "Version", 
        "StarsCount",
        ROW_NUMBER() OVER (ORDER BY "StarsCount" DESC NULLS LAST) AS "Rank"
    FROM 
        LatestReleasedVersions
)
SELECT 
    "Name", 
    "Version", 
    "StarsCount"
FROM 
    RankedPackages
WHERE 
    "Rank" <= 8
ORDER BY 
    "StarsCount" DESC NULLS LAST;