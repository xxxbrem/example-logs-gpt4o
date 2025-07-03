SELECT COUNT(DISTINCT "StudyInstanceUID") AS "Unique_StudyInstanceUIDs"
FROM "IDC"."IDC_V17"."DICOM_PIVOT"
WHERE LOWER("SegmentedPropertyTypeCodeSequence") = '15825003'
  AND LOWER("collection_id") IN ('community', 'nsclc_radiomics');