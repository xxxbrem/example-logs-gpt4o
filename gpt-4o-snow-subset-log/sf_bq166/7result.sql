WITH Max_Copy_Number AS (
  -- Step 1: Compute maximum copy number per cytoband for each sample
  SELECT 
    t."chromosome",
    c."cytoband_name",
    t."case_barcode",
    MAX(t."copy_number") AS "max_copy_number"
  FROM TCGA_MITELMAN.TCGA_VERSIONED.COPY_NUMBER_SEGMENT_ALLELIC_HG38_GDC_R23 t
  JOIN TCGA_MITELMAN.PROD.CYTOBANDS_HG38 c
    ON t."chromosome" = c."chromosome"
    AND t."start_pos" <= c."hg38_stop"
    AND t."end_pos" >= c."hg38_start"
  WHERE t."project_short_name" = 'TCGA-KIRC'
  GROUP BY t."chromosome", c."cytoband_name", t."case_barcode"
),
CNV_Categorized AS (
  -- Step 2: Categorize maximum copy numbers into CNV subtypes
  SELECT 
    m."chromosome",
    m."cytoband_name",
    m."case_barcode",
    m."max_copy_number",
    CASE 
      WHEN m."max_copy_number" > 3 THEN 'Amplification'
      WHEN m."max_copy_number" = 3 THEN 'Gain'
      WHEN m."max_copy_number" = 0 THEN 'Homozygous Deletion'
      WHEN m."max_copy_number" = 1 THEN 'Heterozygous Deletion'
      WHEN m."max_copy_number" = 2 THEN 'Normal'
      ELSE 'Unknown'
    END AS "cnv_category"
  FROM Max_Copy_Number m
),
CNV_Frequencies AS (
  -- Step 3: Calculate the frequency of each CNV subtype per cytoband
  SELECT
    c."chromosome",
    c."cytoband_name",
    c."cnv_category",
    COUNT(DISTINCT c."case_barcode") AS "cnv_count"
  FROM CNV_Categorized c
  GROUP BY c."chromosome", c."cytoband_name", c."cnv_category"
),
Total_Cases_Per_Cytoband AS (
  -- Step 4: Calculate total distinct cases per cytoband across all CNV categories
  SELECT
    c."chromosome",
    c."cytoband_name",
    COUNT(DISTINCT c."case_barcode") AS "total_cases"
  FROM Max_Copy_Number c
  GROUP BY c."chromosome", c."cytoband_name"
),
Percentage_Frequencies AS (
  -- Step 5: Calculate percentages
  SELECT 
    f."chromosome",
    f."cytoband_name",
    f."cnv_category",
    f."cnv_count",
    t."total_cases",
    ROUND((f."cnv_count" * 100.0 / t."total_cases"), 4) AS "percentage_frequency"
  FROM CNV_Frequencies f
  JOIN Total_Cases_Per_Cytoband t
    ON f."chromosome" = t."chromosome"
    AND f."cytoband_name" = t."cytoband_name"
)
-- Final output with sorting and limit
SELECT 
  p."chromosome",
  p."cytoband_name",
  p."cnv_category",
  p."cnv_count",
  p."total_cases",
  p."percentage_frequency"
FROM Percentage_Frequencies p
ORDER BY p."chromosome", p."cytoband_name", p."cnv_category", p."percentage_frequency" DESC NULLS LAST
LIMIT 20;