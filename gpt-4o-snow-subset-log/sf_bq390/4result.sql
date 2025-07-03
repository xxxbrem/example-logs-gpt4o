SELECT DISTINCT d."StudyInstanceUID" 
FROM IDC.IDC_V17.DICOM_ALL d 
INNER JOIN IDC.IDC_V17.SEGMENTATIONS s 
  ON d."StudyInstanceUID" = s."StudyInstanceUID" 
WHERE d."collection_id" = 'qin_prostate_repeatability' 
  AND d."SeriesDescription" ILIKE '%T2%axial%' 
  AND s."SegmentedPropertyType"::VARIANT:"CodeMeaning" ILIKE '%Peripheral zone%'