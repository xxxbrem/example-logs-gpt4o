WITH RECURSIVE packaging_hierarchy AS (
    -- Base case: Initialize the hierarchy with direct relationships
    SELECT 
        r."packaging_id", 
        r."contains_id", 
        r."qty" AS "total_qty"
    FROM ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS r
    UNION ALL
    -- Recursive case: Expand relationships by calculating cumulative quantities
    SELECT 
        ph."packaging_id", 
        pr."contains_id", 
        ph."total_qty" * pr."qty" AS "total_qty"
    FROM packaging_hierarchy ph
    JOIN ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS pr
    ON ph."contains_id" = pr."packaging_id"
)
-- Calculate the average total quantity across all fully expanded final packaging combinations involving leaf-level items
SELECT 
    AVG("aggregated_total_qty") AS "average_total_qty"
FROM (
    -- Aggregate total quantities for each `packaging_id` by summing only final leaf-level item quantities
    SELECT 
        ph."packaging_id", 
        SUM(ph."total_qty") AS "aggregated_total_qty"
    FROM packaging_hierarchy ph
    WHERE ph."contains_id" NOT IN (
        SELECT DISTINCT "packaging_id"
        FROM ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS
    )
    GROUP BY ph."packaging_id"
) aggregated;