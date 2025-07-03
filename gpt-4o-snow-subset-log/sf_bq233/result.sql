WITH Python_R_Files AS (
  SELECT DISTINCT "id", "path"
  FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_FILES
  WHERE "path" ILIKE '%.py' OR "path" ILIKE '%.r'
),
Python_R_Contents AS (
  SELECT sc."content", sf."path"
  FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS sc
  JOIN Python_R_Files sf
  ON sc."id" = sf."id"
),
Python_Modules AS (
  SELECT 
    REGEXP_SUBSTR("content", 'import\\s+([a-zA-Z0-9_\\.]+)', 1, 1, 'i', 1) AS "module",
    'Python' AS "language"
  FROM Python_R_Contents
  WHERE "path" ILIKE '%.py' AND "content" ILIKE '%import%'
  UNION ALL
  SELECT 
    REGEXP_SUBSTR("content", 'from\\s+([a-zA-Z0-9_\\.]+)\\s+import', 1, 1, 'i', 1) AS "module",
    'Python' AS "language"
  FROM Python_R_Contents
  WHERE "path" ILIKE '%.py' AND "content" ILIKE '%from%'
),
R_Libraries AS (
  SELECT 
    REGEXP_SUBSTR("content", 'library\\(([^\\)]+)\\)', 1, 1, 'i', 1) AS "module",
    'R' AS "language"
  FROM Python_R_Contents
  WHERE "path" ILIKE '%.r' AND "content" ILIKE '%library(%'
),
Combined_Modules AS (
  SELECT * FROM Python_Modules
  UNION ALL
  SELECT * FROM R_Libraries
)
SELECT 
  "language",
  "module",
  COUNT(*) AS "occurrences"
FROM Combined_Modules
WHERE "module" IS NOT NULL
GROUP BY "language", "module"
ORDER BY "language", "occurrences" DESC NULLS LAST;