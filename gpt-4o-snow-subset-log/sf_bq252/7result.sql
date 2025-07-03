SELECT sc."sample_repo_name", sc."sample_path", sc."copies"
FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS sc
JOIN GITHUB_REPOS.GITHUB_REPOS.LANGUAGES lang
ON sc."sample_repo_name" = lang."repo_name"
WHERE sc."binary" = False
AND sc."sample_path" ILIKE '%.swift%'
AND lang."language" ILIKE '%Swift%'
ORDER BY sc."copies" DESC NULLS LAST
LIMIT 1;