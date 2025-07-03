WITH cdkn2a_patients AS (
  -- Identify the case barcodes of patients with CDKN2A mutations in the TCGA-BLCA project
  SELECT DISTINCT "case_barcode"
  FROM TCGA.TCGA_VERSIONED.SOMATIC_MUTATION_HG19_MC3_2017_02
  WHERE "Hugo_Symbol" = 'CDKN2A'
    AND "project_short_name" = 'TCGA-BLCA'
),
clinical_info AS (
  -- Retrieve clinical information for the identified patients using GDC Release 39
  SELECT DISTINCT "submitter_id" AS "case_barcode", 
         "demo__gender" AS "gender", 
         "demo__race" AS "race", 
         "demo__age_at_index" AS "age_at_index", 
         "demo__vital_status" AS "vital_status", 
         "primary_site" AS "primary_tumor_site"
  FROM TCGA.TCGA_VERSIONED.CLINICAL_GDC_R39
  WHERE "submitter_id" IN (SELECT "case_barcode" FROM cdkn2a_patients)
),
rna_expression AS (
  -- Retrieve RNA expression levels for specific genes (MDM2, TP53, CDKN1A, CCNE1) for the identified patients
  SELECT DISTINCT "case_barcode", 
                  "gene_name", 
                  "fpkm_unstranded" AS "rna_expression_level"
  FROM TCGA.TCGA_VERSIONED.RNASEQ_HG38_GDC_R39
  WHERE "case_barcode" IN (SELECT "case_barcode" FROM cdkn2a_patients)
    AND "gene_name" IN ('MDM2', 'TP53', 'CDKN1A', 'CCNE1')
),
combined_data AS (
  -- Combine clinical information with RNA expression data for the patient cohort
  SELECT c.*, 
         r."gene_name", 
         r."rna_expression_level"
  FROM clinical_info c
  LEFT JOIN rna_expression r
  ON c."case_barcode" = r."case_barcode"
)
-- Final output
SELECT * 
FROM combined_data
ORDER BY "case_barcode", "gene_name";