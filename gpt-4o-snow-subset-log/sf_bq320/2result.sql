SELECT COUNT(DISTINCT "StudyInstanceUID") AS total_unique_study_ids
FROM "IDC"."IDC_V17"."DICOM_PIVOT"
WHERE LOWER("SegmentedPropertyTypeCodeSequence") = '15825003'
  AND "collection_id" IN ('Community', 'nsclc_radiomics');