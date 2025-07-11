SELECT COUNT(DISTINCT "StudyInstanceUID") AS "unique_StudyInstanceUID_count"
FROM "IDC"."IDC_V17"."DICOM_PIVOT"
WHERE LOWER("SegmentedPropertyTypeCodeSequence") = LOWER('15825003')
  AND "collection_id" IN ('Community', 'nsclc_radiomics');