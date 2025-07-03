WITH yearly_driver_totals AS (
    SELECT 
        r."year",
        ds."driver_id",
        SUM(ds."points") AS "total_points"
    FROM 
        F1.F1."DRIVER_STANDINGS" ds
    JOIN 
        F1.F1."RACES" r
    ON 
        ds."race_id" = r."race_id"
    GROUP BY 
        r."year", ds."driver_id"
),
yearly_constructor_totals AS (
    SELECT 
        r."year",
        cr."constructor_id",
        SUM(cr."points") AS "total_points"
    FROM 
        F1.F1."CONSTRUCTOR_RESULTS" cr
    JOIN 
        F1.F1."RACES" r
    ON 
        cr."race_id" = r."race_id"
    GROUP BY 
        r."year", cr."constructor_id"
)
SELECT 
    yearly_driver_totals."year",
    d."full_name" AS "driver_name",
    yearly_driver_totals."total_points" AS "driver_points",
    c."name" AS "constructor_name",
    yearly_constructor_totals."total_points" AS "constructor_points"
FROM 
    yearly_driver_totals
JOIN 
    F1.F1."DRIVERS" d
ON 
    yearly_driver_totals."driver_id" = d."driver_id"
JOIN 
    (
        SELECT 
            "year", MAX("total_points") AS "max_driver_points"
        FROM 
            yearly_driver_totals
        GROUP BY 
            "year"
    ) max_driver_per_year
ON 
    yearly_driver_totals."year" = max_driver_per_year."year"
    AND yearly_driver_totals."total_points" = max_driver_per_year."max_driver_points"
JOIN 
    yearly_constructor_totals
ON 
    yearly_driver_totals."year" = yearly_constructor_totals."year"
JOIN 
    F1.F1."CONSTRUCTORS" c
ON 
    yearly_constructor_totals."constructor_id" = c."constructor_id"
JOIN 
    (
        SELECT 
            "year", MAX("total_points") AS "max_constructor_points"
        FROM 
            yearly_constructor_totals
        GROUP BY 
            "year"
    ) max_constructor_per_year
ON 
    yearly_constructor_totals."year" = max_constructor_per_year."year"
    AND yearly_constructor_totals."total_points" = max_constructor_per_year."max_constructor_points"
ORDER BY 
    yearly_driver_totals."year";