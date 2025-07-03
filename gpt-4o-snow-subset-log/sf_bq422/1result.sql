-- Step 1: Calculate slice interval difference and exposure difference for each patient:
WITH PatientSliceIntervalDifference AS (
    SELECT 
        "PatientID",
        MAX(CAST("SliceThickness" AS FLOAT)) - MIN(CAST("SliceThickness" AS FLOAT)) AS slice_interval_diff
    FROM IDC.IDC_V17.DICOM_ALL
    WHERE "collection_id" = 'nlst' AND "Modality" = 'CT' AND "SliceThickness" IS NOT NULL
    GROUP BY "PatientID"
),
PatientExposureDifference AS (
    SELECT 
        "PatientID",
        MAX(CAST("Exposure" AS FLOAT)) - MIN(CAST("Exposure" AS FLOAT)) AS exposure_diff
    FROM IDC.IDC_V17.DICOM_ALL
    WHERE "collection_id" = 'nlst' AND "Modality" = 'CT' AND "Exposure" IS NOT NULL
    GROUP BY "PatientID"
),

-- Step 2: Identify top 3 patients with highest slice interval and exposure differences:
TopSliceIntervalPatients AS (
    SELECT 
        "PatientID"
    FROM PatientSliceIntervalDifference
    ORDER BY slice_interval_diff DESC NULLS LAST
    LIMIT 3
),
TopExposurePatients AS (
    SELECT 
        "PatientID"
    FROM PatientExposureDifference
    ORDER BY exposure_diff DESC NULLS LAST
    LIMIT 3
),

-- Step 3: Calculate series size in MiB for each series of the top patients:
SeriesSizeInMiB AS (
    SELECT
        "PatientID",
        "SeriesInstanceUID",
        SUM("instance_size") / (1024 * 1024) AS series_size_mib
    FROM IDC.IDC_V17.DICOM_ALL
    WHERE "collection_id" = 'nlst' AND "Modality" = 'CT'
    GROUP BY "PatientID", "SeriesInstanceUID"
),

-- Step 4: Compute the average series size in MiB for the top 3 slice interval patients:
AvgSeriesSizeBySliceInterval AS (
    SELECT 
        'Top 3 by Slice Interval' AS group_label,
        AVG(series_size_mib) AS avg_series_size_mib
    FROM SeriesSizeInMiB
    WHERE "PatientID" IN (SELECT "PatientID" FROM TopSliceIntervalPatients)
),

-- Step 5: Compute the average series size in MiB for the top 3 exposure patients:
AvgSeriesSizeByExposure AS (
    SELECT 
        'Top 3 by Max Exposure' AS group_label,
        AVG(series_size_mib) AS avg_series_size_mib
    FROM SeriesSizeInMiB
    WHERE "PatientID" IN (SELECT "PatientID" FROM TopExposurePatients)
)

-- Step 6: Combine results:
SELECT * 
FROM AvgSeriesSizeBySliceInterval
UNION ALL
SELECT * 
FROM AvgSeriesSizeByExposure;