WITH cytoband_region AS (
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
    SELECT 
        seg."case_barcode", 
        seg."chromosome" AS "segment_chromosome", 
        seg."start_pos", 
        seg."end_pos", 
        seg."segment_mean",
        POWER(2, seg."segment_mean" + 1) AS "copy_number",  -- Convert log2 CN ratio back to linear
        GREATEST(
            LEAST(seg."end_pos", cr."hg38_stop") - GREATEST(seg."start_pos", cr."hg38_start"), 
            0
        ) AS "overlap_length"
    FROM 
        TCGA_MITELMAN.TCGA_VERSIONED.COPY_NUMBER_SEGMENT_MASKED_HG38_GDC_2017_02 seg,
        cytoband_region cr
    WHERE 
        seg."chromosome" = REPLACE(cr."chromosome", 'chr', '')  -- Match chromosome
        AND seg."end_pos" > cr."hg38_start"
        AND seg."start_pos" < cr."hg38_stop"
        AND seg."project_short_name" = 'TCGA-LAML'
),
weighted_copy_number AS (
    SELECT 
        "case_barcode", 
        SUM("copy_number" * "overlap_length") / NULLIF(SUM("overlap_length"), 0) AS "weighted_avg_copy_number"
    FROM 
        segment_data
    WHERE 
        "overlap_length" > 0
    GROUP BY 
        "case_barcode"
)
SELECT 
    "case_barcode", 
    "weighted_avg_copy_number"
FROM 
    weighted_copy_number
ORDER BY 
    "weighted_avg_copy_number" DESC NULLS LAST;