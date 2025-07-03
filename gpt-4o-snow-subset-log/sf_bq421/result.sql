SELECT 
    si.VALUE:"ConceptCodeSequence"::VARIANT[0]:"CodeMeaning"::STRING AS "EmbeddingMediumCodeMeaning",
    si.VALUE:"ConceptCodeSequence"::VARIANT[1]:"CodeMeaning"::STRING AS "StainingSubstanceCodeMeaning",
    COUNT(*) AS "Occurrences"
FROM IDC.IDC_V17.DICOM_METADATA t, 
LATERAL FLATTEN(input => t."SpecimenDescriptionSequence") s,
LATERAL FLATTEN(input => s.VALUE:"SpecimenPreparationSequence") p,
LATERAL FLATTEN(input => p.VALUE:"SpecimenPreparationStepContentItemSequence") si,
LATERAL FLATTEN(input => si.VALUE:"ConceptCodeSequence") cc -- Unnest ConceptCodeSequence to ensure we capture all values
WHERE t."Modality" = 'SM'
  AND cc.VALUE:"CodingSchemeDesignator"::STRING = 'SCT' -- Ensure only SCT coding scheme is considered
GROUP BY 1, 2
ORDER BY "Occurrences" DESC NULLS LAST;