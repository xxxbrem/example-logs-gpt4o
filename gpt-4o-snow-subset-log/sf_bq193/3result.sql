SELECT "line", "languages", "frequency"
FROM (
    SELECT f.value::STRING AS "line", 
           LISTAGG(DISTINCT l."language", ', ') AS "languages", 
           COUNT(*) AS "frequency"
    FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS c
    JOIN GITHUB_REPOS.GITHUB_REPOS.LANGUAGES l 
        ON c."sample_repo_name" = l."repo_name",
         LATERAL FLATTEN(input => SPLIT(c."content", '\n')) f
    WHERE c."sample_path" ILIKE '%README.md%'
      AND l."language" ILIKE '%python%'
      AND NOT f.value::STRING ILIKE '#%'
      AND NOT f.value::STRING ILIKE '//%'
      AND TRIM(f.value::STRING) != ''
    GROUP BY f.value::STRING
    ORDER BY COUNT(*) DESC NULLS LAST
) AS processed_table
LIMIT 5;