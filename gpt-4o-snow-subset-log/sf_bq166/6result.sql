WITH CytoBandMaxCopy AS (
    -- Step 1: Identify the maximum copy number per cytoband for each sample
    SELECT 
        c."chromosome",
        c."cytoband_name",
        t."case_barcode",
        MAX(t."copy_number") AS "max_copy_number"
    FROM 
        TCGA_MITELMAN.PROD.CYTOBANDS_HG38 c
    JOIN 
        TCGA_MITELMAN.TCGA_VERSIONED.COPY_NUMBER_SEGMENT_ALLELIC_HG38_GDC_R23 t
    ON 
        c."chromosome" = t."chromosome" 
        AND GREATEST(0, LEAST(t."end_pos", c."hg38_stop") - GREATEST(t."start_pos", c."hg38_start")) > 0
    WHERE 
        t."project_short_name" = 'TCGA-KIRC'
    GROUP BY 
        c."chromosome", c."cytoband_name", t."case_barcode"
),
ClassifiedCopyNumbers AS (
    -- Step 2: Classify the maximum copy numbers into categories
    SELECT 
        "chromosome",
        "cytoband_name",
        "case_barcode",
        "max_copy_number",
        CASE 
            WHEN "max_copy_number" > 3 THEN 'amplifications'
            WHEN "max_copy_number" = 3 THEN 'gains'
            WHEN "max_copy_number" = 0 THEN 'homozygous deletions'
            WHEN "max_copy_number" = 1 THEN 'heterozygous deletions'
            WHEN "max_copy_number" = 2 THEN 'normal'
        END AS "copy_number_category"
    FROM 
        CytoBandMaxCopy
),
CaseFrequencies AS (
    -- Step 3: Calculate the frequency of each category by cytoband
    SELECT 
        "chromosome",
        "cytoband_name",
        "copy_number_category",
        COUNT(DISTINCT "case_barcode") AS "case_count"
    FROM 
        ClassifiedCopyNumbers
    GROUP BY 
        "chromosome", "cytoband_name", "copy_number_category"
),
TotalCasesByCytoband AS (
    -- Step 4: Calculate the total number of distinct cases per cytoband
    SELECT 
        "chromosome",
        "cytoband_name",
        COUNT(DISTINCT "case_barcode") AS "total_cases"
    FROM 
        CytoBandMaxCopy
    GROUP BY 
        "chromosome", "cytoband_name"
),
CategoryFrequencies AS (
    -- Step 5: Combine the case frequencies with the total cases to calculate percentages
    SELECT 
        cf."chromosome",
        cf."cytoband_name",
        cf."copy_number_category",
        cf."case_count",
        tc."total_cases",
        (cf."case_count" * 100.0 / tc."total_cases") AS "frequency_percentage"
    FROM 
        CaseFrequencies cf
    JOIN 
        TotalCasesByCytoband tc
    ON 
        cf."chromosome" = tc."chromosome" 
        AND cf."cytoband_name" = tc."cytoband_name"
)
-- Step 6: Final output sorted by chromosome and cytoband
SELECT 
    "chromosome",
    "cytoband_name",
    "copy_number_category",
    "frequency_percentage"
FROM 
    CategoryFrequencies
ORDER BY 
    "chromosome", 
    "cytoband_name",
    "copy_number_category";