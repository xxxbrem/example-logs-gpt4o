SELECT COUNT(DISTINCT "StudyInstanceUID") AS unique_study_instance_uids
FROM (
    -- DWI series
    SELECT DISTINCT "StudyInstanceUID" 
    FROM IDC.IDC_V17.DICOM_ALL
    WHERE "collection_id" = 'qin_prostate_repeatability'
      AND "SeriesDescription" ILIKE '%DWI%'
    
    UNION ALL
    
    -- T2 Weighted Axial series
    SELECT DISTINCT "StudyInstanceUID" 
    FROM IDC.IDC_V17.DICOM_ALL
    WHERE "collection_id" = 'qin_prostate_repeatability'
      AND "SeriesDescription" ILIKE '%T2%Weighted%Axial%'
    
    UNION ALL
    
    -- Apparent Diffusion Coefficient series
    SELECT DISTINCT "StudyInstanceUID" 
    FROM IDC.IDC_V17.DICOM_ALL
    WHERE "collection_id" = 'qin_prostate_repeatability'
      AND "SeriesDescription" ILIKE '%Apparent%Diffusion%Coefficient%'
    
    UNION ALL
    
    -- T2 Weighted Axial Segmentations
    SELECT DISTINCT "StudyInstanceUID" 
    FROM IDC.IDC_V17.SEGMENTATIONS
    WHERE "PatientID" IN (
        SELECT DISTINCT "PatientID"
        FROM IDC.IDC_V17.DICOM_ALL
        WHERE "collection_id" = 'qin_prostate_repeatability'
          AND "SeriesDescription" ILIKE '%T2%Weighted%Axial%'
    )
)
;