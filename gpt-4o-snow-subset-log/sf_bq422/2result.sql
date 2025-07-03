WITH SliceIntervalPatients AS (
  -- Calculate slice interval differences for each patient
  SELECT 
    "PatientID", 
    (MAX(SUBQUERY."SliceInterval") - MIN(SUBQUERY."SliceInterval")) AS "SliceIntervalDifference"
  FROM (
    SELECT 
      "PatientID", 
      "SeriesInstanceUID", 
      CAST("SpacingBetweenSlices" AS FLOAT) - CAST("SliceThickness" AS FLOAT) AS "SliceInterval"
    FROM "IDC"."IDC_V17"."DICOM_ALL"
    WHERE "collection_name" = 'NLST' AND "Modality" = 'CT'
  ) AS SUBQUERY
  GROUP BY "PatientID"
  ORDER BY "SliceIntervalDifference" DESC NULLS LAST
  LIMIT 3
),
ExposureDifferencePatients AS (
  -- Calculate exposure differences for each patient
  SELECT 
    "PatientID", 
    (MAX(CAST("ExposureInmAs" AS FLOAT)) - MIN(CAST("ExposureInmAs" AS FLOAT))) AS "ExposureDifference"
  FROM "IDC"."IDC_V17"."DICOM_ALL"
  WHERE "collection_name" = 'NLST' AND "Modality" = 'CT' AND "ExposureInmAs" IS NOT NULL
  GROUP BY "PatientID"
  ORDER BY "ExposureDifference" DESC NULLS LAST
  LIMIT 3
),
SliceIntervalSeries AS (
  -- Compute series size for patients with highest slice interval differences
  SELECT 
    DICOM."PatientID",
    DICOM."SeriesInstanceUID",
    SUM(DICOM."instance_size") / (1024 * 1024) AS "SeriesSizeMiB"
  FROM "IDC"."IDC_V17"."DICOM_ALL" AS DICOM
  JOIN SliceIntervalPatients AS SLICE
    ON DICOM."PatientID" = SLICE."PatientID"
  WHERE DICOM."collection_name" = 'NLST' AND DICOM."Modality" = 'CT'
  GROUP BY DICOM."PatientID", DICOM."SeriesInstanceUID"
),
ExposureDifferenceSeries AS (
  -- Compute series size for patients with highest exposure differences
  SELECT 
    DICOM."PatientID",
    DICOM."SeriesInstanceUID",
    SUM(DICOM."instance_size") / (1024 * 1024) AS "SeriesSizeMiB"
  FROM "IDC"."IDC_V17"."DICOM_ALL" AS DICOM
  JOIN ExposureDifferencePatients AS EXPOSE
    ON DICOM."PatientID" = EXPOSE."PatientID"
  WHERE DICOM."collection_name" = 'NLST' AND DICOM."Modality" = 'CT'
  GROUP BY DICOM."PatientID", DICOM."SeriesInstanceUID"
),
SliceIntervalAvg AS (
  -- Calculate average series size for patients with highest slice interval differences
  SELECT 
    'Top 3 by Slice Interval' AS "Group",
    AVG("SeriesSizeMiB") AS "AvgSeriesSizeMiB"
  FROM SliceIntervalSeries
),
ExposureDifferenceAvg AS (
  -- Calculate average series size for patients with highest exposure differences
  SELECT 
    'Top 3 by Max Exposure' AS "Group",
    AVG("SeriesSizeMiB") AS "AvgSeriesSizeMiB"
  FROM ExposureDifferenceSeries
)
-- Combine results
SELECT * 
FROM SliceIntervalAvg
UNION ALL
SELECT * 
FROM ExposureDifferenceAvg;