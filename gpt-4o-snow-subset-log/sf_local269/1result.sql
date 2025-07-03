WITH RECURSIVE packaging_hierarchy AS (
    -- Base query: Start with direct relationships
    SELECT 
        pr."packaging_id" AS top_level_packaging_id,
        pr."contains_id" AS leaf_packaging_id,
        pr."qty" AS total_qty
    FROM 
        "ORACLE_SQL"."ORACLE_SQL"."PACKAGING_RELATIONS" pr

    UNION ALL

    -- Recursive query: Traverse nested relationships
    SELECT 
        ph.top_level_packaging_id,
        pr."contains_id" AS leaf_packaging_id,
        ph.total_qty * pr."qty" AS total_qty
    FROM 
        packaging_hierarchy ph
    JOIN 
        "ORACLE_SQL"."ORACLE_SQL"."PACKAGING_RELATIONS" pr
    ON 
        ph.leaf_packaging_id = pr."packaging_id"
)
-- Summing up quantities for each top-level packaging_id
, packaging_totals AS (
    SELECT 
        top_level_packaging_id,
        SUM(total_qty) AS total_qty
    FROM 
        packaging_hierarchy
    GROUP BY 
        top_level_packaging_id
)
-- Calculating the average total quantity across all top-level packaging combinations
SELECT 
    AVG(total_qty) AS average_total_quantity
FROM 
    packaging_totals;