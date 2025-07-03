WITH Filtered_Mutation_Data AS (
    SELECT DISTINCT 
        m."ParticipantBarcode", 
        c."histological_type", 
        CASE 
            WHEN m."Hugo_Symbol" = 'CDH1' THEN 'Mutation' 
            ELSE 'No_Mutation' 
        END AS "Mutation_Status"
    FROM PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED c
    LEFT JOIN PANCANCER_ATLAS_1.PANCANCER_ATLAS_FILTERED.MC3_MAF_V5_ONE_PER_TUMOR_SAMPLE m
    ON c."bcr_patient_barcode" = m."ParticipantBarcode"
    WHERE m."Study" = 'BRCA' 
        AND c."histological_type" IS NOT NULL
        AND (m."FILTER" = 'PASS' OR m."Hugo_Symbol" IS NULL)
),
Aggregated_Data AS (
    SELECT 
        "histological_type", 
        "Mutation_Status", 
        COUNT(DISTINCT "ParticipantBarcode") AS "Count"
    FROM Filtered_Mutation_Data
    GROUP BY "histological_type", "Mutation_Status"
    HAVING COUNT(DISTINCT "ParticipantBarcode") > 10
),
Marginal_Totals AS (
    SELECT
        "histological_type",
        SUM("Count") OVER (PARTITION BY "histological_type") AS "Histological_Type_Total",
        (SELECT SUM("Count") FROM Aggregated_Data) AS "Overall_Total"
    FROM Aggregated_Data
),
Final_ChiSquare_Data AS (
    SELECT
        a."histological_type",
        a."Mutation_Status",
        a."Count",
        m."Histological_Type_Total",
        m."Overall_Total",
        (a."Count" * m."Overall_Total") / m."Histological_Type_Total" AS "Expected_Count" 
    FROM Aggregated_Data a
    INNER JOIN (
        SELECT DISTINCT "histological_type", "Histological_Type_Total", "Overall_Total"
        FROM Marginal_Totals
    ) m
    ON a."histological_type" = m."histological_type"
)
SELECT
    SUM(POWER(("Count" - "Expected_Count"), 2) / "Expected_Count") AS "Chi_Square_Value"
FROM Final_ChiSquare_Data;