WITH FilteredClinical AS (
    SELECT "bcr_patient_barcode", "histological_type"
    FROM PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED
    WHERE "acronym" = 'BRCA' AND "histological_type" IS NOT NULL
),
FilteredMutation AS (
    SELECT DISTINCT "ParticipantBarcode"
    FROM PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.MC3_MAF_V5_ONE_PER_TUMOR_SAMPLE
    WHERE "Hugo_Symbol" = 'CDH1' AND "FILTER" = 'PASS'
),
ContingencyTable AS (
    SELECT 
        c."histological_type",
        COUNT(CASE WHEN m."ParticipantBarcode" IS NOT NULL THEN 1 ELSE NULL END) AS "mutation_present",
        COUNT(CASE WHEN m."ParticipantBarcode" IS NULL THEN 1 ELSE NULL END) AS "no_mutation"
    FROM FilteredClinical c
    LEFT JOIN FilteredMutation m
    ON c."bcr_patient_barcode" = m."ParticipantBarcode"
    GROUP BY c."histological_type"
),
FilteredContingency AS (
    SELECT *
    FROM ContingencyTable
    WHERE ("mutation_present" + "no_mutation") > 10 
      AND "mutation_present" > 10
)
SELECT 
    "histological_type", 
    "mutation_present", 
    "no_mutation",
    ("mutation_present" + "no_mutation") AS "total"
FROM FilteredContingency;