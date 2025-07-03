SELECT DISTINCT pvp."Name", pvp."Version", pr."StarsCount"
FROM DEPS_DEV_V1.DEPS_DEV_V1.PACKAGEVERSIONTOPROJECT pvp
INNER JOIN DEPS_DEV_V1.DEPS_DEV_V1.PROJECTS pr
  ON pvp."ProjectType" = pr."Type" AND pvp."ProjectName" = pr."Name"
WHERE pvp."System" = 'NPM'
  AND pvp."RelationType" = 'SOURCE_REPO_TYPE'
  AND pvp."Version" IN (
    SELECT DISTINCT pv."Version"
    FROM DEPS_DEV_V1.DEPS_DEV_V1.PACKAGEVERSIONS pv
    WHERE pv."VersionInfo"::VARIANT:"IsRelease"::BOOLEAN = TRUE
  )
ORDER BY pr."StarsCount" DESC NULLS LAST
LIMIT 8;