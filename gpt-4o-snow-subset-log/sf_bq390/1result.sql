SELECT DISTINCT T2."StudyInstanceUID"
FROM IDC.IDC_V17.DICOM_ALL T2
JOIN IDC.IDC_V17.SEGMENTATIONS SEG
  ON T2."StudyInstanceUID" = SEG."StudyInstanceUID"
  AND T2."SeriesInstanceUID" = SEG."SeriesInstanceUID"
WHERE T2."collection_id" ILIKE '%qin%prostate%repeatability%'
  AND T2."SeriesDescription" ILIKE '%t2%weighted%' 
  AND T2."SeriesDescription" ILIKE '%axial%'
  AND SEG."SegmentedPropertyType" ILIKE '%Peripheral zone%';