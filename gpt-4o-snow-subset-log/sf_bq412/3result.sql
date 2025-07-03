SELECT 
    t."creative_page_url", 
    f.value:"first_shown"::STRING AS "first_shown", 
    f.value:"last_shown"::STRING AS "last_shown", 
    f.value:"times_shown_lower_bound"::NUMBER AS "times_shown_lower_bound", 
    f.value:"times_shown_upper_bound"::NUMBER AS "times_shown_upper_bound", 
    d.value:"removal_reason"::STRING AS "removal_reason", 
    d.value:"violation_category"::STRING AS "violation_category"
FROM GOOGLE_ADS.GOOGLE_ADS_TRANSPARENCY_CENTER.REMOVED_CREATIVE_STATS t, 
LATERAL FLATTEN(input => t."region_stats") f,
LATERAL FLATTEN(input => t."disapproval") d
WHERE f.value:"region_code"::STRING = 'HR'
  AND f.value:"times_shown_lower_bound"::NUMBER > 10000
  AND f.value:"times_shown_upper_bound"::NUMBER < 25000
  AND f.value:"times_shown_availability_date"::STRING IS NULL
  AND (
      t."audience_selection_approach_info"::VARIANT:"demographic_info" != 'CRITERIA_UNUSED'
      OR t."audience_selection_approach_info"::VARIANT:"geo_location" != 'CRITERIA_UNUSED'
      OR t."audience_selection_approach_info"::VARIANT:"contextual_signals" != 'CRITERIA_UNUSED'
      OR t."audience_selection_approach_info"::VARIANT:"customer_lists" != 'CRITERIA_UNUSED'
      OR t."audience_selection_approach_info"::VARIANT:"topics_of_interest" != 'CRITERIA_UNUSED'
  )
ORDER BY f.value:"last_shown"::STRING DESC NULLS LAST
LIMIT 5;