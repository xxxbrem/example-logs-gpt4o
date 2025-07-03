SELECT DISTINCT d."StudyInstanceUID"
FROM IDC.IDC_V17.DICOM_ALL d
JOIN IDC.IDC_V17.SEGMENTATIONS s
  ON d."StudyInstanceUID" = s."StudyInstanceUID"
WHERE d."collection_id" = 'qin_prostate_repeatability'
  AND LOWER(d."SeriesDescription") LIKE '%t2%'  -- Adjusting the condition to capture broader T2-weighted descriptions
  AND LOWER(s."SegmentedPropertyType"::VARIANT:"CodeMeaning") LIKE '%peripheral%'; -- Generalizing match for segmentation type