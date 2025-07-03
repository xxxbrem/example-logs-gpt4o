WITH LatestReleases AS (
    SELECT 
        pvt."Name", 
        pvt."Version", 
        MAX(pvt."SnapshotAt") AS LatestSnapshot 
    FROM 
        "DEPS_DEV_V1"."DEPS_DEV_V1"."PACKAGEVERSIONS" pvt 
    JOIN 
        "DEPS_DEV_V1"."DEPS_DEV_V1"."PACKAGEVERSIONTOPROJECT" pvtp 
    ON 
        pvt."Name" = pvtp."Name" AND pvt."Version" = pvtp."Version"
    WHERE 
        pvt."System" = 'NPM' 
        AND pvt."VersionInfo":IsRelease = TRUE
    GROUP BY 
        pvt."Name", 
        pvt."Version"
)
SELECT 
    pr."Name" AS PackageName, 
    pr."Version" AS PackageVersion, 
    pj."Name" AS ProjectName, 
    pj."StarsCount" AS StarsCount
FROM 
    LatestReleases pr
JOIN 
    "DEPS_DEV_V1"."DEPS_DEV_V1"."PACKAGEVERSIONTOPROJECT" pvpr 
ON 
    pr."Name" = pvpr."Name" 
    AND pr."Version" = pvpr."Version"
JOIN 
    "DEPS_DEV_V1"."DEPS_DEV_V1"."PROJECTS" pj 
ON 
    pvpr."ProjectName" = pj."Name"
WHERE 
    pj."Type" = 'GITHUB' 
    AND pj."StarsCount" IS NOT NULL
ORDER BY 
    pj."StarsCount" DESC NULLS LAST
LIMIT 8;