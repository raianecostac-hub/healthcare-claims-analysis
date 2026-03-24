-- ============================================
-- MEDICARE INPATIENT CLAIMS ANALYSIS — 2023
-- Author: Raiane Camara
-- Tools: SQLite / DBeaver
-- ============================================


-- ============================================
-- 1. TOP 10 MOST EXPENSIVE PROCEDURES
-- ============================================
SELECT 
    DRG_Desc AS Procedure,
    ROUND(AVG(Avg_Submtd_Cvrd_Chrg), 2) AS Avg_Charge,
    ROUND(AVG(Avg_Tot_Pymt_Amt), 2) AS Avg_Payment,
    ROUND(AVG(Avg_Submtd_Cvrd_Chrg) - AVG(Avg_Tot_Pymt_Amt), 2) AS Avg_Gap
FROM medicare_claims
GROUP BY DRG_Desc
ORDER BY Avg_Charge DESC
LIMIT 10;


-- ============================================
-- 2. AVERAGE CHARGE VS PAYMENT BY STATE
-- ============================================
SELECT 
    Rndrng_Prvdr_State_Abrvtn AS State,
    ROUND(AVG(Avg_Submtd_Cvrd_Chrg), 2) AS Avg_Charge,
    ROUND(AVG(Avg_Tot_Pymt_Amt), 2) AS Avg_Payment,
    ROUND(AVG(Avg_Mdcr_Pymt_Amt), 2) AS Avg_Medicare_Payment,
    SUM(Tot_Dschrgs) AS Total_Discharges
FROM medicare_claims
GROUP BY Rndrng_Prvdr_State_Abrvtn
ORDER BY Avg_Charge DESC
LIMIT 15;


-- ============================================
-- 3. HOSPITAL CHARGE INFLATION
-- ============================================
SELECT 
    Rndrng_Prvdr_Org_Name AS Hospital,
    Rndrng_Prvdr_State_Abrvtn AS State,
    Rndrng_Prvdr_City AS City,
    ROUND(AVG(Avg_Submtd_Cvrd_Chrg), 2) AS Avg_Charge,
    ROUND(AVG(Avg_Tot_Pymt_Amt), 2) AS Avg_Payment,
    SUM(Tot_Dschrgs) AS Total_Discharges,
    ROUND(
        (AVG(Avg_Submtd_Cvrd_Chrg) - AVG(Avg_Tot_Pymt_Amt)) 
        / AVG(Avg_Submtd_Cvrd_Chrg) * 100, 2
    ) AS Charge_Inflation_Pct
FROM medicare_claims
GROUP BY Rndrng_Prvdr_Org_Name, Rndrng_Prvdr_State_Abrvtn
HAVING Total_Discharges >= 100
ORDER BY Charge_Inflation_Pct DESC
LIMIT 10;


-- ============================================
-- 4. PROCEDURE VOLUME VS TOTAL MEDICARE COST
-- ============================================
SELECT 
    DRG_Desc AS Procedure,
    SUM(Tot_Dschrgs) AS Total_Discharges,
    ROUND(AVG(Avg_Tot_Pymt_Amt), 2) AS Avg_Payment_Per_Case,
    ROUND(SUM(Tot_Dschrgs) * AVG(Avg_Tot_Pymt_Amt), 2) AS Total_Medicare_Cost
FROM medicare_claims
GROUP BY DRG_Desc
ORDER BY Total_Discharges DESC
LIMIT 10;


-- ============================================
-- 5. BONUS: MOST EXPENSIVE STATES FOR SEPSIS
-- ============================================
SELECT 
    Rndrng_Prvdr_State_Abrvtn AS State,
    COUNT(*) AS Hospitals_Reporting,
    SUM(Tot_Dschrgs) AS Total_Sepsis_Cases,
    ROUND(AVG(Avg_Submtd_Cvrd_Chrg), 2) AS Avg_Charge,
    ROUND(AVG(Avg_Tot_Pymt_Amt), 2) AS Avg_Payment,
    ROUND(SUM(Tot_Dschrgs) * AVG(Avg_Tot_Pymt_Amt), 2) AS Total_State_Cost
FROM medicare_claims
WHERE DRG_Desc LIKE '%SEPTICEMIA%'
GROUP BY Rndrng_Prvdr_State_Abrvtn
ORDER BY Total_State_Cost DESC
LIMIT 10;