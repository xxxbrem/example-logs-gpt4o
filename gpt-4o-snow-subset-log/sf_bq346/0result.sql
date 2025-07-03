SELECT 
    f.value::VARIANT:"CodeMeaning"::STRING AS "SegmentedPropertyCategory", 
    COUNT(*) AS "Frequency"
FROM IDC.IDC_V17.SEGMENTATIONS t
JOIN IDC.IDC_V17.DICOM_ALL d
    ON t."SOPInstanceUID" = d."SOPInstanceUID",
LATERAL FLATTEN(input => t."SegmentedPropertyCategory") f
WHERE d."Modality" = 'SEG'
  AND d."SOPClassUID" = '1.2.840.10008.5.1.4.1.1.66.4'
  AND d."access" = 'Public'
GROUP BY f.value::VARIANT:"CodeMeaning"::STRING
ORDER BY "Frequency" DESC NULLS LAST
LIMIT 5;