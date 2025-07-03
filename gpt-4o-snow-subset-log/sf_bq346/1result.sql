WITH Filtered_SEG_Data AS (
  SELECT
    s."SegmentedPropertyCategory",
    TRY_PARSE_JSON(s."SegmentedPropertyCategory") AS "ParsedCategory"
  FROM
    IDC.IDC_V17.SEGMENTATIONS s
  JOIN
    IDC.IDC_V17.DICOM_ALL d
  ON
    s."SOPInstanceUID" = d."SOPInstanceUID"
  WHERE
    d."Modality" = 'SEG'
    AND d."SOPClassUID" = '1.2.840.10008.5.1.4.1.1.66.4'
    AND d."access" = 'Public'
    AND s."SegmentedPropertyCategory" IS NOT NULL
),
Category_Frequencies AS (
  SELECT
    "ParsedCategory":"CodeMeaning"::STRING AS "CodeMeaning",
    COUNT(*) AS "Frequency"
  FROM
    Filtered_SEG_Data
  GROUP BY
    "ParsedCategory":"CodeMeaning"::STRING
)
SELECT
  "CodeMeaning",
  "Frequency"
FROM
  Category_Frequencies
ORDER BY
  "Frequency" DESC NULLS LAST
LIMIT 5;