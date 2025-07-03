SELECT 
    "collection_name", 
    "StudyInstanceUID", 
    "SeriesInstanceUID", 
    ROUND(SUM("instance_size") / 1024, 2) AS "Total_Size_kB",
    CONCAT('https://viewer.imaging.datacommons.cancer.gov/viewer/', "StudyInstanceUID") AS "Viewer_URL"
FROM 
    IDC.IDC_V17.DICOM_ALL
WHERE 
    "Modality" IN ('SEG', 'RTSTRUCT') 
    AND "SOPClassUID" = '1.2.840.10008.5.1.4.1.1.66.4'
    AND "ReferencedSeriesSequence" = '[]'
    AND "ReferencedImageSequence" = '[]'
    AND "SourceImageSequence" = '[]'
GROUP BY 
    "collection_name", "StudyInstanceUID", "SeriesInstanceUID"
ORDER BY 
    "Total_Size_kB" DESC NULLS LAST;