SELECT "sample_repo_name"
FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS
WHERE "binary" = FALSE
  AND UPPER("sample_path") LIKE '%.SWIFT'
ORDER BY "copies" DESC NULLS LAST
LIMIT 1;