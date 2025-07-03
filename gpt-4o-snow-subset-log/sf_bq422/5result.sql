WITH SliceIntervalTop3 AS (
    SELECT 
        "PatientID", 
        MAX(CAST("SliceLocation" AS FLOAT)) - MIN(CAST("SliceLocation" AS FLOAT)) AS "SliceInterval"
    FROM IDC.IDC_V17.DICOM_ALL
    WHERE "Modality" = 'CT' AND "collection_id" = 'nlst' AND "SliceLocation" IS NOT NULL
    GROUP BY "PatientID"
    ORDER BY "SliceInterval" DESC NULLS LAST
    LIMIT 3
),
ExposureDifferenceTop3 AS (
    SELECT 
        "PatientID", 
        MAX(CAST("Exposure" AS FLOAT)) - MIN(CAST("Exposure" AS FLOAT)) AS "ExposureDifference"
    FROM IDC.IDC_V17.DICOM_ALL
    WHERE "Modality" = 'CT' AND "collection_id" = 'nlst' AND "Exposure" IS NOT NULL
    GROUP BY "PatientID"
    ORDER BY "ExposureDifference" DESC NULLS LAST
    LIMIT 3
),
SeriesSizes AS (
    SELECT 
        "PatientID", 
        "SeriesInstanceUID", 
        SUM("instance_size") / (1024 * 1024) AS "SeriesSizeMiB"
    FROM IDC.IDC_V17.DICOM_ALL
    WHERE "Modality" = 'CT' AND "collection_id" = 'nlst'
    GROUP BY "PatientID", "SeriesInstanceUID"
),
SliceIntervalAvgSeriesSize AS (
    SELECT 
        'Top 3 by Slice Interval' AS "Group",
        AVG("SeriesSizeMiB") AS "AverageSeriesSize"
    FROM SeriesSizes
    WHERE "PatientID" IN (SELECT "PatientID" FROM SliceIntervalTop3)
),
ExposureDifferenceAvgSeriesSize AS (
    SELECT 
        'Top 3 by Max Exposure' AS "Group",
        AVG("SeriesSizeMiB") AS "AverageSeriesSize"
    FROM SeriesSizes
    WHERE "PatientID" IN (SELECT "PatientID" FROM ExposureDifferenceTop3)
)
SELECT * 
FROM SliceIntervalAvgSeriesSize
UNION ALL
SELECT * 
FROM ExposureDifferenceAvgSeriesSize;