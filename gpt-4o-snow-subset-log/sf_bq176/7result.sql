WITH cytoband_data AS (
    SELECT 
        "chromosome", 
        "cytoband_name", 
        "hg38_start", 
        "hg38_stop"
    FROM 
        "TCGA_MITELMAN"."PROD"."CYTOBANDS_HG38"
    WHERE 
        "chromosome" = 'chr15' 
        AND "cytoband_name" = '15q11'
),
segment_data AS (
    SELECT 
        "case_barcode", 
        "chromosome", 
        "start_pos", 
        "end_pos", 
        "segment_mean", 
        "project_short_name"
    FROM 
        "TCGA_MITELMAN"."TCGA_VERSIONED"."COPY_NUMBER_SEGMENT_MASKED_HG38_GDC_2017_02"
    WHERE 
        "chromosome" = '15' 
        AND "project_short_name" = 'TCGA-LAML'
),
overlap_data AS (
    SELECT 
        segment_data."case_barcode", 
        segment_data."segment_mean", 
        (LEAST(segment_data."end_pos", cytoband_data."hg38_stop") - GREATEST(segment_data."start_pos", cytoband_data."hg38_start")) AS overlap_length
    FROM 
        segment_data
    JOIN 
        cytoband_data
    ON 
        segment_data."start_pos" < cytoband_data."hg38_stop" 
        AND segment_data."end_pos" > cytoband_data."hg38_start"
    WHERE 
        (LEAST(segment_data."end_pos", cytoband_data."hg38_stop") - GREATEST(segment_data."start_pos", cytoband_data."hg38_start")) > 0
),
weighted_avg AS (
    SELECT 
        "case_barcode", 
        SUM((LEAST(segment_data."end_pos", cytoband_data."hg38_stop") - GREATEST(segment_data."start_pos", cytoband_data."hg38_start")) * segment_data."segment_mean") / 
        SUM(LEAST(segment_data."end_pos", cytoband_data."hg38_stop") - GREATEST(segment_data."start_pos", cytoband_data."hg38_start")) AS weighted_segment_mean
    FROM 
        segment_data
    JOIN 
        cytoband_data
    ON 
        segment_data."start_pos" < cytoband_data."hg38_stop" 
        AND segment_data."end_pos" > cytoband_data."hg38_start"
    GROUP BY 
        "case_barcode"
)
SELECT 
    "case_barcode", 
    weighted_segment_mean
FROM 
    weighted_avg
ORDER BY 
    weighted_segment_mean DESC NULLS LAST;