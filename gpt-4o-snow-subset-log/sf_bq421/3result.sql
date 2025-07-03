SELECT 
    em.value::VARIANT:"CodeMeaning" AS "EmbeddingMedium",
    ss.value::VARIANT:"CodeMeaning" AS "StainingSubstance",
    COUNT(*) AS "Occurrences"
FROM IDC.IDC_V17.DICOM_METADATA AS t,
LATERAL FLATTEN(input => t."SpecimenDescriptionSequence") f,
LATERAL FLATTEN(input => f.value::VARIANT:"SpecimenPreparationSequence") sp,
LATERAL FLATTEN(input => sp.value::VARIANT:"SpecimenPreparationStepContentItemSequence") s,
LATERAL FLATTEN(input => s.value::VARIANT:"ConceptCodeSequence") em,
LATERAL FLATTEN(input => s.value::VARIANT:"ConceptCodeSequence") ss
WHERE t."Modality" = 'SM'
    AND em.value::VARIANT:"CodingSchemeDesignator" = 'SCT'
    AND ss.value::VARIANT:"CodingSchemeDesignator" = 'SCT'
GROUP BY 1, 2
ORDER BY "Occurrences" DESC NULLS LAST;