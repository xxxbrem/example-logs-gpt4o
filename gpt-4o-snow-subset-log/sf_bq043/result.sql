WITH somatic_mutations AS (
    -- Extract cases with CDKN2A mutations from the somatic mutations table
    SELECT DISTINCT "case_barcode"
    FROM TCGA.TCGA_VERSIONED.SOMATIC_MUTATION_HG19_DCC_2017_02
    WHERE "project_short_name" = 'TCGA-BLCA' AND "Hugo_Symbol" = 'CDKN2A'
),
clinical_data AS (
    -- Extract clinical information from the Genomic Data Commons Release 39
    SELECT DISTINCT 
        "case_barcode", 
        "age_at_diagnosis" AS "age", 
        "gender", 
        "pathologic_stage", 
        "vital_status", 
        "disease_code", 
        "tumor_tissue_site"
    FROM TCGA.TCGA_VERSIONED.CLINICAL_GDC_2019_06
),
rna_expression AS (
    -- Extract RNA expression levels of specified genes
    SELECT 
        "case_barcode", 
        "HGNC_gene_symbol" AS "gene_name", 
        "normalized_count" AS "expression_level"
    FROM TCGA.TCGA_VERSIONED.RNASEQ_HG19_GDC_2017_02
    WHERE "HGNC_gene_symbol" IN ('MDM2', 'TP53', 'CDKN1A', 'CCNE1') AND "project_short_name" = 'TCGA-BLCA'
)
-- Combine data from somatic mutations, clinical data, and RNA expression
SELECT 
    mut."case_barcode", 
    clin."age", 
    clin."gender", 
    clin."pathologic_stage", 
    clin."vital_status", 
    clin."disease_code", 
    clin."tumor_tissue_site", 
    rna."gene_name", 
    rna."expression_level"
FROM somatic_mutations mut
JOIN clinical_data clin ON mut."case_barcode" = clin."case_barcode"
JOIN rna_expression rna ON mut."case_barcode" = rna."case_barcode"
ORDER BY mut."case_barcode", rna."gene_name";