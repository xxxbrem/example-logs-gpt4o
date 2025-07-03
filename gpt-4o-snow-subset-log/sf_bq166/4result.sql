WITH cytoband_classification AS (
    SELECT 
        s."case_barcode", 
        s."chromosome", 
        c."cytoband_name", 
        MAX(s."copy_number") AS "max_copy_number",
        CASE
            WHEN MAX(s."copy_number") > 3 THEN 'amplification'
            WHEN MAX(s."copy_number") = 3 THEN 'gain'
            WHEN MAX(s."copy_number") = 0 THEN 'homozygous deletion'
            WHEN MAX(s."copy_number") = 1 THEN 'heterozygous deletion'
            WHEN MAX(s."copy_number") = 2 THEN 'normal'
        END AS "classification"
    FROM TCGA_MITELMAN.TCGA_VERSIONED.COPY_NUMBER_SEGMENT_ALLELIC_HG38_GDC_R23 s
    JOIN TCGA_MITELMAN.PROD.CYTOBANDS_HG38 c
      ON s."chromosome" = c."chromosome"
     AND s."end_pos" >= c."hg38_start" 
     AND s."start_pos" <= c."hg38_stop"
    WHERE s."project_short_name" = 'TCGA-KIRC'
    GROUP BY s."case_barcode", s."chromosome", c."cytoband_name"
),
case_totals AS (
    SELECT COUNT(DISTINCT "case_barcode") AS "total_cases"
    FROM TCGA_MITELMAN.TCGA_VERSIONED.COPY_NUMBER_SEGMENT_ALLELIC_HG38_GDC_R23
    WHERE "project_short_name" = 'TCGA-KIRC'
)
SELECT 
    t."chromosome", 
    t."cytoband_name", 
    t."classification", 
    COUNT(DISTINCT t."case_barcode") AS "case_count",
    ROUND(
        COUNT(DISTINCT t."case_barcode") * 100.0 / c."total_cases", 
        4
    ) AS "percentage"
FROM cytoband_classification t
CROSS JOIN case_totals c
GROUP BY t."chromosome", t."cytoband_name", t."classification", c."total_cases"
ORDER BY t."chromosome", t."cytoband_name", t."classification"
LIMIT 20;