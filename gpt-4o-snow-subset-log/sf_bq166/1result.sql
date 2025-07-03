SELECT 
    "chromosome", 
    "cytoband_name", 
    "copy_number_type",
    (COUNT(DISTINCT "case_barcode") * 100.0 /
     (SELECT COUNT(DISTINCT "case_barcode")
      FROM TCGA_MITELMAN.TCGA_VERSIONED.COPY_NUMBER_SEGMENT_ALLELIC_HG38_GDC_R23
      WHERE "project_short_name" = 'TCGA-KIRC')) AS "frequency_percentage"
FROM (
    SELECT 
        cyto."chromosome" AS "chromosome", 
        cyto."cytoband_name" AS "cytoband_name", 
        cns."case_barcode",
        MAX(cns."copy_number") AS "max_copy_number",
        CASE 
            WHEN MAX(cns."copy_number") > 3 THEN 'amplifications'
            WHEN MAX(cns."copy_number") = 3 THEN 'gains'
            WHEN MAX(cns."copy_number") = 2 THEN 'normal'
            WHEN MAX(cns."copy_number") = 1 THEN 'heterozygous deletions'
            WHEN MAX(cns."copy_number") = 0 THEN 'homozygous deletions'
        END AS "copy_number_type"
    FROM TCGA_MITELMAN.TCGA_VERSIONED.COPY_NUMBER_SEGMENT_ALLELIC_HG38_GDC_R23 cns
    JOIN TCGA_MITELMAN.PROD.CYTOBANDS_HG38 cyto
      ON cns."chromosome" = cyto."chromosome"
      AND cns."start_pos" <= cyto."hg38_stop"
      AND cns."end_pos" >= cyto."hg38_start"
    WHERE cns."project_short_name" = 'TCGA-KIRC'
    GROUP BY cyto."chromosome", cyto."cytoband_name", cns."case_barcode"
) grouped
GROUP BY "chromosome", "cytoband_name", "copy_number_type"
ORDER BY "chromosome", "cytoband_name", "frequency_percentage" DESC NULLS LAST
LIMIT 20;