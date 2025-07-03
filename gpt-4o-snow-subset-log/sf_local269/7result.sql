WITH RecursiveExpansion AS (
    -- Start with direct relationships from the PACKAGING_RELATIONS table
    SELECT 
        pr."packaging_id", 
        pr."contains_id", 
        pr."qty"
    FROM 
        ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS pr
    UNION ALL
    -- Recursively expand by joining nested levels
    SELECT 
        re."packaging_id", 
        pr."contains_id", 
        re."qty" * pr."qty" AS "qty"
    FROM 
        RecursiveExpansion re
    JOIN 
        ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS pr
    ON 
        re."contains_id" = pr."packaging_id"
),
LeafLevelItems AS (
    -- Identify leaf-level items (contained items that don't act as packaging themselves)
    SELECT 
        re."packaging_id", 
        re."contains_id", 
        re."qty"
    FROM 
        RecursiveExpansion re
    LEFT JOIN 
        ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS pr
    ON 
        re."contains_id" = pr."packaging_id"
    WHERE 
        pr."packaging_id" IS NULL
),
TotalQuantities AS (
    -- Aggregate quantities for each packaging combination
    SELECT 
        "packaging_id", 
        SUM("qty") AS "total_qty"
    FROM 
        LeafLevelItems
    GROUP BY 
        "packaging_id"
)
-- Compute the average total quantity
SELECT 
    AVG("total_qty") AS "average_total_qty"
FROM 
    TotalQuantities;