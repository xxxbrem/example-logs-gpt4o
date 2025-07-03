SELECT 
    "collection_id", 
    "StudyInstanceUID", 
    "SeriesInstanceUID", 
    CONCAT('https://viewer.imaging.datacommons.cancer.gov/viewer/', "StudyInstanceUID") AS "Viewer_URL",
    SUM("instance_size") / 1024 AS "Total_Instance_Size_KB" 
FROM 
    IDC.IDC_V17.DICOM_ALL
WHERE 
    "Modality" IN ('SEG', 'RTSTRUCT') 
    AND "SOPClassUID" = '1.2.840.10008.5.1.4.1.1.66.4' 
    AND "ReferencedStudySequence" = '[]' 
    AND "ReferencedSeriesSequence" = '[]'
    AND "ReferencedImageSequence" = '[]'
GROUP BY 
    "collection_id", "StudyInstanceUID", "SeriesInstanceUID" 
ORDER BY 
    "Total_Instance_Size_KB" DESC NULLS LAST;