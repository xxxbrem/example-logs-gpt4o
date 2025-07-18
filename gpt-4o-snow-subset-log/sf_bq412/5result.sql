SELECT t."creative_page_url", 
       r.value::VARIANT:"first_shown"::STRING AS "first_shown",
       r.value::VARIANT:"last_shown"::STRING AS "last_shown",
       r.value::VARIANT:"times_shown_lower_bound"::NUMBER AS "times_shown_lower_bound",
       r.value::VARIANT:"times_shown_upper_bound"::NUMBER AS "times_shown_upper_bound",
       d.value::VARIANT:"removal_reason"::STRING AS "removal_reason",
       d.value::VARIANT:"violation_category"::STRING AS "violation_category"
FROM GOOGLE_ADS.GOOGLE_ADS_TRANSPARENCY_CENTER.REMOVED_CREATIVE_STATS t,
LATERAL FLATTEN(input => t."region_stats") r,
LATERAL FLATTEN(input => t."disapproval") d
WHERE r.value::VARIANT:"region_code"::STRING = 'HR'
  AND r.value::VARIANT:"times_shown_lower_bound"::NUMBER > 10000
  AND r.value::VARIANT:"times_shown_upper_bound"::NUMBER < 25000
  AND r.value::VARIANT:"times_shown_availability_date" IS NULL
ORDER BY r.value::VARIANT:"last_shown"::STRING DESC NULLS LAST
LIMIT 5;