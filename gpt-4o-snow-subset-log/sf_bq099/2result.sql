WITH AssigneeApplications AS (
  SELECT 
    f.value::VARIANT:"name"::STRING AS "assignee_name", 
    COUNT(*) AS "total_applications",
    t."priority_date",
    t."country_code"
  FROM PATENTS.PATENTS.PUBLICATIONS t, 
  LATERAL FLATTEN(input => t."cpc") c, 
  LATERAL FLATTEN(input => t."assignee_harmonized") f 
  WHERE c.value::VARIANT:"code"::STRING ILIKE '%A01B3%'
  GROUP BY "assignee_name", t."priority_date", t."country_code"
),
TopAssignees AS (
  SELECT 
    "assignee_name", 
    SUM("total_applications") AS "sum_applications"
  FROM AssigneeApplications
  GROUP BY "assignee_name"
  ORDER BY "sum_applications" DESC NULLS LAST
  LIMIT 3
),
YearlyTrends AS (
  SELECT 
    a."assignee_name", 
    a."priority_date",
    a."country_code",
    SUM(a."total_applications") AS "yearly_applications"
  FROM AssigneeApplications a
  INNER JOIN TopAssignees t ON a."assignee_name" = t."assignee_name"
  GROUP BY a."assignee_name", a."priority_date", a."country_code"
),
YearMax AS (
  SELECT 
    "assignee_name", 
    "priority_date" AS "max_year", 
    MAX("yearly_applications") AS "max_yearly_applications"
  FROM YearlyTrends
  GROUP BY "assignee_name", "priority_date"
),
CountryMax AS (
  SELECT 
    y."assignee_name", 
    y."priority_date", 
    y."yearly_applications", 
    y."country_code"
  FROM YearlyTrends y
  INNER JOIN YearMax m 
    ON y."assignee_name" = m."assignee_name" 
    AND y."priority_date" = m."max_year" 
    AND y."yearly_applications" = m."max_yearly_applications"
)
SELECT 
  t."assignee_name",
  t."sum_applications" AS "total_applications",
  c."priority_date" AS "year_with_most_applications", 
  c."yearly_applications" AS "applications_in_that_year",
  c."country_code" AS "most_active_country_code"
FROM TopAssignees t
INNER JOIN CountryMax c 
  ON t."assignee_name" = c."assignee_name"
ORDER BY "total_applications" DESC NULLS LAST;