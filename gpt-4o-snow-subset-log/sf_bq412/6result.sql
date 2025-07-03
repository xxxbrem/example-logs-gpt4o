SELECT DISTINCT 
    t."creative_page_url",
    f.value:"first_shown"::STRING AS "first_shown",
    f.value:"last_shown"::STRING AS "last_shown",
    d.value:"removal_reason"::STRING AS "removal_reason",
    d.value:"violation_category"::STRING AS "violation_category",
    f.value:"times_shown_lower_bound"::INTEGER AS "times_shown_lower_bound",
    f.value:"times_shown_upper_bound"::INTEGER AS "times_shown_upper_bound"
FROM 
    GOOGLE_ADS.GOOGLE_ADS_TRANSPARENCY_CENTER.REMOVED_CREATIVE_STATS t,
    TABLE(FLATTEN(input => t."region_stats")) f,
    TABLE(FLATTEN(input => t."disapproval")) d,
    TABLE(FLATTEN(input => t."audience_selection_approach_info")) a
WHERE 
    f.value:"region_code"::STRING = 'HR' -- Region Croatia (HR)
    AND (f.value:"times_shown_availability_date"::STRING IS NULL 
         OR f.value:"times_shown_availability_date" = '') -- Availability date is explicitly null or empty
    AND f.value:"times_shown_lower_bound"::INTEGER > 10000 -- Shown lower bound exceeds 10,000
    AND f.value:"times_shown_upper_bound"::INTEGER < 25000 -- Shown upper bound below 25,000
    AND (
        COALESCE(a.value:"contextual_signals"::STRING, '') != 'CRITERIA_UNUSED'
        OR COALESCE(a.value:"customer_lists"::STRING, '') != 'CRITERIA_UNUSED'
        OR COALESCE(a.value:"demographic_info"::STRING, '') != 'CRITERIA_UNUSED'
        OR COALESCE(a.value:"geo_location"::STRING, '') != 'CRITERIA_UNUSED'
        OR COALESCE(a.value:"topics_of_interest"::STRING, '') != 'CRITERIA_UNUSED'
    ) -- At least one valid audience selection criterion
ORDER BY 
    f.value:"last_shown"::STRING DESC NULLS LAST -- Most recent ads by last shown
LIMIT 5;