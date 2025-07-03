WITH cytoband_range AS (
    SELECT 
        "chromosome",
        "cytoband_name",
        "hg38_start",
        "hg38_stop"
    FROM TCGA_MITELMAN.PROD.CYTOBANDS_HG38
    WHERE "chromosome" = 'chr15' AND "cytoband_name" = '15q11'
),
segment_data AS (
    SELECT 
        "case_barcode",
        "chromosome",
        "start_pos",
        "end_pos",
        "segment_mean",
        (POWER(2, "segment_mean") * 2) AS "copy_number" -- Calculating the actual copy number from segment mean
    FROM TCGA_MITELMAN.TCGA_VERSIONED.COPY_NUMBER_SEGMENT_MASKED_HG38_GDC_2017_02
    WHERE "project_short_name" = 'TCGA-LAML' AND "chromosome" = '15'
),
overlap_data AS (
    SELECT
        s."case_barcode",
        s."chromosome",
        GREATEST(s."start_pos", c."hg38_start") AS overlap_start,
        LEAST(s."end_pos", c."hg38_stop") AS overlap_end,
        s."copy_number",
        (LEAST(s."end_pos", c."hg38_stop") - GREATEST(s."start_pos", c."hg38_start")) AS overlap_length
    FROM segment_data s
    JOIN cytoband_range c
    ON s."start_pos" < c."hg38_stop" AND s."end_pos" > c."hg38_start"
),
weighted_copy_number AS (
    SELECT
        "case_barcode",
        SUM("copy_number" * overlap_length) / SUM(overlap_length) AS weighted_avg_copy_number
    FROM overlap_data
    GROUP BY "case_barcode"
)
SELECT 
    "case_barcode", 
    weighted_avg_copy_number
FROM weighted_copy_number
ORDER BY weighted_avg_copy_number DESC NULLS LAST;