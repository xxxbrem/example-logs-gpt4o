SELECT 
    "SeriesInstanceUID",
    "SeriesNumber",
    "PatientID",
    ROUND(SUM("instance_size") / (1024 * 1024), 2) AS series_size_mib
FROM IDC.IDC_V17.DICOM_ALL
WHERE "collection_id" != 'nlst' -- Exclude 'nlst' collection
  AND "Modality" = 'CT' -- Focus on CT modality
  AND "TransferSyntaxUID" NOT IN ('1.2.840.10008.1.2.4.70', '1.2.840.10008.1.2.4.51') -- Exclude JPEG-compressed formats
  AND "ImageType" NOT ILIKE '%LOCALIZER%' -- Exclude localizer series
  AND "SeriesInstanceUID" IN (
      SELECT "SeriesInstanceUID"
      FROM (
          SELECT 
              "SeriesInstanceUID",
              COUNT(DISTINCT "Rows") AS unique_rows,
              COUNT(DISTINCT "Columns") AS unique_columns,
              COUNT(DISTINCT "PixelSpacing") AS unique_pixel_spacings,
              COUNT(DISTINCT "ImagePositionPatient"::VARIANT[2]) AS unique_z_positions,
              COUNT(*) AS total_images,
              COUNT(DISTINCT "ImageOrientationPatient") AS unique_image_orientations,
              MAX(ABS(
                  CAST("ImageOrientationPatient"::VARIANT[0] AS FLOAT) *
                  CAST("ImageOrientationPatient"::VARIANT[4] AS FLOAT) - 
                  CAST("ImageOrientationPatient"::VARIANT[1] AS FLOAT) *
                  CAST("ImageOrientationPatient"::VARIANT[3] AS FLOAT)
              )) AS max_z_alignment_value
          FROM IDC.IDC_V17.DICOM_ALL
          WHERE "collection_id" != 'nlst'
            AND "Modality" = 'CT'
            AND "TransferSyntaxUID" NOT IN ('1.2.840.10008.1.2.4.70', '1.2.840.10008.1.2.4.51')
            AND "ImageType" NOT ILIKE '%LOCALIZER%'
          GROUP BY "SeriesInstanceUID"
      ) AS series_summary
      WHERE unique_rows = 1 
        AND unique_columns = 1
        AND unique_pixel_spacings = 1
        AND unique_z_positions = total_images
        AND unique_image_orientations = 1
        AND max_z_alignment_value BETWEEN 0.99 AND 1.01
  )
GROUP BY "SeriesInstanceUID", "SeriesNumber", "PatientID"
ORDER BY series_size_mib DESC NULLS LAST -- Sort by series size in descending order
LIMIT 5;