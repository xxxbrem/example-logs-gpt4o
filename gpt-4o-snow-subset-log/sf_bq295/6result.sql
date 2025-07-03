SELECT DISTINCT r."repo_name", SUM(r."watch_count") AS "total_watch_count"
FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS c
JOIN GITHUB_REPOS.GITHUB_REPOS.SAMPLE_REPOS r 
ON c."sample_repo_name" = r."repo_name"
JOIN GITHUB_REPOS.GITHUB_REPOS.LANGUAGES l 
ON r."repo_name" = l."repo_name"
WHERE c."size" < 15000 
AND c."content" ILIKE '%def %' 
AND c."sample_path" ILIKE '%.py%' 
AND l."language" ILIKE '%python%'
GROUP BY r."repo_name"
ORDER BY "total_watch_count" DESC NULLS LAST
LIMIT 3;