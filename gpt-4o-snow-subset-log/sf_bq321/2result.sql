SELECT COUNT(DISTINCT "StudyInstanceUID") AS unique_study_instance_uids
FROM IDC.IDC_V17.DICOM_ALL
WHERE "collection_id" = 'qin_prostate_repeatability'
  AND (
       "SeriesDescription" ILIKE '%DWI%' 
       OR "SeriesDescription" ILIKE '%T2%Weighted%Axial%'
       OR "SeriesDescription" ILIKE '%Apparent%Diffusion%Coefficient%'
       OR "SeriesDescription" ILIKE '%T2%Weighted%Axial%Segmentations%'
  );