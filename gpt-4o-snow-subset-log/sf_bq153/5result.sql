SELECT clin."icd_o_3_histology", clin."histological_type", 
       AVG(LN(gene."normalized_count" + 1) / LN(10)) AS "average_log10_expression"
FROM "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED" clin
JOIN "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."EBPP_ADJUSTPANCAN_ILLUMINAHISEQ_RNASEQV2_GENEXP_FILTERED" gene
ON clin."bcr_patient_barcode" = gene."ParticipantBarcode"
WHERE clin."acronym" = 'LGG' 
  AND gene."Symbol" = 'IGF2'
  AND clin."icd_o_3_histology" NOT LIKE '[%]'
GROUP BY clin."icd_o_3_histology", clin."histological_type"
ORDER BY "average_log10_expression" DESC NULLS LAST;