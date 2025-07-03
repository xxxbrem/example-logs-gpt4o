WITH Combined_Series AS (
  -- Step 1: Select SOPInstanceUID and Modality from DICOM_METADATA for the MR series
  SELECT "SOPInstanceUID", "Modality"
  FROM "IDC"."IDC_V17"."DICOM_METADATA"
  WHERE "SeriesInstanceUID" = '1.3.6.1.4.1.14519.5.2.1.3671.4754.105976129314091491952445656147'
  
  UNION ALL
  
  -- Step 2: Select SOPInstanceUID and 'SEG' as Modality for the segmentation data in SEGMENTATIONS
  SELECT "SOPInstanceUID", 'SEG' AS "Modality"
  FROM "IDC"."IDC_V17"."SEGMENTATIONS"
  WHERE "segmented_SeriesInstanceUID" = '1.3.6.1.4.1.14519.5.2.1.3671.4754.105976129314091491952445656147'
)

-- Step 3: Aggregate the count of SOPInstanceUIDs by Modality and retrieve the top modality
SELECT "Modality", COUNT("SOPInstanceUID") AS "SOPInstance_Count"
FROM Combined_Series
GROUP BY "Modality"
ORDER BY "SOPInstance_Count" DESC NULLS LAST
LIMIT 1;