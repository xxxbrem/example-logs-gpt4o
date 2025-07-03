SELECT 
    "collection_name", 
    "StudyInstanceUID", 
    "SeriesInstanceUID", 
    "SeriesDescription", 
    CONCAT('https://viewer.imaging.datacommons.cancer.gov/viewer/', "StudyInstanceUID") AS viewer_url, 
    ROUND(SUM("instance_size") / 1024, 2) AS total_instance_size_kb
FROM IDC.IDC_V17.DICOM_ALL
WHERE 
    "Modality" IN ('SEG', 'RTSTRUCT') 
    AND "SOPClassUID" = '1.2.840.10008.5.1.4.1.1.66.4' 
    AND "ReferencedImageSequence" = '[]'
    AND "ReferencedSeriesSequence" = '[]'
    AND "SourceImageSequence" = '[]'
GROUP BY 
    "collection_name", 
    "StudyInstanceUID", 
    "SeriesInstanceUID", 
    "SeriesDescription"
ORDER BY total_instance_size_kb DESC NULLS LAST;