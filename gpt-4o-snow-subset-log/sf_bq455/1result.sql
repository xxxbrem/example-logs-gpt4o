WITH FilteredSeries AS (
    SELECT 
        "SeriesInstanceUID",
        "SeriesNumber",
        "PatientID",
        SUM("instance_size") / 1048576.0 AS series_size_mib,
        COUNT(DISTINCT "ImageOrientationPatient") AS unique_orientations,
        COUNT(DISTINCT "ImagePositionPatient"::VARIANT[2]) AS unique_z_positions,
        COUNT(*) AS total_images,
        COUNT(DISTINCT "Rows") AS unique_rows,
        COUNT(DISTINCT "Columns") AS unique_columns,
        MAX(ABS(
            ("ImageOrientationPatient"::VARIANT[0]::FLOAT * "ImageOrientationPatient"::VARIANT[4]::FLOAT) -
            ("ImageOrientationPatient"::VARIANT[1]::FLOAT * "ImageOrientationPatient"::VARIANT[3]::FLOAT)
        )) AS max_cross_product_z
    FROM 
        IDC.IDC_V17.DICOM_ALL
    WHERE 
        "Modality" = 'CT'
        AND "collection_id" != 'nlst'
        AND "TransferSyntaxUID" NOT IN ('1.2.840.10008.1.2.4.70', '1.2.840.10008.1.2.4.51') -- Exclude JPEG compressed
        AND "ImageType" NOT ILIKE '%LOCALIZER%' -- Exclude LOCALIZER
    GROUP BY 
        "SeriesInstanceUID", "SeriesNumber", "PatientID"
    HAVING 
        COUNT(DISTINCT "ImageOrientationPatient") = 1 -- Ensure consistent image orientation
        AND unique_z_positions = total_images -- Ensure no duplicate slices
        AND unique_rows = 1 -- Uniform pixel rows
        AND unique_columns = 1 -- Uniform pixel columns
        AND max_cross_product_z BETWEEN 0.99 AND 1.01 -- Ensure proper imaging plane alignment
),
TopSeries AS (
    SELECT 
        "SeriesInstanceUID",
        "SeriesNumber",
        "PatientID",
        series_size_mib
    FROM 
        FilteredSeries
    ORDER BY 
        series_size_mib DESC NULLS LAST
    LIMIT 5
)
SELECT 
    "SeriesInstanceUID",
    "SeriesNumber",
    "PatientID",
    series_size_mib
FROM 
    TopSeries;