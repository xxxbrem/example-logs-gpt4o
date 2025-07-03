SELECT "Modality", SUM("SOPInstanceCount") AS "TotalSOPInstances"
FROM (
    SELECT 
        "Modality", 
        COUNT("SOPInstanceUID") AS "SOPInstanceCount"
    FROM "IDC"."IDC_V17"."DICOM_PIVOT"
    WHERE "SeriesInstanceUID" = '1.3.6.1.4.1.14519.5.2.1.3671.4754.105976129314091491952445656147'
    GROUP BY "Modality"
    
    UNION ALL
    
    SELECT 
        "Modality",
        COUNT("SOPInstanceUID") AS "SOPInstanceCount"
    FROM "IDC"."IDC_V17"."SEGMENTATIONS"
    JOIN "IDC"."IDC_V17"."DICOM_METADATA_CURATED_SERIES_LEVEL" ON 
        "SEGMENTATIONS"."SeriesInstanceUID" = "DICOM_METADATA_CURATED_SERIES_LEVEL"."SeriesInstanceUID"
    WHERE "segmented_SeriesInstanceUID" = '1.3.6.1.4.1.14519.5.2.1.3671.4754.105976129314091491952445656147'
    GROUP BY "Modality"
)
GROUP BY "Modality"
ORDER BY "TotalSOPInstances" DESC NULLS LAST
LIMIT 1;