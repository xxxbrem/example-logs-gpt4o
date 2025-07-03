WITH ClassificationTable AS (
  SELECT 
      cna."chromosome", 
      bands."cytoband_name", 
      cna."case_barcode",
      CASE 
          WHEN MAX(cna."copy_number") > 3 THEN 'Amplification'
          WHEN MAX(cna."copy_number") = 3 THEN 'Gain'
          WHEN MAX(cna."copy_number") = 0 THEN 'Homozygous Deletion'
          WHEN MAX(cna."copy_number") = 1 THEN 'Heterozygous Deletion'
          ELSE 'Normal'
      END AS "classification"
  FROM TCGA_MITELMAN.TCGA_VERSIONED.COPY_NUMBER_SEGMENT_ALLELIC_HG38_GDC_R23 cna
  JOIN TCGA_MITELMAN.PROD.CYTOBANDS_HG38 bands
    ON cna."chromosome" = bands."chromosome"
  WHERE cna."project_short_name" = 'TCGA-KIRC'
  AND cna."start_pos" <= bands."hg38_stop"
  AND cna."end_pos" >= bands."hg38_start"
  GROUP BY cna."chromosome", bands."cytoband_name", cna."case_barcode"
), 
TotalCases AS (
  SELECT COUNT(DISTINCT "case_barcode") AS total
  FROM TCGA_MITELMAN.TCGA_VERSIONED.COPY_NUMBER_SEGMENT_ALLELIC_HG38_GDC_R23
  WHERE "project_short_name" = 'TCGA-KIRC'
)
SELECT 
    classification_table."chromosome", 
    classification_table."cytoband_name", 
    classification_table."classification", 
    COUNT(DISTINCT classification_table."case_barcode") * 100.0 / total_cases.total AS "percentage_frequency"
FROM ClassificationTable classification_table
CROSS JOIN TotalCases total_cases
GROUP BY classification_table."chromosome", 
         classification_table."cytoband_name", 
         classification_table."classification", 
         total_cases.total
ORDER BY classification_table."chromosome", 
         classification_table."cytoband_name", 
         classification_table."classification";