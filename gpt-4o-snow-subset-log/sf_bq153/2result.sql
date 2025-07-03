SELECT 
    c."icd_o_3_histology",
    AVG(LOG(10, g."normalized_count" + 1)) AS average_log10_expression
FROM 
    "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED" c
JOIN 
    "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."EBPP_ADJUSTPANCAN_ILLUMINAHISEQ_RNASEQV2_GENEXP_FILTERED" g
ON 
    c."bcr_patient_barcode" = g."ParticipantBarcode"
WHERE 
    c."acronym" = 'LGG' 
    AND g."Symbol" = 'IGF2'
    AND g."normalized_count" IS NOT NULL 
    AND g."normalized_count" > 0
    AND c."icd_o_3_histology" NOT LIKE '[%'
GROUP BY 
    c."icd_o_3_histology"
ORDER BY 
    average_log10_expression DESC NULLS LAST;