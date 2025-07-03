SELECT DISTINCT d."StudyInstanceUID"
FROM "IDC"."IDC_V17"."DICOM_ALL" d
JOIN "IDC"."IDC_V17"."SEGMENTATIONS" s 
  ON d."StudyInstanceUID" = s."StudyInstanceUID"
WHERE d."collection_id" = 'qin_prostate_repeatability'
  AND d."SeriesDescription" ILIKE '%t2%axial%' 
  AND s."SegmentedPropertyType"::TEXT ILIKE '%Peripheral%zone%'
LIMIT 20;