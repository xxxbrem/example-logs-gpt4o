WITH slice_interval_ranking AS (
  SELECT 
    "PatientID", 
    MAX(CAST("SliceThickness" AS FLOAT)) - MIN(CAST("SliceThickness" AS FLOAT)) AS "max_slice_interval_diff"
  FROM 
    "IDC"."IDC_V17"."DICOM_ALL"
  WHERE 
    "collection_id" = 'nlst'
    AND "Modality" = 'CT'
  GROUP BY 
    "PatientID"
),
top_3_by_slice_interval AS (
  SELECT 
    "PatientID"
  FROM 
    slice_interval_ranking
  ORDER BY 
    "max_slice_interval_diff" DESC NULLS LAST
  LIMIT 3
),
exposure_difference_ranking AS (
  SELECT 
    "PatientID", 
    MAX(CAST("Exposure" AS FLOAT)) - MIN(CAST("Exposure" AS FLOAT)) AS "max_exposure_diff"
  FROM 
    "IDC"."IDC_V17"."DICOM_ALL"
  WHERE 
    "collection_id" = 'nlst'
    AND "Modality" = 'CT'
    AND "Exposure" IS NOT NULL
  GROUP BY 
    "PatientID"
),
top_3_by_exposure AS (
  SELECT 
    "PatientID"
  FROM 
    exposure_difference_ranking
  ORDER BY 
    "max_exposure_diff" DESC NULLS LAST
  LIMIT 3
),
series_sizes AS (
  SELECT 
    "PatientID", 
    "SeriesInstanceUID", 
    SUM("instance_size") / (1024 * 1024) AS "series_size_mib"
  FROM 
    "IDC"."IDC_V17"."DICOM_ALL"
  WHERE 
    "collection_id" = 'nlst'
    AND "Modality" = 'CT'
  GROUP BY 
    "PatientID", 
    "SeriesInstanceUID"
),
average_series_size_by_slice_interval AS (
  SELECT 
    'Top 3 by Slice Interval' AS "Group", 
    AVG("series_size_mib") AS "avg_series_size_mib"
  FROM 
    series_sizes
  WHERE 
    "PatientID" IN (SELECT "PatientID" FROM top_3_by_slice_interval)
),
average_series_size_by_exposure AS (
  SELECT 
    'Top 3 by Max Exposure' AS "Group", 
    AVG("series_size_mib") AS "avg_series_size_mib"
  FROM 
    series_sizes
  WHERE 
    "PatientID" IN (SELECT "PatientID" FROM top_3_by_exposure)
)
SELECT 
  *
FROM 
  average_series_size_by_slice_interval
UNION ALL
SELECT 
  *
FROM 
  average_series_size_by_exposure;