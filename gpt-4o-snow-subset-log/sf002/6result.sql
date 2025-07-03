WITH Active_Large_Banks AS (
    SELECT 
        FI."NAME",
        FI."FDIC_CERT",
        FI."ID_RSSD",
        FI."IS_ACTIVE"
    FROM 
        "FINANCE__ECONOMICS"."CYBERSYN"."FINANCIAL_INSTITUTION_ENTITIES" AS FI
    WHERE 
        FI."IS_ACTIVE" = TRUE 
        AND FI."CATEGORY" = 'Bank' 
        AND FI."ID_RSSD" IS NOT NULL
), 
Insured_Percentage AS (
    SELECT 
        FTS."ID_RSSD",
        (1 - COALESCE(FTS."VALUE", 0)) AS "UNINSURED_PERCENT"
    FROM 
        "FINANCE__ECONOMICS"."CYBERSYN"."FINANCIAL_INSTITUTION_TIMESERIES" AS FTS
    WHERE 
        FTS."VARIABLE_NAME" ILIKE '%Insured%' 
        AND FTS."DATE" = '2022-12-31'
),
Asset_Filtered AS (
    SELECT 
        ATS."ID_RSSD",
        MAX(ATS."VALUE") AS "ASSET_VALUE"
    FROM 
        "FINANCE__ECONOMICS"."CYBERSYN"."FINANCIAL_INSTITUTION_TIMESERIES" AS ATS
    WHERE 
        ATS."VARIABLE_NAME" ILIKE '%Assets%' 
        AND ATS."UNIT" = 'USD' 
        AND ATS."DATE" = '2022-12-31'
    GROUP BY 
        ATS."ID_RSSD"
),
Filtered_Banks AS (
    SELECT 
        ALB."NAME",
        ALB."ID_RSSD",
        IP."UNINSURED_PERCENT",
        AF."ASSET_VALUE"
    FROM 
        Active_Large_Banks AS ALB
    JOIN 
        Insured_Percentage AS IP 
        ON ALB."ID_RSSD" = IP."ID_RSSD"
    JOIN 
        Asset_Filtered AS AF 
        ON ALB."ID_RSSD" = AF."ID_RSSD"
    WHERE 
        AF."ASSET_VALUE" > 10000000000
)
SELECT 
    "NAME",
    "UNINSURED_PERCENT"
FROM 
    Filtered_Banks
ORDER BY 
    "UNINSURED_PERCENT" DESC NULLS LAST
LIMIT 10;