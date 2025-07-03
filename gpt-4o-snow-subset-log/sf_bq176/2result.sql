WITH CytobandRange AS (
    -- Retrieve the start and end positions of cytoband 15q11 on chromosome 15
    SELECT 
        "hg38_start" AS cytoband_start, 
        "hg38_stop" AS cytoband_end
    FROM "TCGA_MITELMAN"."PROD"."CYTOBANDS_HG38"
    WHERE "cytoband_name" = '15q11' AND "chromosome" = 'chr15'
),
FilteredSegments AS (
    -- Retrieve segment data for TCGA-LAML study specific to chromosome 15
    SELECT 
        "case_barcode", 
        "start_pos", 
        "end_pos", 
        "segment_mean"
    FROM "TCGA_MITELMAN"."TCGA_VERSIONED"."COPY_NUMBER_SEGMENT_MASKED_HG38_GDC_2017_02"
    WHERE "project_short_name" = 'TCGA-LAML' AND "chromosome" = '15'
),
OverlappingSegments AS (
    -- Identify only the segments that overlap with the cytoband 15q11
    SELECT 
        fs."case_barcode", 
        GREATEST(fs."start_pos", cr.cytoband_start) AS overlap_start, 
        LEAST(fs."end_pos", cr.cytoband_end) AS overlap_end, 
        fs."segment_mean"
    FROM FilteredSegments fs
    CROSS JOIN CytobandRange cr
    WHERE fs."end_pos" >= cr.cytoband_start AND fs."start_pos" <= cr.cytoband_end
),
WeightedCopyNumber AS (
    -- Calculate the weighted contribution of each segment's copy number to the cytoband
    SELECT 
        "case_barcode",
        (overlap_end - overlap_start + 1) * POWER(2, "segment_mean") AS weighted_copy_number,
        overlap_end - overlap_start + 1 AS segment_length
    FROM OverlappingSegments
),
CaseTotalCopyNumber AS (
    -- Sum the weighted copy numbers and lengths per case to get weighted average
    SELECT 
        "case_barcode",
        SUM(weighted_copy_number) AS total_weighted_copy,
        SUM(segment_length) AS total_length,
        SUM(weighted_copy_number) / NULLIF(SUM(segment_length), 0) AS weighted_avg_copy_number
    FROM WeightedCopyNumber
    GROUP BY "case_barcode"
)
-- Retrieve the cases with the highest weighted average copy number in cytoband 15q11
SELECT 
    "case_barcode", 
    weighted_avg_copy_number
FROM CaseTotalCopyNumber
ORDER BY weighted_avg_copy_number DESC NULLS LAST
LIMIT 10;