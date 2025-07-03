SELECT COUNT(DISTINCT "StudyInstanceUID") AS unique_study_instance_uids
FROM (
    SELECT DISTINCT "StudyInstanceUID"
    FROM "IDC"."IDC_V17"."DICOM_ALL"
    WHERE "collection_id" = 'qin_prostate_repeatability'
      AND ("SeriesDescription" ILIKE '%DWI%'
           OR "SeriesDescription" ILIKE '%T2%Weighted%Axial%'
           OR "SeriesDescription" ILIKE '%Apparent%Diffusion%Coefficient%')
    
    UNION
    
    SELECT DISTINCT "StudyInstanceUID"
    FROM "IDC"."IDC_V17"."SEGMENTATIONS"
    WHERE "PatientID" IN (
        SELECT DISTINCT "PatientID"
        FROM "IDC"."IDC_V17"."DICOM_ALL"
        WHERE "collection_id" = 'qin_prostate_repeatability'
          AND "SeriesDescription" ILIKE '%T2%Weighted%Axial%'
    )
);