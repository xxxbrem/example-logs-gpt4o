SELECT DISTINCT dicom."StudyInstanceUID"
FROM IDC.IDC_V17.DICOM_ALL dicom
INNER JOIN IDC.IDC_V17.SEGMENTATIONS seg
ON dicom."StudyInstanceUID" = seg."StudyInstanceUID"
WHERE dicom."collection_id" = 'qin_prostate_repeatability'
AND dicom."SeriesDescription" ILIKE '%T2%axial%'
AND seg."SegmentedPropertyType"::TEXT ILIKE '%Peripheral zone%'