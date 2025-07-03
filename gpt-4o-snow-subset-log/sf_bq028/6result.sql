WITH LatestReleases AS (
    SELECT 
        DISTINCT "Name", 
        "Version", 
        "VersionInfo"::VARIANT:"IsRelease" AS "IsRelease"
    FROM DEPS_DEV_V1.DEPS_DEV_V1.PACKAGEVERSIONS
    WHERE "System" = 'NPM' AND "VersionInfo"::VARIANT:"IsRelease" = true
),
PackageProjects AS (
    SELECT
        "Name" AS "PackageName",
        "Version" AS "PackageVersion",
        "ProjectName" AS "GitHubProjectName"
    FROM DEPS_DEV_V1.DEPS_DEV_V1.PACKAGEVERSIONTOPROJECT
    WHERE "System" = 'NPM' AND "ProjectType" = 'GITHUB' AND "RelationType" = 'SOURCE_REPO_TYPE'
),
ProjectStars AS (
    SELECT
        "Name" AS "GitHubProjectName",
        "StarsCount"
    FROM DEPS_DEV_V1.DEPS_DEV_V1.PROJECTS
)
SELECT 
    L."Name" AS "PackageName",
    L."Version" AS "PackageVersion",
    P."GitHubProjectName",
    S."StarsCount"
FROM LatestReleases L
JOIN PackageProjects P 
    ON L."Name" = P."PackageName" AND L."Version" = P."PackageVersion"
JOIN ProjectStars S
    ON P."GitHubProjectName" = S."GitHubProjectName"
ORDER BY S."StarsCount" DESC NULLS LAST
LIMIT 8;