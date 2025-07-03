WITH LatestVersions AS (
    SELECT
        pv."Name",
        pv."Version",
        pv."SnapshotAt",
        pv."VersionInfo"
    FROM DEPS_DEV_V1.DEPS_DEV_V1.PACKAGEVERSIONS pv
    WHERE pv."VersionInfo"::VARIANT:"IsRelease" = TRUE
),
LatestSnapshot AS (
    SELECT 
        "Name",
        "Version",
        MAX("SnapshotAt") AS "LatestSnapshotAt"
    FROM LatestVersions
    GROUP BY "Name", "Version"
),
GitHubProjects AS (
    SELECT
        pp."Name" AS "PackageName",
        pp."Version",
        pp."ProjectName" AS "GitHubRepo",
        p."StarsCount"
    FROM DEPS_DEV_V1.DEPS_DEV_V1.PACKAGEVERSIONTOPROJECT pp
    JOIN DEPS_DEV_V1.DEPS_DEV_V1.PROJECTS p
        ON pp."ProjectType" = p."Type" AND pp."ProjectName" = p."Name"
    WHERE pp."System" = 'NPM' AND pp."ProjectType" = 'GITHUB'
),
FilteredProjects AS (
    SELECT
        g."PackageName",
        g."Version",
        g."GitHubRepo",
        g."StarsCount"
    FROM GitHubProjects g
    JOIN LatestSnapshot ls
        ON g."PackageName" = ls."Name" AND g."Version" = ls."Version"
),
TopProjects AS (
    SELECT
        "PackageName",
        "Version",
        "GitHubRepo",
        "StarsCount"
    FROM FilteredProjects
    ORDER BY "StarsCount" DESC NULLS LAST
    LIMIT 8
)
SELECT *
FROM TopProjects;