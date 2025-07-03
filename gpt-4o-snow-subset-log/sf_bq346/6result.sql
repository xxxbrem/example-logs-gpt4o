SELECT f.value::VARIANT:"CodeMeaning"::STRING AS "SegmentedPropertyCategory_CodeMeaning", 
       COUNT(*) AS "Frequency" 
FROM IDC.IDC_V17.SEGMENTATIONS t, 
LATERAL FLATTEN(input => t."SegmentedPropertyCategory") f 
WHERE t."SeriesInstanceUID" IN (
    SELECT DISTINCT "SeriesInstanceUID" 
    FROM IDC.IDC_V17.DICOM_ALL 
    WHERE "Modality" = 'SEG' 
      AND "SOPClassUID" = '1.2.840.10008.5.1.4.1.1.66.4'
)
  AND EXISTS (
    SELECT 1
    FROM IDC.IDC_V17.DICOM_ALL d
    WHERE d."SOPInstanceUID" = t."SOPInstanceUID" 
      AND d."access" = 'Public'
) 
GROUP BY "SegmentedPropertyCategory_CodeMeaning" 
ORDER BY "Frequency" DESC NULLS LAST 
LIMIT 5;