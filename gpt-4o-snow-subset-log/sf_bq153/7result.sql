SELECT 
    c."icd_o_3_histology" AS "Histology_Type",
    AVG(LN(g."normalized_count" + 1) / LN(10)) AS "Average_Log10_Expression"
FROM 
    "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED" c
JOIN 
    "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."EBPP_ADJUSTPANCAN_ILLUMINAHISEQ_RNASEQV2_GENEXP_FILTERED" g
ON 
    c."bcr_patient_barcode" = g."ParticipantBarcode"
WHERE 
    c."acronym" = 'LGG' 
    AND g."Symbol" = 'IGF2' 
    AND c."icd_o_3_histology" NOT LIKE '[%'
GROUP BY 
    c."icd_o_3_histology"
ORDER BY 
    "Average_Log10_Expression" DESC NULLS LAST;