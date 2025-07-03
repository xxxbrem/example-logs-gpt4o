WITH top_histological_types AS (
    SELECT clinical."histological_type", 
           COUNT(mutations."ParticipantBarcode") * 100.0 / patient_counts."total_patients" AS "mutation_percentage"
    FROM "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED" clinical
    JOIN "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."MC3_MAF_V5_ONE_PER_TUMOR_SAMPLE" mutations
    ON clinical."bcr_patient_barcode" = mutations."ParticipantBarcode"
    JOIN (
        SELECT "histological_type", COUNT(*) AS "total_patients"
        FROM "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED"
        WHERE "acronym" = 'BRCA'
        GROUP BY "histological_type"
    ) patient_counts 
    ON clinical."histological_type" = patient_counts."histological_type"
    WHERE mutations."Hugo_Symbol" = 'CDH1' AND clinical."acronym" = 'BRCA'
    GROUP BY clinical."histological_type", patient_counts."total_patients"
    ORDER BY "mutation_percentage" DESC NULLS LAST
    LIMIT 5
)
SELECT "histological_type", "mutation_percentage"
FROM top_histological_types;