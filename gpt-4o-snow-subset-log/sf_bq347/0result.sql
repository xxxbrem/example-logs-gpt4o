WITH MR_SOP AS (
    -- Get SOP instances for the specified MR series
    SELECT 
        "Modality", 
        "SOPInstanceUID"
    FROM 
        IDC.IDC_V17.DICOM_METADATA
    WHERE 
        "SeriesInstanceUID" = '1.3.6.1.4.1.14519.5.2.1.3671.4754.105976129314091491952445656147'
),
SEGMENTATION_SOP AS (
    -- Get SOP instances from SEGMENTATIONS table associated with the MR series
    SELECT 
        'SEG' AS "Modality", 
        "SOPInstanceUID"
    FROM 
        IDC.IDC_V17.SEGMENTATIONS
    WHERE 
        "segmented_SeriesInstanceUID" = '1.3.6.1.4.1.14519.5.2.1.3671.4754.105976129314091491952445656147'
),
ALL_SOPS AS (
    -- Combine both MR and segmentation SOP instances
    SELECT * FROM MR_SOP
    UNION ALL
    SELECT * FROM SEGMENTATION_SOP
)
SELECT 
    "Modality", 
    COUNT(DISTINCT "SOPInstanceUID") AS "Total_SOP_Count"
FROM 
    ALL_SOPS
GROUP BY 
    "Modality"
ORDER BY 
    "Total_SOP_Count" DESC NULLS LAST;