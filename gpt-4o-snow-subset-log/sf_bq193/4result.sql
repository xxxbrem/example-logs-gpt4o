WITH README_CONTENT AS (
    SELECT DISTINCT s."content",
                    l."language"
    FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS s
    JOIN GITHUB_REPOS.GITHUB_REPOS.LANGUAGES l
    ON l."repo_name" = s."sample_repo_name"
    WHERE s."sample_path" ILIKE '%README%md%' 
      AND s."content" IS NOT NULL 
      AND s."content" NOT LIKE '#%'  -- Exclude Markdown comments
      AND s."content" NOT LIKE '//%' -- Exclude code comments
      AND l."language" ILIKE '%Python%' -- Filter for Python repositories
),
LINE_FREQUENCY AS (
    SELECT "content",
           COUNT("content") AS "frequency",
           LISTAGG(DISTINCT "language", ', ') AS "languages"
    FROM README_CONTENT
    GROUP BY "content"
)
SELECT "content", 
       "frequency", 
       "languages"
FROM LINE_FREQUENCY
ORDER BY "frequency" DESC NULLS LAST
LIMIT 5;