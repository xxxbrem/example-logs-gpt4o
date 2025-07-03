WITH MR_series AS (
    -- Fetch SOPInstanceUIDs and Modality from the specified MR SeriesInstanceUID
    SELECT "SOPInstanceUID", "Modality"
    FROM IDC.IDC_V17.DICOM_METADATA
    WHERE "SeriesInstanceUID" = '1.3.6.1.4.1.14519.5.2.1.3671.4754.105976129314091491952445656147'
),
segmentation_instances AS (
    -- Fetch all SOPInstanceUIDs and Modality from segmentation data where segmented_SeriesInstanceUID matches the MR SeriesInstanceUID directly
    SELECT seg."SOPInstanceUID", 'SEG' AS "Modality"
    FROM IDC.IDC_V17.SEGMENTATIONS seg
    WHERE seg."segmented_SeriesInstanceUID" = '1.3.6.1.4.1.14519.5.2.1.3671.4754.105976129314091491952445656147'
)
-- Combine MR Series and its associated segmentation instances
SELECT "Modality", COUNT("SOPInstanceUID") AS "SOPInstanceCount"
FROM (
    SELECT * FROM MR_series
    UNION ALL
    SELECT * FROM segmentation_instances
) combined_data
GROUP BY "Modality"
ORDER BY "SOPInstanceCount" DESC NULLS LAST;