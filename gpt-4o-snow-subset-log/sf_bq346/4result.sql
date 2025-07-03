SELECT 
    seg_category.VALUE::VARIANT:"CodeMeaning"::STRING AS "SegmentedPropertyCategory_CodeMeaning",
    COUNT(*) AS "Frequency"
FROM IDC.IDC_V17.SEGMENTATIONS seg
JOIN IDC.IDC_V17.DICOM_ALL meta
     ON seg."SOPInstanceUID" = meta."SOPInstanceUID",
     LATERAL FLATTEN(input => seg."SegmentedPropertyCategory") seg_category
WHERE meta."Modality" = 'SEG'
  AND meta."SOPClassUID" = '1.2.840.10008.5.1.4.1.1.66.4'
  AND meta."access" = 'Public'
GROUP BY seg_category.VALUE::VARIANT:"CodeMeaning"::STRING
ORDER BY "Frequency" DESC NULLS LAST
LIMIT 5;