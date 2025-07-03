SELECT COUNT(DISTINCT "StudyInstanceUID") AS unique_study_instance_uids
FROM (
    SELECT "StudyInstanceUID"
    FROM "IDC"."IDC_V17"."DICOM_ALL"
    WHERE "collection_id" = 'qin_prostate_repeatability'
      AND (
        "SeriesDescription" ILIKE '%DWI%' 
        OR "SeriesDescription" ILIKE '%T2%Weighted%Axial%' 
        OR "SeriesDescription" ILIKE '%Apparent%Diffusion%Coefficient%'
      )
    UNION ALL
    SELECT "StudyInstanceUID"
    FROM "IDC"."IDC_V17"."SEGMENTATIONS"
    WHERE "PatientID" LIKE '%qin_prostate_repeatability%' 
      AND (
        "SegmentAlgorithmName" ILIKE '%Axial%'
        OR "segmented_SeriesInstanceUID" IN (
            SELECT "SeriesInstanceUID"
            FROM "IDC"."IDC_V17"."DICOM_ALL"
            WHERE "collection_id" = 'qin_prostate_repeatability'
              AND "SeriesDescription" ILIKE '%T2%Weighted%Axial%'
        )
      )
);