SELECT DISTINCT 
    t."creative_page_url", 
    f.value::VARIANT:"first_shown"::STRING AS "first_shown", 
    f.value::VARIANT:"last_shown"::STRING AS "last_shown", 
    d.value::VARIANT:"removal_reason"::STRING AS "removal_reason", 
    d.value::VARIANT:"violation_category"::STRING AS "violation_category", 
    f.value::VARIANT:"times_shown_lower_bound"::INTEGER AS "times_shown_lower_bound", 
    f.value::VARIANT:"times_shown_upper_bound"::INTEGER AS "times_shown_upper_bound"
FROM "GOOGLE_ADS"."GOOGLE_ADS_TRANSPARENCY_CENTER"."REMOVED_CREATIVE_STATS" t,
TABLE(FLATTEN(input => t."disapproval")) d,
TABLE(FLATTEN(input => t."audience_selection_approach_info")) a,
TABLE(FLATTEN(input => t."region_stats")) f
WHERE f.value::VARIANT:"region_code"::STRING = 'HR'
  AND f.value::VARIANT:"times_shown_availability_date" IS NULL
  AND f.value::VARIANT:"times_shown_lower_bound"::INTEGER > 10000
  AND f.value::VARIANT:"times_shown_upper_bound"::INTEGER < 25000
  AND (
      a.value::VARIANT:"demographic_info" IS NULL OR a.value::VARIANT:"demographic_info"::STRING != 'CRITERIA_UNUSED'
      OR a.value::VARIANT:"geo_location" IS NULL OR a.value::VARIANT:"geo_location"::STRING != 'CRITERIA_UNUSED'
      OR a.value::VARIANT:"contextual_signals" IS NULL OR a.value::VARIANT:"contextual_signals"::STRING != 'CRITERIA_UNUSED'
      OR a.value::VARIANT:"customer_lists" IS NULL OR a.value::VARIANT:"customer_lists"::STRING != 'CRITERIA_UNUSED'
      OR a.value::VARIANT:"topics_of_interest" IS NULL OR a.value::VARIANT:"topics_of_interest"::STRING != 'CRITERIA_UNUSED'
  )
ORDER BY f.value::VARIANT:"last_shown"::STRING DESC NULLS LAST
LIMIT 5;