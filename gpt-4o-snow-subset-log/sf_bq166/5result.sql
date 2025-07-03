WITH MaxCopyNumberPerCytoband AS (
    SELECT 
        CNV."case_barcode", 
        CNV."chromosome", 
        CYTO."cytoband_name", 
        MAX(CNV."copy_number") AS "max_copy_number"
    FROM TCGA_MITELMAN.TCGA_VERSIONED.COPY_NUMBER_SEGMENT_ALLELIC_HG38_GDC_R23 CNV
    JOIN TCGA_MITELMAN.PROD.CYTOBANDS_HG38 CYTO
        ON CNV."chromosome" = CYTO."chromosome"
        AND CNV."start_pos" <= CYTO."hg38_stop"
        AND CNV."end_pos" >= CYTO."hg38_start"
    WHERE CNV."project_short_name" = 'TCGA-KIRC'
    GROUP BY CNV."case_barcode", CNV."chromosome", CYTO."cytoband_name"
),
CategorizedCopyNumbers AS (
    SELECT 
        "chromosome", 
        "cytoband_name", 
        "case_barcode", 
        "max_copy_number", 
        CASE 
            WHEN "max_copy_number" > 3 THEN 'Amplifications'
            WHEN "max_copy_number" = 3 THEN 'Gains'
            WHEN "max_copy_number" = 0 THEN 'Homozygous Deletions'
            WHEN "max_copy_number" = 1 THEN 'Heterozygous Deletions'
            WHEN "max_copy_number" = 2 THEN 'Normal'
            ELSE 'Other'
        END AS "category"
    FROM MaxCopyNumberPerCytoband
),
FrequencyByCytoband AS (
    SELECT 
        "chromosome", 
        "cytoband_name", 
        "category", 
        COUNT(DISTINCT "case_barcode") AS "case_count",
        (COUNT(DISTINCT "case_barcode") * 100.0 / SUM(COUNT(DISTINCT "case_barcode")) OVER (PARTITION BY "chromosome", "cytoband_name")) AS "frequency_percentage"
    FROM CategorizedCopyNumbers
    GROUP BY "chromosome", "cytoband_name", "category"
)
SELECT 
    "chromosome", 
    "cytoband_name", 
    "category", 
    "case_count", 
    ROUND("frequency_percentage", 4) AS "frequency_percentage"
FROM FrequencyByCytoband
ORDER BY "chromosome", "cytoband_name", "frequency_percentage" DESC NULLS LAST
LIMIT 20;