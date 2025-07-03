WITH total_files AS (
    SELECT COUNT(DISTINCT f."id") AS "total_readme_files"
    FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES" f
    JOIN (
        SELECT DISTINCT "repo_name"
        FROM "GITHUB_REPOS"."GITHUB_REPOS"."LANGUAGES"
        WHERE "language" NOT ILIKE '%python%'
    ) filtered_repos
    ON f."repo_name" = filtered_repos."repo_name"
    WHERE f."path" ILIKE '%readme.md%'
),
copyright_files AS (
    SELECT COUNT(DISTINCT c."id") AS "total_copyright_files"
    FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_CONTENTS" c
    WHERE c."id" IN (
        SELECT DISTINCT f."id"
        FROM "GITHUB_REPOS"."GITHUB_REPOS"."SAMPLE_FILES" f
        JOIN (
            SELECT DISTINCT "repo_name"
            FROM "GITHUB_REPOS"."GITHUB_REPOS"."LANGUAGES"
            WHERE "language" NOT ILIKE '%python%'
        ) filtered_repos
        ON f."repo_name" = filtered_repos."repo_name"
        WHERE f."path" ILIKE '%readme.md%'
    )
    AND c."content" ILIKE '%Copyright (c)%'
)
SELECT 
    (copyright_files."total_copyright_files" * 1.0 / total_files."total_readme_files") AS "proportion"
FROM total_files, copyright_files;