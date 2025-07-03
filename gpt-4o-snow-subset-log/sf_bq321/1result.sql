SELECT COUNT(DISTINCT "StudyInstanceUID") AS "Unique_StudyInstanceUID_Count"
FROM (
    SELECT DISTINCT "StudyInstanceUID"
    FROM "IDC"."IDC_V17"."DICOM_ALL"
    WHERE "collection_id" = 'qin_prostate_repeatability'
      AND (
        "SeriesDescription" = 'DWI' OR
        "SeriesDescription" ILIKE '%T2%Weighted%Axial%' OR
        "SeriesDescription" ILIKE '%Apparent%Diffusion%Coefficient%'
      )
    
    UNION ALL

    SELECT DISTINCT seg."StudyInstanceUID"
    FROM "IDC"."IDC_V17"."SEGMENTATIONS" seg
    JOIN "IDC"."IDC_V17"."DICOM_ALL" dcm
      ON seg."segmented_SeriesInstanceUID" = dcm."SeriesInstanceUID"
    WHERE dcm."collection_id" = 'qin_prostate_repeatability'
      AND dcm."SeriesDescription" ILIKE '%T2%Weighted%Axial%'
) AS combined_data;