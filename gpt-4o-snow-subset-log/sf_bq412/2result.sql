SELECT 
    t."creative_page_url", 
    f.value::VARIANT:"first_shown" AS "first_shown",
    f.value::VARIANT:"last_shown" AS "last_shown",
    d.value::VARIANT:"removal_reason" AS "removal_reason",
    d.value::VARIANT:"violation_category" AS "violation_category",
    f.value::VARIANT:"times_shown_lower_bound" AS "times_shown_lower_bound",
    f.value::VARIANT:"times_shown_upper_bound" AS "times_shown_upper_bound"
FROM GOOGLE_ADS.GOOGLE_ADS_TRANSPARENCY_CENTER.REMOVED_CREATIVE_STATS t, 
LATERAL FLATTEN(input => t."region_stats") f,
LATERAL FLATTEN(input => t."disapproval") d
WHERE f.value::VARIANT:"region_code" = 'HR'
      AND f.value::VARIANT:"times_shown_lower_bound" > 10000
      AND f.value::VARIANT:"times_shown_upper_bound" < 25000
      AND f.value::VARIANT:"times_shown_availability_date" IS NULL
      AND (
          t."audience_selection_approach_info"::VARIANT:"demographic_info" != 'CRITERIA_UNUSED' 
          OR t."audience_selection_approach_info"::VARIANT:"geo_location" != 'CRITERIA_UNUSED'
          OR t."audience_selection_approach_info"::VARIANT:"contextual_signals" != 'CRITERIA_UNUSED'
          OR t."audience_selection_approach_info"::VARIANT:"customer_lists" != 'CRITERIA_UNUSED'
          OR t."audience_selection_approach_info"::VARIANT:"topics_of_interest" != 'CRITERIA_UNUSED'
      )
ORDER BY f.value::VARIANT:"last_shown" DESC NULLS LAST
LIMIT 5;