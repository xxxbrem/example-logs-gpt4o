SELECT s."sample_repo_name", s."id", s."copies"
FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS" s
JOIN "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES" f
  ON s."id" = f."id"
WHERE s."binary" = FALSE AND f."path" ILIKE '%.swift'
ORDER BY s."copies" DESC NULLS LAST
LIMIT 1;