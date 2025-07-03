SELECT 
    "SegmentedPropertyCategory"::VARIANT:"CodeMeaning"::TEXT AS "CodeMeaning",
    COUNT(*) AS "Frequency"
FROM "IDC"."IDC_V17"."SEGMENTATIONS"
GROUP BY "SegmentedPropertyCategory"::VARIANT:"CodeMeaning"::TEXT
ORDER BY "Frequency" DESC NULLS LAST
LIMIT 5;