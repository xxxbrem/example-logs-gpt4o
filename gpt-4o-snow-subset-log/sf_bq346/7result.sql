SELECT 
    f.value::VARIANT:"CodeMeaning"::STRING AS "SegmentedPropertyCategory_CodeMeaning", 
    COUNT(*) AS "Occurrence"
FROM 
    "IDC"."IDC_V17"."SEGMENTATIONS" seg
INNER JOIN 
    "IDC"."IDC_V17"."DICOM_ALL" dicom
ON 
    dicom."SeriesInstanceUID" = seg."SeriesInstanceUID"
    AND dicom."access" = 'Public'
, 
    LATERAL FLATTEN(input => seg."SegmentedPropertyCategory") f
WHERE 
    dicom."Modality" = 'SEG'
    AND dicom."SOPClassUID" = '1.2.840.10008.5.1.4.1.1.66.4'
    AND seg."SOPInstanceUID" IS NOT NULL
    AND seg."SeriesInstanceUID" IS NOT NULL
GROUP BY 
    f.value::VARIANT:"CodeMeaning"::STRING
ORDER BY 
    "Occurrence" DESC NULLS LAST
LIMIT 5;