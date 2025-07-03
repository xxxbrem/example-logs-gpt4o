SELECT sf."repo_name", sf."path", sf."id", sc."copies"
FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES" sf
JOIN "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS" sc
ON sf."id" = sc."id"
WHERE sc."binary" = FALSE AND sf."path" ILIKE '%.swift'
ORDER BY sc."copies" DESC NULLS LAST
LIMIT 1;