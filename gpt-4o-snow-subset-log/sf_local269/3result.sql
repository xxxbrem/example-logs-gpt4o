WITH RECURSIVE packaging_tree AS (
    -- Start with direct relationships from PACKAGING_RELATIONS
    SELECT 
        r."packaging_id", 
        r."contains_id", 
        r."qty"
    FROM ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS r
    
    UNION ALL

    -- Recursively traverse nested relationships
    SELECT 
        pt."packaging_id", 
        r."contains_id", 
        pt."qty" * r."qty"
    FROM packaging_tree pt
    JOIN ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS r
    ON pt."contains_id" = r."packaging_id"
),
leaf_items AS (
    -- Identify leaf-level items (those that are only "contains_id" and not "packaging_id")
    SELECT DISTINCT "contains_id"
    FROM ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS
    WHERE "contains_id" NOT IN (
        SELECT DISTINCT "packaging_id" FROM ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS
    )
),
final_totals AS (
    -- Calculate the total quantities for each packaging_id, considering only leaf-level items
    SELECT 
        pt."packaging_id", 
        pt."contains_id", 
        pt."qty"
    FROM packaging_tree pt
    JOIN leaf_items li
    ON pt."contains_id" = li."contains_id"
)
-- Calculate the average total quantity across all final packaging combinations
SELECT 
    AVG("qty") AS "average_total_qty"
FROM final_totals;