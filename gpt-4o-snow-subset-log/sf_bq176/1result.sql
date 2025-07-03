WITH cytoband_data AS (
    -- Retrieve the start and end positions of cytoband 15q11 on chr15
    SELECT 
        "chromosome", 
        "cytoband_name", 
        "hg38_start", 
        "hg38_stop"
    FROM 
        TCGA_MITELMAN.PROD.CYTOBANDS_HG38
    WHERE 
        "chromosome" = 'chr15' AND "cytoband_name" = '15q11'
), 
segment_data AS (
    -- Retrieve segment data for TCGA-LAML on chromosome 15 that overlaps 15q11
    SELECT 
        s."case_barcode",
        s."project_short_name",
        s."chromosome",
        s."start_pos",
        s."end_pos",
        s."segment_mean",
        cytoband_data."hg38_start" AS cytoband_start,
        cytoband_data."hg38_stop" AS cytoband_stop
    FROM 
        TCGA_MITELMAN.TCGA_VERSIONED.COPY_NUMBER_SEGMENT_MASKED_HG38_GDC_2017_02 s
    CROSS JOIN 
        cytoband_data
    WHERE 
        s."project_short_name" = 'TCGA-LAML' 
        AND s."chromosome" = '15'
        AND (
            (s."start_pos" BETWEEN cytoband_data."hg38_start" AND cytoband_data."hg38_stop") OR 
            (s."end_pos" BETWEEN cytoband_data."hg38_start" AND cytoband_data."hg38_stop") OR
            (s."start_pos" <= cytoband_data."hg38_start" AND s."end_pos" >= cytoband_data."hg38_stop") -- Segment fully spans cytoband
        )
),
weighted_average AS (
    -- Calculate the weighted average copy number for each case
    SELECT 
        "case_barcode",
        SUM(("segment_mean" * (LEAST("end_pos", cytoband_stop) - GREATEST("start_pos", cytoband_start)))) /
        NULLIF(SUM(LEAST("end_pos", cytoband_stop) - GREATEST("start_pos", cytoband_start)), 0) AS weighted_avg_cn
    FROM 
        segment_data
    GROUP BY 
        "case_barcode"
)
-- Retrieve the case barcodes with the highest weighted average copy number
SELECT 
    "case_barcode",
    weighted_avg_cn
FROM 
    weighted_average
ORDER BY 
    weighted_avg_cn DESC NULLS LAST
LIMIT 10;