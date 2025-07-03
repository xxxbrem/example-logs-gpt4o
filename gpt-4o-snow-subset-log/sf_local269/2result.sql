WITH RECURSIVE packaging_cte AS (
    -- Base case: Get all direct relationships
    SELECT 
        PR."packaging_id", 
        PR."contains_id", 
        PR."qty"
    FROM 
        ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS PR

    UNION ALL

    -- Recursive case: Propagate quantities through nested relationships
    SELECT 
        pr."packaging_id", 
        pr."contains_id", 
        pr."qty" * cte."qty" AS "qty"
    FROM 
        ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS PR
    INNER JOIN 
        packaging_cte cte
    ON 
        pr."packaging_id" = cte."contains_id"
)
-- Aggregated sum of quantities for each packaging_id considering all hierarchy levels
, total_quantities AS (
    SELECT 
        cte."packaging_id", 
        SUM(cte."qty") AS "total_quantity"
    FROM 
        packaging_cte cte
    GROUP BY 
        cte."packaging_id"
)
-- Identify final packaging combinations (packaging_id not serving as contains_id)
, final_packaging AS (
    SELECT 
        tq."packaging_id", 
        tq."total_quantity"
    FROM 
        total_quantities tq
    WHERE 
        tq."packaging_id" NOT IN (
            SELECT DISTINCT 
                PR."contains_id"
            FROM 
                ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS PR
        )
)
-- Compute the average total quantity for final-level packaging combinations
SELECT 
    AVG(fp."total_quantity") AS "average_total_quantity"
FROM 
    final_packaging fp;