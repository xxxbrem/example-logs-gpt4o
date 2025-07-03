WITH PythonRepos AS (
    -- Filter repositories that primarily use Python
    SELECT DISTINCT l."repo_name"
    FROM GITHUB_REPOS.GITHUB_REPOS.LANGUAGES l
    WHERE l."language" ILIKE '%Python%'
),
ReadmeLines AS (
    -- Get non-empty, non-commented lines from README.md files in Python repositories
    SELECT c."content", c."sample_repo_name" AS "repo_name"
    FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS c
    JOIN GITHUB_REPOS.GITHUB_REPOS.SAMPLE_FILES f ON c."id" = f."id"
    WHERE f."path" ILIKE '%README.md'
      AND c."content" IS NOT NULL
      AND c."content" NOT ILIKE '#%'
      AND c."content" NOT ILIKE '//%'
      AND c."sample_repo_name" IN (SELECT "repo_name" FROM PythonRepos)
),
LineOccurrences AS (
    -- Count occurrences of unique lines and join programming languages used in each repository
    SELECT rl."content", 
           COUNT(rl."content") AS "count_occurrences",
           LISTAGG(DISTINCT l."language", ', ') WITHIN GROUP (ORDER BY l."language") AS "languages_used"
    FROM ReadmeLines rl
    JOIN GITHUB_REPOS.GITHUB_REPOS.LANGUAGES l ON rl."repo_name" = l."repo_name"
    GROUP BY rl."content"
)
-- Retrieve the top 5 most frequently occurring lines, sorted by frequency and relevant languages
SELECT "content", 
       "count_occurrences", 
       "languages_used"
FROM LineOccurrences
ORDER BY "count_occurrences" DESC NULLS LAST
LIMIT 5;