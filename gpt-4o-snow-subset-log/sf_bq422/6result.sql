WITH SliceIntervalDifferences AS (
  SELECT 
    "PatientID",
    MAX(CAST("SliceThickness" AS FLOAT)) - MIN(CAST("SliceThickness" AS FLOAT)) AS "SliceIntervalDifference"
  FROM 
    IDC.IDC_V17.DICOM_ALL
  WHERE 
    "collection_id" = 'nlst' 
    AND "Modality" = 'CT'
    AND "SliceThickness" IS NOT NULL
  GROUP BY 
    "PatientID"
  ORDER BY 
    "SliceIntervalDifference" DESC NULLS LAST
  LIMIT 3
),
ExposureDifferences AS (
  SELECT 
    "PatientID",
    MAX(CAST("Exposure" AS FLOAT)) - MIN(CAST("Exposure" AS FLOAT)) AS "ExposureDifference"
  FROM 
    IDC.IDC_V17.DICOM_ALL
  WHERE 
    "collection_id" = 'nlst' 
    AND "Modality" = 'CT'
    AND "Exposure" IS NOT NULL
  GROUP BY 
    "PatientID"
  ORDER BY 
    "ExposureDifference" DESC NULLS LAST
  LIMIT 3
),
SliceIntervalSeriesSizes AS (
  SELECT 
    si."PatientID",
    (SUM("instance_size") / (1024 * 1024)) AS "SeriesSizeMiB"
  FROM 
    IDC.IDC_V17.DICOM_ALL d
  JOIN 
    SliceIntervalDifferences si
  ON 
    d."PatientID" = si."PatientID"
  WHERE 
    "collection_id" = 'nlst' 
    AND "Modality" = 'CT'
  GROUP BY 
    si."PatientID", 
    d."SeriesInstanceUID"
),
ExposureSeriesSizes AS (
  SELECT 
    ed."PatientID",
    (SUM("instance_size") / (1024 * 1024)) AS "SeriesSizeMiB"
  FROM 
    IDC.IDC_V17.DICOM_ALL d
  JOIN 
    ExposureDifferences ed
  ON 
    d."PatientID" = ed."PatientID"
  WHERE 
    "collection_id" = 'nlst' 
    AND "Modality" = 'CT'
  GROUP BY 
    ed."PatientID", 
    d."SeriesInstanceUID"
)
SELECT 
  'Top 3 by Slice Interval' AS "Group",
  AVG("SeriesSizeMiB") AS "AverageSeriesSizeMiB"
FROM 
  SliceIntervalSeriesSizes
UNION ALL
SELECT 
  'Top 3 by Max Exposure' AS "Group",
  AVG("SeriesSizeMiB") AS "AverageSeriesSizeMiB"
FROM 
  ExposureSeriesSizes;