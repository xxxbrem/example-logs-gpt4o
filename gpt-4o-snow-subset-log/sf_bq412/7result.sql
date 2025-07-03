SELECT 
    t."creative_page_url",
    f.value::VARIANT:"first_shown"::STRING AS "first_shown",
    f.value::VARIANT:"last_shown"::STRING AS "last_shown",
    d.value::VARIANT:"removal_reason"::STRING AS "removal_reason",
    d.value::VARIANT:"violation_category"::STRING AS "violation_category",
    f.value::VARIANT:"times_shown_lower_bound"::NUMBER AS "times_shown_lower_bound",
    f.value::VARIANT:"times_shown_upper_bound"::NUMBER AS "times_shown_upper_bound"
FROM 
    GOOGLE_ADS.GOOGLE_ADS_TRANSPARENCY_CENTER.REMOVED_CREATIVE_STATS t,
    LATERAL FLATTEN(input => t."region_stats") f,
    LATERAL FLATTEN(input => t."disapproval") d
WHERE 
    f.value::VARIANT:"region_code"::STRING = 'HR'
    AND f.value::VARIANT:"times_shown_availability_date" IS NULL
    AND f.value::VARIANT:"times_shown_lower_bound"::NUMBER > 10000
    AND f.value::VARIANT:"times_shown_upper_bound"::NUMBER < 25000
ORDER BY 
    f.value::VARIANT:"last_shown"::STRING DESC NULLS LAST
LIMIT 5;