WITH RECURSIVE packaging_tree AS (
    -- Base case: Direct parent-child packaging relationships
    SELECT pr."packaging_id", pr."contains_id", pr."qty" AS "multiplier", 1 AS "level"
    FROM ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS pr
    UNION ALL
    -- Recursive case: Traverse nested relationships and multiply quantities
    SELECT pt."packaging_id", pr."contains_id", pt."multiplier" * pr."qty", pt."level" + 1
    FROM packaging_tree pt
    JOIN ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS pr ON pt."contains_id" = pr."packaging_id"
)
-- Calculate total quantities for each packaging and its leaf-level components
SELECT AVG("total_quantity") AS "average_total_quantity"
FROM (
    SELECT pt."packaging_id", pt."contains_id", SUM(pt."multiplier") AS "total_quantity"
    FROM packaging_tree pt
    WHERE pt."contains_id" NOT IN (
        -- Exclude items that act as parent "packaging_id" (i.e., non-leaf items)
        SELECT DISTINCT "packaging_id" FROM ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS
    )
    GROUP BY pt."packaging_id", pt."contains_id"
) aggregated_totals;