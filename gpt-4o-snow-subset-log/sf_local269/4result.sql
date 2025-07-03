WITH RecursiveCTE AS (
  -- Base step: Start with the direct packaging relationships
  SELECT 
    "packaging_id", 
    "contains_id", 
    "qty" AS "cumulative_qty"
  FROM ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS
  
  UNION ALL
  
  -- Recursive step: Expand the hierarchy by multiplying quantities across relationships
  SELECT 
    prv."packaging_id", 
    prn."contains_id", 
    prv."cumulative_qty" * prn."qty" AS "cumulative_qty"
  FROM RecursiveCTE prv
  INNER JOIN ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS prn
  ON prv."contains_id" = prn."packaging_id"
),
LeafItems AS (
  -- Identify leaf-level items (those not used as "packaging_id") and calculate their total quantity
  SELECT 
    "contains_id", 
    SUM("cumulative_qty") AS "total_quantity"
  FROM RecursiveCTE
  WHERE "contains_id" NOT IN (
    SELECT DISTINCT "packaging_id"
    FROM ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS
  )
  GROUP BY "contains_id"
)
-- Compute the average total quantity across all final leaf-level items
SELECT AVG("total_quantity") AS "avg_quantity"
FROM LeafItems;