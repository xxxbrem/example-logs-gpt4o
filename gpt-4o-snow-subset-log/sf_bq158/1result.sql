SELECT "histological_type",
       "mutation_count",
       "total_patients",
       "mutation_percentage"
FROM (
    SELECT type_data."histological_type",
           type_data."mutation_count",
           total_data."total_patients",
           (type_data."mutation_count"::FLOAT / total_data."total_patients") * 100 AS "mutation_percentage"
    FROM (
        SELECT clinical."histological_type", COUNT(DISTINCT clinical."bcr_patient_barcode") AS "mutation_count"
        FROM "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED" clinical
        JOIN "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."MC3_MAF_V5_ONE_PER_TUMOR_SAMPLE" mc3
        ON clinical."bcr_patient_barcode" = mc3."ParticipantBarcode"
        WHERE mc3."Hugo_Symbol" = 'CDH1' AND mc3."Study" = 'BRCA'
        GROUP BY clinical."histological_type"
    ) AS type_data
    JOIN (
        SELECT "histological_type", COUNT(DISTINCT "bcr_patient_barcode") AS "total_patients"
        FROM "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED"
        WHERE "acronym" = 'BRCA'
        GROUP BY "histological_type"
    ) AS total_data
    ON type_data."histological_type" = total_data."histological_type"
) AS combined_data
ORDER BY "mutation_percentage" DESC NULLS LAST
LIMIT 5;