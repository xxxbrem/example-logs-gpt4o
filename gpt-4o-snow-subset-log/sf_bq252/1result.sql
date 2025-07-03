SELECT sc."sample_repo_name", sc."copies", sf."id", sf."path"
FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS" sc
JOIN "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES" sf
ON sc."id" = sf."id"
WHERE sc."binary" = False
AND sf."path" ILIKE '%.swift%'
ORDER BY sc."copies" DESC NULLS LAST
LIMIT 1;