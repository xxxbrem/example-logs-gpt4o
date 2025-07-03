-- Step 1: Calculate slice interval difference and exposure difference for each patient
WITH SliceIntervalTop3 AS (
    SELECT 
        "PatientID", 
        MAX(CAST("SliceThickness" AS FLOAT)) - MIN(CAST("SliceThickness" AS FLOAT)) AS "SliceIntervalDifference" 
    FROM IDC.IDC_V17.DICOM_ALL 
    WHERE "Modality" = 'CT' AND "collection_name" ILIKE '%nlst%' 
    GROUP BY "PatientID"
    ORDER BY "SliceIntervalDifference" DESC NULLS LAST 
    LIMIT 3
), ExposureTop3 AS (
    SELECT 
        "PatientID", 
        MAX(CAST("Exposure" AS FLOAT)) - MIN(CAST("Exposure" AS FLOAT)) AS "ExposureDifference" 
    FROM IDC.IDC_V17.DICOM_ALL 
    WHERE "Modality" = 'CT' AND "collection_name" ILIKE '%nlst%' 
    GROUP BY "PatientID"
    ORDER BY "ExposureDifference" DESC NULLS LAST 
    LIMIT 3
), SeriesSizesSliceInterval AS (
    -- Step 2: Compute total series size (in MiB) for patients in the top 3 by slice interval difference
    SELECT 
        a."PatientID", 
        a."SeriesInstanceUID", 
        SUM(a."instance_size") / (1024 * 1024) AS "SeriesSize_MiB"
    FROM IDC.IDC_V17.DICOM_ALL a
    JOIN SliceIntervalTop3 b ON a."PatientID" = b."PatientID"
    WHERE a."Modality" = 'CT' AND a."collection_name" ILIKE '%nlst%'
    GROUP BY a."PatientID", a."SeriesInstanceUID"
), SeriesSizesExposure AS (
    -- Compute total series size (in MiB) for patients in the top 3 by exposure difference
    SELECT 
        a."PatientID", 
        a."SeriesInstanceUID", 
        SUM(a."instance_size") / (1024 * 1024) AS "SeriesSize_MiB"
    FROM IDC.IDC_V17.DICOM_ALL a
    JOIN ExposureTop3 b ON a."PatientID" = b."PatientID"
    WHERE a."Modality" = 'CT' AND a."collection_name" ILIKE '%nlst%'
    GROUP BY a."PatientID", a."SeriesInstanceUID"
)
-- Step 3: Aggregate and label results for both groups
SELECT 
    'Top 3 by Slice Interval' AS "Group",
    "PatientID", 
    AVG("SeriesSize_MiB") AS "AvgSeriesSize_MiB"
FROM SeriesSizesSliceInterval
GROUP BY "PatientID"

UNION ALL

SELECT 
    'Top 3 by Max Exposure' AS "Group",
    "PatientID", 
    AVG("SeriesSize_MiB") AS "AvgSeriesSize_MiB"
FROM SeriesSizesExposure
GROUP BY "PatientID";