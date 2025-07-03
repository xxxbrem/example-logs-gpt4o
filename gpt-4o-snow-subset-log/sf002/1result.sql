WITH Large_Banks_Assets AS (
    -- Filter active banks with assets exceeding $10 billion as of December 31, 2022
    SELECT 
        ent."NAME" AS "BANK_NAME", 
        ts."ID_RSSD", 
        ts."VALUE" AS "ASSETS"
    FROM 
        "FINANCE__ECONOMICS"."CYBERSYN"."FINANCIAL_INSTITUTION_TIMESERIES" ts
    JOIN 
        "FINANCE__ECONOMICS"."CYBERSYN"."FINANCIAL_INSTITUTION_ENTITIES" ent
    ON 
        ts."ID_RSSD" = CAST(ent."ID_RSSD" AS TEXT)
    WHERE 
        ts."VARIABLE" = 'ASSET' 
        AND ts."DATE" = '2022-12-31'
        AND ts."VALUE" > 10000000000
        AND ent."IS_ACTIVE" = TRUE
),
Insured_Percentage_Data AS (
    -- Retrieve '% Insured (Estimated)' data for the same date
    SELECT 
        ts."ID_RSSD",
        ts."VALUE" AS "INSURED_PERCENTAGE"
    FROM 
        "FINANCE__ECONOMICS"."CYBERSYN"."FINANCIAL_INSTITUTION_TIMESERIES" ts
    WHERE 
        ts."VARIABLE" = 'DEPIDOMR' -- Adjusted to the correct variable for '% Insured (Estimated)'
        AND ts."DATE" = '2022-12-31'
        AND ts."VALUE" IS NOT NULL
),
Uninsured_Asset_Percentage AS (
    -- Calculate the percentage of uninsured assets
    SELECT 
        la."BANK_NAME", 
        la."ID_RSSD", 
        la."ASSETS", 
        1 - ip."INSURED_PERCENTAGE" AS "PERCENT_UNINSURED_ASSETS"
    FROM 
        Large_Banks_Assets la
    LEFT JOIN 
        Insured_Percentage_Data ip
    ON 
        la."ID_RSSD" = ip."ID_RSSD"
),
Top_10_Large_Banks AS (
    -- Rank banks by the highest percentage of uninsured assets
    SELECT 
        uba."BANK_NAME", 
        uba."PERCENT_UNINSURED_ASSETS", 
        uba."ASSETS"
    FROM 
        Uninsured_Asset_Percentage uba
    WHERE 
        uba."PERCENT_UNINSURED_ASSETS" IS NOT NULL
    ORDER BY 
        uba."PERCENT_UNINSURED_ASSETS" DESC NULLS LAST
    LIMIT 10
)
SELECT 
    "BANK_NAME", 
    "PERCENT_UNINSURED_ASSETS", 
    "ASSETS"
FROM 
    Top_10_Large_Banks;