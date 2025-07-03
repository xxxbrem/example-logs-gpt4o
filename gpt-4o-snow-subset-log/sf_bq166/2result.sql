SELECT 
    c."chromosome",
    c."cytoband_name",
    ROUND(
        100.0 * COUNT(CASE WHEN t."max_copy_number" > 3 THEN 1 END) 
        / COUNT(DISTINCT t."case_barcode"), 4
    ) AS "amplifications_percentage",
    ROUND(
        100.0 * COUNT(CASE WHEN t."max_copy_number" = 3 THEN 1 END) 
        / COUNT(DISTINCT t."case_barcode"), 4
    ) AS "gains_percentage",
    ROUND(
        100.0 * COUNT(CASE WHEN t."max_copy_number" = 2 THEN 1 END) 
        / COUNT(DISTINCT t."case_barcode"), 4
    ) AS "normal_percentage",
    ROUND(
        100.0 * COUNT(CASE WHEN t."max_copy_number" = 1 THEN 1 END) 
        / COUNT(DISTINCT t."case_barcode"), 4
    ) AS "heterozygous_deletions_percentage",
    ROUND(
        100.0 * COUNT(CASE WHEN t."max_copy_number" = 0 THEN 1 END) 
        / COUNT(DISTINCT t."case_barcode"), 4
    ) AS "homozygous_deletions_percentage"
FROM (
    SELECT 
        copy_segment."case_barcode", 
        cytoband."cytoband_name", 
        MAX(copy_segment."copy_number") AS "max_copy_number"
    FROM "TCGA_MITELMAN"."TCGA_VERSIONED"."COPY_NUMBER_SEGMENT_ALLELIC_HG38_GDC_R23" copy_segment
    JOIN "TCGA_MITELMAN"."PROD"."CYTOBANDS_HG38" cytoband
        ON copy_segment."chromosome" = cytoband."chromosome"
        AND copy_segment."start_pos" < cytoband."hg38_stop"
        AND copy_segment."end_pos" > cytoband."hg38_start"
    WHERE copy_segment."project_short_name" = 'TCGA-KIRC'
    GROUP BY copy_segment."case_barcode", cytoband."cytoband_name"
) t
JOIN "TCGA_MITELMAN"."PROD"."CYTOBANDS_HG38" c
  ON t."cytoband_name" = c."cytoband_name"
GROUP BY c."chromosome", c."cytoband_name"
ORDER BY c."chromosome", c."cytoband_name";