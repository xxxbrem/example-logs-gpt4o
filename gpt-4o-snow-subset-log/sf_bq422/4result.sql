WITH Top3_By_Slice_Interval AS (
    SELECT 
        "PatientID",
        "SeriesInstanceUID",
        SUM("instance_size") / (1024 * 1024) AS "Series_Size_MiB"
    FROM IDC.IDC_V17.DICOM_ALL
    WHERE "collection_id" = 'nlst' AND "Modality" = 'CT'
          AND "PatientID" IN (
              SELECT "PatientID"
              FROM (
                  SELECT 
                      "PatientID",
                      MAX("Slice_Interval_Difference") AS "Max_Slice_Interval_Difference"
                  FROM (
                      SELECT 
                          "PatientID", 
                          MAX("SliceThickness"::FLOAT) - MIN("SliceThickness"::FLOAT) AS "Slice_Interval_Difference"
                      FROM IDC.IDC_V17.DICOM_ALL
                      WHERE "collection_id" = 'nlst' AND "Modality" = 'CT'
                            AND "SliceThickness" IS NOT NULL
                      GROUP BY "PatientID"
                  ) AS slice_intervals
                  GROUP BY "PatientID"
                  ORDER BY "Max_Slice_Interval_Difference" DESC NULLS LAST
                  LIMIT 3
              )
          )
    GROUP BY "PatientID", "SeriesInstanceUID"
),
Top3_By_Max_Exposure AS (
    SELECT 
        "PatientID",
        "SeriesInstanceUID",
        SUM("instance_size") / (1024 * 1024) AS "Series_Size_MiB"
    FROM IDC.IDC_V17.DICOM_ALL
    WHERE "collection_id" = 'nlst' AND "Modality" = 'CT'
          AND "PatientID" IN (
              SELECT "PatientID"
              FROM (
                  SELECT 
                      "PatientID",
                      MAX("Exposure_Difference") AS "Max_Exposure_Difference"
                  FROM (
                      SELECT 
                          "PatientID", 
                          MAX("Exposure"::FLOAT) - MIN("Exposure"::FLOAT) AS "Exposure_Difference"
                      FROM IDC.IDC_V17.DICOM_ALL
                      WHERE "collection_id" = 'nlst' AND "Modality" = 'CT'
                            AND "Exposure" IS NOT NULL
                      GROUP BY "PatientID"
                  ) AS exposures
                  GROUP BY "PatientID"
                  ORDER BY "Max_Exposure_Difference" DESC NULLS LAST
                  LIMIT 3
              )
          )
    GROUP BY "PatientID", "SeriesInstanceUID"
),
Average_Series_Size AS (
    SELECT 
        'Top 3 by Slice Interval' AS "Group_Label",
        AVG("Series_Size_MiB") AS "Average_Series_Size_MiB"
    FROM Top3_By_Slice_Interval
    UNION ALL
    SELECT 
        'Top 3 by Max Exposure' AS "Group_Label",
        AVG("Series_Size_MiB") AS "Average_Series_Size_MiB"
    FROM Top3_By_Max_Exposure
)
SELECT * FROM Average_Series_Size;