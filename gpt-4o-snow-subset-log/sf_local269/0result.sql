WITH RECURSIVE packaging_hierarchy AS (
    -- Base case: Select direct relationships from PACKAGING_RELATIONS
    SELECT 
        "packaging_id", 
        "contains_id", 
        "qty"
    FROM 
        "ORACLE_SQL"."ORACLE_SQL"."PACKAGING_RELATIONS"
    
    UNION ALL
    
    -- Recursive case: Find leaf-level items by expanding relationships
    SELECT 
        ph."packaging_id", 
        pr."contains_id", 
        ph."qty" * pr."qty" AS "qty"
    FROM 
        packaging_hierarchy ph
    JOIN 
        "ORACLE_SQL"."ORACLE_SQL"."PACKAGING_RELATIONS" pr
    ON 
        ph."contains_id" = pr."packaging_id"
)
-- Aggregate final quantities for each packaging_id and calculate the average
SELECT 
    AVG(total_quantity) AS average_total_quantity
FROM (
    SELECT 
        "packaging_id", 
        SUM("qty") AS total_quantity
    FROM 
        packaging_hierarchy
    WHERE 
        "contains_id" NOT IN (SELECT DISTINCT "packaging_id" FROM "ORACLE_SQL"."ORACLE_SQL"."PACKAGING_RELATIONS")
    GROUP BY 
        "packaging_id"
) subquery;