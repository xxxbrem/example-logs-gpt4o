SELECT 
    e.value::VARIANT:"CodeMeaning"::STRING AS "EmbeddingMedium",
    st.value::VARIANT:"CodeMeaning"::STRING AS "StainingSubstance",
    COUNT(DISTINCT t."SOPInstanceUID") AS "Occurrences"
FROM IDC.IDC_V17.DICOM_METADATA t,
LATERAL FLATTEN(input => t."SpecimenDescriptionSequence") f,
LATERAL FLATTEN(input => f.value::VARIANT:"SpecimenPreparationSequence") g,
LATERAL FLATTEN(input => g.value::VARIANT:"SpecimenPreparationStepContentItemSequence") s,
LATERAL FLATTEN(input => s.value::VARIANT:"ConceptCodeSequence") e,
LATERAL FLATTEN(input => s.value::VARIANT:"ConceptCodeSequence") st
WHERE t."Modality" = 'SM'
AND e.value::VARIANT:"CodingSchemeDesignator"::STRING = 'SCT'
AND st.value::VARIANT:"CodingSchemeDesignator"::STRING = 'SCT'
AND e.value::VARIANT:"CodeMeaning"::STRING IS NOT NULL
AND st.value::VARIANT:"CodeMeaning"::STRING IS NOT NULL
GROUP BY "EmbeddingMedium", "StainingSubstance"
ORDER BY "Occurrences" DESC NULLS LAST
LIMIT 20;