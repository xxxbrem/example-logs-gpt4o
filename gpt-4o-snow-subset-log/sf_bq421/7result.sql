WITH UnnestedSpecimenPreparation AS (
    SELECT 
        t."SOPInstanceUID",
        step.value::VARIANT AS "SpecimenPreparationStepContentItem"
    FROM IDC.IDC_V17.DICOM_METADATA t,
         LATERAL FLATTEN(input => t."SpecimenDescriptionSequence") desc_seq,
         LATERAL FLATTEN(input => desc_seq.value::VARIANT:"SpecimenPreparationSequence") step
    WHERE t."Modality" = 'SM'
),
SpecimenPreparationDetails AS (
    SELECT
        spc."SpecimenPreparationStepContentItem"::VARIANT:"SpecimenPreparationStepContentItemSequence" AS "StepContentItemSequence"
    FROM UnnestedSpecimenPreparation spc
),
CodeDetails AS (
    SELECT 
        code.value::VARIANT:"CodeMeaning" AS "CodeMeaning",
        code.value::VARIANT:"CodingSchemeDesignator" AS "CodingSchemeDesignator"
    FROM SpecimenPreparationDetails spd,
         LATERAL FLATTEN(input => spd."StepContentItemSequence") step,
         LATERAL FLATTEN(input => step.value::VARIANT:"ConceptCodeSequence") code
    WHERE code.value::VARIANT:"CodingSchemeDesignator" = 'SCT'
),
EmbeddingAndStainingPairs AS (
    SELECT 
        sp1."CodeMeaning" AS "EmbeddingMedium",
        sp2."CodeMeaning" AS "StainingSubstance"
    FROM CodeDetails sp1
    JOIN CodeDetails sp2
    ON sp1."CodeMeaning" != sp2."CodeMeaning"
)
SELECT 
    "EmbeddingMedium",
    "StainingSubstance",
    COUNT(*) AS "Occurrences"
FROM EmbeddingAndStainingPairs
GROUP BY "EmbeddingMedium", "StainingSubstance"
ORDER BY "Occurrences" DESC NULLS LAST;