WITH Cytoband15q11 AS (
    SELECT 
        "cytoband_name", 
        "hg38_start", 
        "hg38_stop", 
        "chromosome"
    FROM TCGA_MITELMAN.PROD.CYTOBANDS_HG38
    WHERE "cytoband_name" = '15q11'
),
FilteredSegments AS (
    SELECT 
        s."case_barcode", 
        s."chromosome", 
        s."start_pos", 
        s."end_pos", 
        s."segment_mean", 
        Cytoband15q11."hg38_start" AS "cytoband_start", 
        Cytoband15q11."hg38_stop" AS "cytoband_end"
    FROM TCGA_MITELMAN.TCGA_VERSIONED.COPY_NUMBER_SEGMENT_MASKED_HG38_GDC_2017_02 s
    JOIN Cytoband15q11
    ON CONCAT('chr', s."chromosome") = Cytoband15q11."chromosome" -- Adjusting for potential chr prefix mismatch
    WHERE s."chromosome" = '15'
    AND s."start_pos" <= Cytoband15q11."hg38_stop"
    AND s."end_pos" >= Cytoband15q11."hg38_start"
),
SegmentWeights AS (
    SELECT 
        "case_barcode", 
        "chromosome", 
        "start_pos", 
        "end_pos", 
        "segment_mean", 
        LEAST("end_pos", "cytoband_end") - GREATEST("start_pos", "cytoband_start") AS "overlap_length"
    FROM FilteredSegments
    WHERE LEAST("end_pos", "cytoband_end") > GREATEST("start_pos", "cytoband_start") -- Ensure a positive overlap
),
WeightedCopyNumbers AS (
    SELECT 
        "case_barcode", 
        SUM("segment_mean" * "overlap_length") / NULLIF(SUM("overlap_length"), 0) AS "weighted_avg_copy_number"
    FROM SegmentWeights
    GROUP BY "case_barcode"
)
SELECT 
    "case_barcode", 
    "weighted_avg_copy_number"
FROM WeightedCopyNumbers
WHERE "case_barcode" LIKE 'TCGA%'
ORDER BY "weighted_avg_copy_number" DESC NULLS LAST
LIMIT 20;