SELECT sc."sample_repo_name", sf."path", sc."copies", sc."id"
FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS" sc
INNER JOIN "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES" sf
ON sc."id" = sf."id"
WHERE sc."binary" = FALSE AND sf."path" ILIKE '%.swift'
ORDER BY sc."copies" DESC NULLS LAST
LIMIT 1;