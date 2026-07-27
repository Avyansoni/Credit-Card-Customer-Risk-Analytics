 /*CREDIT CARD CUSTOMER RISK ANALYTICS PROJECT
    SECTION 2 : BUSINESS ANALYSIS

    Author   : Avyan Soni
    Database : credit_card_project*/
    
    /*
    Business Question 1: Applicants by Age Group
	Objective:
    Analyze the distribution of applicants across
    different age groups to identify the bank's
    largest customer segment.
=============================
	*/
    
    SELECT 
    CASE
		WHEN ROUND(-DAYS_BIRTH/365.25,0) BETWEEN 20 AND 30 THEN '20-30'
        WHEN ROUND(-DAYS_BIRTH/365.25,0) BETWEEN 31 AND 40 THEN '31-40'
        WHEN ROUND(-DAYS_BIRTH/365.25,0) BETWEEN 41 AND 50 THEN '41-50'
        WHEN ROUND(-DAYS_BIRTH/365.25,0) BETWEEN 51 AND 60 THEN '51-60'
        ELSE '60+'
        END AS Age_group,
        COUNT(*) AS Total_customers
        FROM application_record
        GROUP BY Age_group
		ORDER BY Total_customers DESC;
        
/*Business Question 2: Applicants by Income Type

    Objective:
    Identify which income group contributes the
    highest number of applicants.  */
    
        SELECT COUNT(*) AS Total_customers,
			NAME_INCOME_TYPE
            FROM application_record
            GROUP BY NAME_INCOME_TYPE
            ORDER BY Total_customers DESC;
   
/*Business Question 3: Applicants by Occupation

    Objective:
    Identify the occupations with the highest
    number of applicants.*/
    SELECT
    CASE
        WHEN OCCUPATION_TYPE IS NULL OR OCCUPATION_TYPE = '' THEN 'Unknown'
        ELSE OCCUPATION_TYPE
    END AS OCCUPATION_TYPE,
    COUNT(*) AS Total_Customers
FROM application_record
GROUP BY
    CASE
        WHEN OCCUPATION_TYPE IS NULL OR OCCUPATION_TYPE = '' THEN 'Unknown'
        ELSE OCCUPATION_TYPE
    END
ORDER BY Total_Customers DESC;
   
   /*Business Question 4: Applicants by Education Level

    Objective:
    Analyze the distribution of applicants based on
    their education level to understand the bank's
    customer profile.*/
    
    SELECT NAME_EDUCATION_TYPE,
		COUNT(*) AS Total_customers
	FROM application_record
	GROUP BY NAME_EDUCATION_TYPE
    ORDER BY Total_customers DESC;
    
   /* SECTION B : FINANCIAL ANALYSIS
   Objective:
Analyze the financial profile of credit card applicants
by comparing income across different customer segments.
   */
  /* 
    Business Question 5: Average Income by Education Level

    Objective:
    Analyze the average income of applicants across
    different education levels to identify whether
    education is associated with higher income.*/
    
    SELECT   NAME_EDUCATION_TYPE ,
        ROUND(AVG(AMT_INCOME_TOTAL), 2) AS Average_Income
	FROM application_record
    GROUP BY NAME_EDUCATION_TYPE
    ORDER BY  Average_income DESC;
 
 /*   Business Question 6: Average Income by Income Type

    Objective:
    Compare the average income across different income
    categories to identify the highest-earning group */
    
SELECT NAME_INCOME_TYPE,
	ROUND(AVG(AMT_INCOME_TOTAL),2) AS Average_Income
FROM application_record
GROUP BY NAME_INCOME_TYPE
ORDER BY Average_Income DESC; 
    
 /*
  Business Question 7: Average Income by Occupation

    Objective:
    Analyze the average income across different
    occupations to identify the highest-earning
    occupational groups.
 */   
SELECT
    CASE
        WHEN OCCUPATION_TYPE IS NULL OR OCCUPATION_TYPE = '' THEN 'Unknown'
        ELSE OCCUPATION_TYPE
    END AS OCCUPATION_TYPE,
    ROUND(AVG(AMT_INCOME_TOTAL), 2) AS Average_Income
FROM application_record
GROUP BY
    CASE
        WHEN OCCUPATION_TYPE IS NULL OR OCCUPATION_TYPE = '' THEN 'Unknown'
        ELSE OCCUPATION_TYPE
    END
ORDER BY Average_Income DESC;
    
/*  SECTION C : CREDIT RISK ANALYSIS 

Objective:
Analyze customer repayment behavior using credit
history to identify high-risk and low-risk customer
segments for informed lending decisions.


   Business Question 8: Good vs Bad Customers

    Objective:
    Classify customers as Good or Bad based on
    their credit repayment history to evaluate
    overall credit risk.
*/

  /*=====================================================
    Business Question 8: Good vs Bad Customers

    Objective:
    Classify each customer as Good or Bad based on
    their worst credit repayment history.
=====================================================*/

SELECT
    ID,
    MAX(
        CASE
            WHEN STATUS IN ('C', 'X') THEN 0
            ELSE CAST(STATUS AS UNSIGNED)
        END
    ) AS Worst_Status,
    CASE
        WHEN MAX(
            CASE
                WHEN STATUS IN ('C', 'X') THEN 0
                ELSE CAST(STATUS AS UNSIGNED)
            END
        ) >= 3 THEN 'Bad Customer'
        ELSE 'Good Customer'
    END AS Customer_Status
FROM credit_record
GROUP BY ID;
    
/*Business Question 9: Risk Distribution
Objective

Find how many customers are Good and how many are Bad.*/
WITH CUSTOMER_RISK AS(
    SELECT ID,
		case when 
        MAX(
        CASE 
			WHEN STATUS IN ('C','X') THEN 0
            ELSE CAST(STATUS AS UNSIGNED)
		END
	)>= 3 THEN 'BAD CUSTOMER'
	ELSE 'GOOD CUSTOMER'
 END AS Customer_Status
FROM credit_record
group by ID
    )
SELECT Customer_Status,
COUNT(*) AS Total_Customers
from CUSTOMER_RISK
group by Customer_Status;

/*Business Question 10: Average Income by Customer Risk
Objective
Compare the average annual income of Good Customers 
and Bad Customers.
*/
WITH Customer_Risk AS (
    SELECT
        ID,
        CASE
            WHEN MAX(
                CASE
                    WHEN STATUS IN ('C', 'X') THEN 0
                    ELSE CAST(STATUS AS UNSIGNED)
                END
            ) >= 3 THEN 'Bad Customer'
            ELSE 'Good Customer'
        END AS Customer_Status
    FROM credit_record
    GROUP BY ID
)
SELECT
    cr.Customer_Status,
    ROUND(AVG(ar.AMT_INCOME_TOTAL), 2) AS Average_Income
FROM application_record AS ar
JOIN Customer_Risk AS cr
    ON ar.ID = cr.ID
GROUP BY cr.Customer_Status;

/*Business Question 11: Credit Risk by Education Level

Objective: Find the number of Good and Bad customers for each
 education level.
*/

WITH Customer_Risk AS (
    SELECT
        ID,
        CASE
            WHEN MAX(CASE
                        WHEN STATUS IN ('C','X') THEN 0
                        ELSE CAST(STATUS AS UNSIGNED)
                     END) >= 3
            THEN 'Bad Customer'
            ELSE 'Good Customer'
        END AS Customer_Status
    FROM credit_record
    GROUP BY ID
)
SELECT
    ar.NAME_EDUCATION_TYPE,
    cr.Customer_Status,
    COUNT(*) AS Total_Customers
FROM application_record ar
JOIN Customer_Risk cr
ON ar.ID = cr.ID
GROUP BY ar.NAME_EDUCATION_TYPE, cr.Customer_Status
ORDER BY ar.NAME_EDUCATION_TYPE;
/*
Q12. Credit Risk by Income Type.
*/

WITH Customer_Risk AS (
    SELECT
        ID,
        CASE
            WHEN MAX(CASE
                        WHEN STATUS IN ('C','X') THEN 0
                        ELSE CAST(STATUS AS UNSIGNED)
                     END) >= 3
            THEN 'Bad Customer'
            ELSE 'Good Customer'
        END AS Customer_Status
    FROM credit_record
    GROUP BY ID
)
SELECT
    ar.NAME_INCOME_TYPE,
    cr.Customer_Status,
    COUNT(*) AS Total_Customers
FROM application_record ar
JOIN Customer_Risk cr
ON ar.ID = cr.ID
GROUP BY ar.NAME_INCOME_TYPE, cr.Customer_Status;


/*--------------------------------------------------------------
Q13. Credit Risk by Gender.
--------------------------------------------------------------*/

WITH Customer_Risk AS (
    SELECT
        ID,
        CASE
            WHEN MAX(CASE
                        WHEN STATUS IN ('C','X') THEN 0
                        ELSE CAST(STATUS AS UNSIGNED)
                     END) >= 3
            THEN 'Bad Customer'
            ELSE 'Good Customer'
        END AS Customer_Status
    FROM credit_record
    GROUP BY ID
)
SELECT
    ar.CODE_GENDER,
    cr.Customer_Status,
    COUNT(*) AS Total_Customers
FROM application_record ar
JOIN Customer_Risk cr
ON ar.ID = cr.ID
GROUP BY ar.CODE_GENDER, cr.Customer_Status;


/*
Q14. Credit Risk by Home Ownership.
*/

WITH Customer_Risk AS (
    SELECT
        ID,
        CASE
            WHEN MAX(CASE
                        WHEN STATUS IN ('C','X') THEN 0
                        ELSE CAST(STATUS AS UNSIGNED)
                     END) >= 3
            THEN 'Bad Customer'
            ELSE 'Good Customer'
        END AS Customer_Status
    FROM credit_record
    GROUP BY ID
)
SELECT
    ar.FLAG_OWN_REALTY,
    cr.Customer_Status,
    COUNT(*) AS Total_Customers
FROM application_record ar
JOIN Customer_Risk cr
ON ar.ID = cr.ID
GROUP BY ar.FLAG_OWN_REALTY, cr.Customer_Status;


/*
Q15. Credit Risk by Car Ownership.
*/

WITH Customer_Risk AS (
    SELECT
        ID,
        CASE
            WHEN MAX(CASE
                        WHEN STATUS IN ('C','X') THEN 0
                        ELSE CAST(STATUS AS UNSIGNED)
                     END) >= 3
            THEN 'Bad Customer'
            ELSE 'Good Customer'
        END AS Customer_Status
    FROM credit_record
    GROUP BY ID
)
SELECT
    ar.FLAG_OWN_CAR,
    cr.Customer_Status,
    COUNT(*) AS Total_Customers
FROM application_record ar
JOIN Customer_Risk cr
ON ar.ID = cr.ID
GROUP BY ar.FLAG_OWN_CAR, cr.Customer_Status;


/*
Q16. Top 10 Occupations with Highest Bad Customers.
*/

WITH Customer_Risk AS (
    SELECT
        ID,
        CASE
            WHEN MAX(CASE
                        WHEN STATUS IN ('C','X') THEN 0
                        ELSE CAST(STATUS AS UNSIGNED)
                     END) >= 3
            THEN 'Bad Customer'
            ELSE 'Good Customer'
        END AS Customer_Status
    FROM credit_record
    GROUP BY ID
)
SELECT
    ar.OCCUPATION_TYPE,
    COUNT(*) AS Bad_Customers
FROM application_record ar
JOIN Customer_Risk cr
ON ar.ID = cr.ID
WHERE cr.Customer_Status = 'Bad Customer'
GROUP BY ar.OCCUPATION_TYPE
ORDER BY Bad_Customers DESC
LIMIT 10;


/*
Q17. Average Age of Good and Bad Customers.
*/

WITH Customer_Risk AS (
    SELECT
        ID,
        CASE
            WHEN MAX(CASE
                        WHEN STATUS IN ('C','X') THEN 0
                        ELSE CAST(STATUS AS UNSIGNED)
                     END) >= 3
            THEN 'Bad Customer'
            ELSE 'Good Customer'
        END AS Customer_Status
    FROM credit_record
    GROUP BY ID
)
SELECT
    cr.Customer_Status,
    ROUND(AVG(ABS(ar.DAYS_BIRTH)/365),1) AS Average_Age
FROM application_record ar
JOIN Customer_Risk cr
ON ar.ID = cr.ID
GROUP BY cr.Customer_Status;


/*
Q18. Average Family Size by Customer Risk.
*/

WITH Customer_Risk AS (
    SELECT
        ID,
        CASE
            WHEN MAX(CASE
                        WHEN STATUS IN ('C','X') THEN 0
                        ELSE CAST(STATUS AS UNSIGNED)
                     END) >= 3
            THEN 'Bad Customer'
            ELSE 'Good Customer'
        END AS Customer_Status
    FROM credit_record
    GROUP BY ID
)
SELECT
    cr.Customer_Status,
    ROUND(AVG(ar.CNT_FAM_MEMBERS),2) AS Average_Family_Size
FROM application_record ar
JOIN Customer_Risk cr
ON ar.ID = cr.ID
GROUP BY cr.Customer_Status;


/*
Q19. Top 10 Highest Income Customers.
*/

SELECT
    ID,
    AMT_INCOME_TOTAL,
    NAME_INCOME_TYPE,
    OCCUPATION_TYPE
FROM application_record
ORDER BY AMT_INCOME_TOTAL DESC
LIMIT 10;


/*
Q20. Dashboard KPIs.
*/

SELECT COUNT(*) AS Total_Customers
FROM application_record;

SELECT ROUND(AVG(AMT_INCOME_TOTAL),2) AS Average_Income
FROM application_record;

SELECT ROUND(AVG(ABS(DAYS_BIRTH)/365),1) AS Average_Age
FROM application_record;

SELECT COUNT(DISTINCT OCCUPATION_TYPE) AS Total_Occupations
FROM application_record;