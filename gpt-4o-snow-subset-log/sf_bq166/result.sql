WITH max_copy_numbers AS (
    SELECT c."chromosome",
           b."cytoband_name",
           MAX(c."copy_number") AS "max_copy_number",
           CASE
               WHEN MAX(c."copy_number") > 3 THEN 'amplifications'
               WHEN MAX(c."copy_number") = 3 THEN 'gains'
               WHEN MAX(c."copy_number") = 2 THEN 'normal_diploid'
               WHEN MAX(c."copy_number") = 1 THEN 'heterozygous_deletions'
               WHEN MAX(c."copy_number") = 0 THEN 'homozygous_deletions'
               ELSE 'others'
           END AS "copy_number_category",
           COUNT(DISTINCT c."sample_barcode") AS "case_count"
    FROM TCGA_MITELMAN.TCGA_VERSIONED.COPY_NUMBER_SEGMENT_ALLELIC_HG38_GDC_R23 c
    INNER JOIN TCGA_MITELMAN.PROD.CYTOBANDS_HG38 b
    ON c."chromosome" = b."chromosome"
       AND c."start_pos" <= b."hg38_stop"
       AND c."end_pos" >= b."hg38_start"
    WHERE c."project_short_name" = 'TCGA-KIRC'
    GROUP BY c."chromosome", b."cytoband_name"
),
total_cases AS (
    SELECT COUNT(DISTINCT "sample_barcode") AS "total_cases"
    FROM TCGA_MITELMAN.TCGA_VERSIONED.COPY_NUMBER_SEGMENT_ALLELIC_HG38_GDC_R23
    WHERE "project_short_name" = 'TCGA-KIRC'
)
SELECT mcn."chromosome",
       mcn."cytoband_name",
       mcn."copy_number_category",
       mcn."case_count",
       tc."total_cases",
       (mcn."case_count" * 100.0 / tc."total_cases") AS "frequency_percentage"
FROM max_copy_numbers mcn, 
     total_cases tc
ORDER BY mcn."chromosome", mcn."cytoband_name", mcn."copy_number_category"
LIMIT 20;