SELECT JSON_EXTRACT_PATH_TEXT(s."SegmentedPropertyCategory", 'CodeMeaning') AS "SegmentedPropertyCategory_CodeMeaning", 
       COUNT(*) AS "Frequency"
FROM IDC.IDC_V17.DICOM_ALL m
JOIN IDC.IDC_V17.SEGMENTATIONS s
  ON m."SOPInstanceUID" = s."SOPInstanceUID"
WHERE m."Modality" = 'SEG' 
  AND m."SOPClassUID" = '1.2.840.10008.5.1.4.1.1.66.4'
  AND m."access" = 'Public'
GROUP BY "SegmentedPropertyCategory_CodeMeaning"
ORDER BY "Frequency" DESC NULLS LAST
LIMIT 5;