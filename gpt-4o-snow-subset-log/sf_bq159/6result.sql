WITH FilteredClinical AS (
    SELECT 
        "bcr_patient_barcode" AS "ParticipantBarcode", 
        "histological_type"
    FROM 
        "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."CLINICAL_PANCAN_PATIENT_WITH_FOLLOWUP_FILTERED"
    WHERE 
        "acronym" = 'BRCA' 
        AND "histological_type" IS NOT NULL
),
FilteredMutations AS (
    SELECT 
        DISTINCT "ParticipantBarcode", 
        'Mutation' AS "Mutation_Status"
    FROM 
        "PANCANCER_ATLAS_1"."PANCANCER_ATLAS_FILTERED"."MC3_MAF_V5_ONE_PER_TUMOR_SAMPLE"
    WHERE 
        "Hugo_Symbol" = 'CDH1' 
        AND "FILTER" = 'PASS'
),
CombinedData AS (
    SELECT 
        c."histological_type", 
        COALESCE(m."Mutation_Status", 'No Mutation') AS "Mutation_Status"
    FROM 
        FilteredClinical c
    LEFT JOIN 
        FilteredMutations m
    ON 
        c."ParticipantBarcode" = m."ParticipantBarcode"
),
Counts AS (
    SELECT 
        "histological_type", 
        "Mutation_Status", 
        COUNT(*) AS "count"
    FROM 
        CombinedData
    GROUP BY 
        "histological_type", 
        "Mutation_Status"
),
FilteredCounts AS (
    SELECT 
        "histological_type", 
        "Mutation_Status", 
        "count"
    FROM 
        Counts
    WHERE 
        "histological_type" IN (
            SELECT "histological_type"
            FROM Counts
            GROUP BY "histological_type"
            HAVING SUM("count") > 10
        )
        AND "Mutation_Status" IN (
            SELECT "Mutation_Status"
            FROM Counts
            GROUP BY "Mutation_Status"
            HAVING SUM("count") > 10
        )
),
PivotTable AS (
    SELECT 
        "histological_type",
        SUM(CASE WHEN "Mutation_Status" = 'Mutation' THEN "count" ELSE 0 END) AS "Mutations",
        SUM(CASE WHEN "Mutation_Status" = 'No Mutation' THEN "count" ELSE 0 END) AS "No_Mutations"
    FROM 
        FilteredCounts
    GROUP BY 
        "histological_type"
),
ChiSquare AS (
    SELECT 
        SUM(POWER(("Mutations" - ExpectedMutations), 2) / ExpectedMutations) 
        + SUM(POWER(("No_Mutations" - ExpectedNoMutations), 2) / ExpectedNoMutations) AS "ChiSquare_Value"
    FROM (
        SELECT 
            "histological_type", 
            "Mutations", 
            "No_Mutations",
            TotalMutations * "RowTotal" / GrandTotal AS ExpectedMutations,
            TotalNoMutations * "RowTotal" / GrandTotal AS ExpectedNoMutations
        FROM (
            SELECT 
                p.*,
                TotalMutations,
                TotalNoMutations,
                "Mutations" + "No_Mutations" AS "RowTotal",
                TotalMutations + TotalNoMutations AS GrandTotal
            FROM 
                PivotTable p
            CROSS JOIN 
                (SELECT 
                    SUM("Mutations") AS TotalMutations, 
                    SUM("No_Mutations") AS TotalNoMutations 
                FROM 
                    PivotTable) Totals
        ) AS Subquery
    ) Final
)
SELECT 
    "ChiSquare_Value"
FROM 
    ChiSquare;