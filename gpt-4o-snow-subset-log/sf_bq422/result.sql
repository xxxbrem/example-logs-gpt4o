WITH SliceInterval AS (
    SELECT 
        "PatientID", 
        MAX(CAST("SliceThickness" AS FLOAT)) - MIN(CAST("SliceThickness" AS FLOAT)) AS "SliceIntervalDifference"
    FROM 
        "IDC"."IDC_V17"."DICOM_ALL"
    WHERE 
        "collection_id" = 'nlst'
        AND "Modality" = 'CT'
    GROUP BY 
        "PatientID"
),
TopSlicePatients AS (
    SELECT 
        "PatientID"
    FROM 
        SliceInterval
    ORDER BY 
        "SliceIntervalDifference" DESC NULLS LAST
    LIMIT 
        3
),
ExposureDifference AS (
    SELECT 
        "PatientID", 
        MAX(CAST("Exposure" AS FLOAT)) - MIN(CAST("Exposure" AS FLOAT)) AS "ExposureDifference"
    FROM 
        "IDC"."IDC_V17"."DICOM_ALL"
    WHERE 
        "collection_id" = 'nlst'
        AND "Modality" = 'CT'
    GROUP BY 
        "PatientID"
),
TopExposurePatients AS (
    SELECT 
        "PatientID"
    FROM 
        ExposureDifference
    ORDER BY 
        "ExposureDifference" DESC NULLS LAST
    LIMIT 
        3
),
SeriesSizeSliceInterval AS (
    SELECT 
        d."PatientID", 
        d."SeriesInstanceUID", 
        SUM(d."instance_size") / (1024 * 1024) AS "SeriesSizeMiB" -- Convert bytes to MiB
    FROM 
        "IDC"."IDC_V17"."DICOM_ALL" d
    JOIN 
        TopSlicePatients ts
    ON 
        d."PatientID" = ts."PatientID"
    WHERE 
        d."collection_id" = 'nlst'
        AND d."Modality" = 'CT'
    GROUP BY 
        d."PatientID", 
        d."SeriesInstanceUID"
),
SeriesSizeExposureDifference AS (
    SELECT 
        d."PatientID", 
        d."SeriesInstanceUID", 
        SUM(d."instance_size") / (1024 * 1024) AS "SeriesSizeMiB" -- Convert bytes to MiB
    FROM 
        "IDC"."IDC_V17"."DICOM_ALL" d
    JOIN 
        TopExposurePatients te
    ON 
        d."PatientID" = te."PatientID"
    WHERE 
        d."collection_id" = 'nlst'
        AND d."Modality" = 'CT'
    GROUP BY 
        d."PatientID", 
        d."SeriesInstanceUID"
)
SELECT 
    'Top 3 by Slice Interval' AS "Group",
    AVG("SeriesSizeMiB") AS "AverageSeriesSizeMiB"
FROM 
    SeriesSizeSliceInterval
UNION ALL
SELECT 
    'Top 3 by Max Exposure' AS "Group",
    AVG("SeriesSizeMiB") AS "AverageSeriesSizeMiB"
FROM 
    SeriesSizeExposureDifference;