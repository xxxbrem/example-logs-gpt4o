WITH events_with_names AS (
    SELECT 
        e."page_id",
        ei."event_name",
        e."event_type",
        e."cookie_id",
        e."visit_id",
        e."sequence_number",
        e."event_time"
    FROM 
        "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_EVENTS" e
    INNER JOIN 
        "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_EVENT_IDENTIFIER" ei
    ON 
        e."event_type" = ei."event_type"
),
filtered_events AS (
    SELECT
        ew."page_id",
        ew."event_name",
        ph."product_id",
        ph."page_name",
        ph."product_category"
    FROM 
        events_with_names ew
    INNER JOIN 
        "BANK_SALES_TRADING"."BANK_SALES_TRADING"."SHOPPING_CART_PAGE_HIERARCHY" ph
    ON 
        ew."page_id" = ph."page_id"
    WHERE 
        ew."page_id" NOT IN (1, 2, 12, 13)
),
breakdown AS (
    SELECT
        fe."product_id",
        fe."page_name",
        fe."product_category",
        COUNT(CASE WHEN fe."event_name" = 'Page View' THEN 1 END) AS "views",
        COUNT(CASE WHEN fe."event_name" = 'Add to Cart' THEN 1 END) AS "add_to_cart",
        COUNT(CASE WHEN fe."event_name" = 'Purchase' THEN 1 END) AS "purchases",
        COUNT(CASE 
              WHEN fe."event_name" = 'Add to Cart' AND 
                   fe."page_id" NOT IN (
                       SELECT DISTINCT "page_id"
                       FROM filtered_events
                       WHERE "event_name" = 'Purchase'
                   ) 
              THEN 1 END
        ) AS "left_in_cart"
    FROM 
        filtered_events fe
    GROUP BY 
        fe."product_id", fe."page_name", fe."product_category"
)
SELECT 
    "product_id",
    "page_name",
    "product_category",
    "views",
    "add_to_cart",
    "purchases",
    "left_in_cart"
FROM 
    breakdown
ORDER BY 
    "views" DESC NULLS LAST, 
    "add_to_cart" DESC NULLS LAST, 
    "purchases" DESC NULLS LAST;