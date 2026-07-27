/*  CREDIT CARD CUSTOMER RISK ANALYTICS PROJECT
   Author: Avyan Soni
   Database: credit_card_project */
   /* SECTION 1 : DATA EXPLORATION */
 
 /* 1. Total Records */
 
SELECT COUNT(*) AS Total_Application_Records
FROM application_record;

SELECT COUNT(*) AS Total_Credit_Records
FROM credit_record;


/* 2. Unique Customers */
SELECT COUNT(DISTINCT ID) AS Total_Applicants
FROM application_record;

SELECT COUNT(DISTINCT ID) AS Customers_With_Credit_History
FROM credit_record;


/* 3. Customers Available in Both Tables */
SELECT
    COUNT(DISTINCT a.ID) AS Application_Customers,
    COUNT(DISTINCT c.ID) AS Credit_Customers,
    COUNT(DISTINCT CASE
        WHEN c.ID IS NOT NULL THEN a.ID
    END) AS Matched_Customers
FROM application_record a
LEFT JOIN credit_record c
ON a.ID = c.ID;
/* 4. Missing Values */

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(OCCUPATION_TYPE) AS Occupation_Available,
    COUNT(*) - COUNT(OCCUPATION_TYPE) AS Missing_Occupation
FROM application_record;
/* 5. Gender Distribution */
SELECT
    CODE_GENDER,
    COUNT(*) AS Customers,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM application_record),
        2
    ) AS Percentage
FROM application_record
GROUP BY CODE_GENDER;

/* 6. Income Type Distribution */
SELECT
    NAME_INCOME_TYPE,
    COUNT(*) AS Customers
FROM application_record
GROUP BY NAME_INCOME_TYPE
ORDER BY Customers DESC;

/* 7. Average Income by Income Type */
SELECT
    NAME_INCOME_TYPE,
    ROUND(AVG(AMT_INCOME_TOTAL),2) AS Average_Income
FROM application_record
GROUP BY NAME_INCOME_TYPE
ORDER BY Average_Income DESC;

/* 8. Age Statistics */
SELECT
    ROUND(AVG(-DAYS_BIRTH/365.25),1) AS Average_Age,
    ROUND(MIN(-DAYS_BIRTH/365.25),1) AS Youngest_Age,
    ROUND(MAX(-DAYS_BIRTH/365.25),1) AS Oldest_Age
FROM application_record;


/* 9. Credit Status Distribution */

SELECT
    STATUS,
    COUNT(*) AS Total_Records
FROM credit_record
GROUP BY STATUS
ORDER BY STATUS;
