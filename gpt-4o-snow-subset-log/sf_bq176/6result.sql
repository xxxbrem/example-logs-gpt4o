WITH cytoband_range AS (
    -- Step 1: Get the start and stop positions for cytoband 15q11 on chromosome 15
    SELECT 
        "hg38_start" AS "start_pos",
        "hg38_stop" AS "end_pos"
    FROM TCGA_MITELMAN.PROD.CYTOBANDS_HG38
    WHERE "cytoband_name" = '15q11' AND "chromosome" = 'chr15'
),
segment_data AS (
    -- Step 2: Identify overlapping segments in TCGA-LAML project within cytoband 15q11
    SELECT 
        seg."case_barcode",
        seg."start_pos",
        seg."end_pos",
        seg."segment_mean",
        LEAST(cyt."end_pos", seg."end_pos") - GREATEST(cyt."start_pos", seg."start_pos") AS "overlap_length"
    FROM TCGA_MITELMAN.TCGA_VERSIONED.COPY_NUMBER_SEGMENT_MASKED_HG38_GDC_2017_02 seg
    CROSS JOIN cytoband_range cyt
    WHERE seg."chromosome" = '15' 
      AND seg."project_short_name" = 'TCGA-LAML'
      AND seg."start_pos" <= cyt."end_pos" 
      AND seg."end_pos" >= cyt."start_pos"
),
weighted_avg_copy_number AS (
    -- Step 3: Calculate weighted average copy number for each case in cytoband 15q11
    SELECT 
        "case_barcode",
        SUM("segment_mean" * "overlap_length") / SUM("overlap_length") AS "weighted_avg_cn"
    FROM segment_data
    GROUP BY "case_barcode"
)
-- Step 4: Return the case barcodes with the highest weighted average copy number
SELECT 
    "case_barcode",
    "weighted_avg_cn"
FROM weighted_avg_copy_number
ORDER BY "weighted_avg_cn" DESC NULLS LAST
LIMIT 10;