WITH LatestReleases AS (
    SELECT
        pv."Name",
        pv."Version",
        pv."SnapshotAt",
        pv."VersionInfo"::VARIANT:"IsRelease" AS "IsRelease"
    FROM DEPS_DEV_V1.DEPS_DEV_V1.PACKAGEVERSIONS pv
    WHERE pv."System" = 'NPM'
),
FilteredLatestReleases AS (
    SELECT
        lr."Name",
        lr."Version",
        lr."SnapshotAt"
    FROM LatestReleases lr
    WHERE lr."IsRelease" = TRUE
),
ProjectStars AS (
    SELECT
        ptp."Name" AS "PackageName",
        ptp."ProjectName",
        proj."StarsCount",
        proj."Type",
        proj."Homepage"
    FROM DEPS_DEV_V1.DEPS_DEV_V1.PACKAGEVERSIONTOPROJECT ptp
    INNER JOIN DEPS_DEV_V1.DEPS_DEV_V1.PROJECTS proj
        ON ptp."ProjectName" = proj."Name"
    WHERE ptp."System" = 'NPM' AND ptp."ProjectType" = 'GITHUB'
),
PackagePopularity AS (
    SELECT
        flr."Name",
        flr."Version",
        ps."StarsCount",
        ps."Homepage"
    FROM FilteredLatestReleases flr
    INNER JOIN ProjectStars ps
        ON flr."Name" = ps."PackageName"
)
SELECT
    "Name" AS "PackageName",
    "Version",
    "StarsCount",
    "Homepage"
FROM PackagePopularity
ORDER BY "StarsCount" DESC NULLS LAST
LIMIT 8;