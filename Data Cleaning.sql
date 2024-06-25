Create database Automobiles;

use Automobiles;

CREATE TABLE CustomerOrders (
    CustomerCode INT,
    CustomerName VARCHAR(255),
    KitItem VARCHAR(255),
    OEM VARCHAR(255),
    ItemDescription VARCHAR(255),
    ProductType VARCHAR(255),
    ItemCode VARCHAR(255),
    Date DATETIME,
    NumberOfKits int);
   
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/kit_data.csv"
INTO TABLE CustomerOrders
FIELDS TERMINATED BY ',' ENCLOSED BY '"'  
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(CustomerCode, CustomerName, KitItem, OEM, ItemDescription, ProductType, ItemCode, @DateVar, @NumberOfKits)
SET Date = STR_TO_DATE(@DateVar, '%d-%m-%Y %H:%i:%s'),
NumberOfKits = NULLIF(@NumberOfKits, '');   

select * from CustomerOrders;

# **************First Moment Business Decision / Measures of Central Tendency**********************
# *************************************************************************************************

# *******************Calculating Mean*****************
select
avg(NumberOfKits) as Mean_NumberOfKits
from CustomerOrders;
   
# ***********Calculating Median***************    
select
avg(NumberofKits) as Median_NumberOfKits
from(
select NumberOfKits, row_number() over(order by NumberOfKits) as row_num, count(*) over()
as total_rows
from CustomerOrders)
as ranked where row_num in (ceil(total_rows/2.0),floor(total_rows/2.0)+1);

# ***********Calculating Mode***************  
SELECT NumberOfKits AS Mode_NumberOfKits
FROM (
SELECT NumberOfKits, COUNT(NumberOfKits) AS frequency
FROM CustomerOrders
GROUP BY NumberOfKits
ORDER BY frequency DESC
LIMIT 1
) as subquery;

SELECT CustomerCode AS Mode_CustomerCode
FROM (
SELECT CustomerCode, COUNT(CustomerCode) AS frequency
FROM CustomerOrders
GROUP BY CustomerCode
ORDER BY frequency DESC
LIMIT 1
) as subquery;

SELECT CustomerName AS Mode_CustomerName
FROM (
SELECT CustomerName, COUNT(CustomerName) AS frequency
FROM CustomerOrders
GROUP BY Customername
ORDER BY frequency DESC
LIMIT 1
) as subquery;

SELECT KitItem AS Mode_KitItem
FROM (
SELECT KitItem, COUNT(KitItem) AS frequency
FROM CustomerOrders
GROUP BY KitItem
ORDER BY frequency DESC
LIMIT 1
) as subquery;

SELECT OEM AS Mode_OEM
FROM (
SELECT OEM, COUNT(OEM) AS frequency
FROM CustomerOrders
GROUP BY OEM
ORDER BY frequency DESC
LIMIT 1
) as subquery;

SELECT ItemDescription AS Mode_ItemDescription
FROM (
SELECT ItemDescription, COUNT(ItemDescription) AS frequency
FROM CustomerOrders
GROUP BY ItemDescription
ORDER BY frequency DESC
LIMIT 1
) as subquery;

SELECT ProductType AS Mode_ProductType
FROM (
SELECT ProductType, COUNT(ProductType) AS frequency
FROM CustomerOrders
GROUP BY ProductType
ORDER BY frequency DESC
LIMIT 1
) as subquery;

SELECT ItemCode AS Mode_ItemCode
FROM (
SELECT ItemCode, COUNT(ItemCode) AS frequency
FROM CustomerOrders
GROUP BY ItemCode
ORDER BY frequency DESC
LIMIT 1
) as subquery;

#****************Second Moment Business Decision / Measures of Dispersion***************
#***************************************************************************************

#***********Calculating standard deviation**************
select
stddev(NumberOfKits) as stddev_NumberOfKits
from CustomerOrders;   

#**************RANGE***************
select
max(NumberOfKits) - min(NumberOfKits) as NumberOfKits_Range
from CustomerOrders;

# ********************** Calculating Variance *********************
select
variance(NumberOfKits) as NumberOfKits_Variance
from CustomerOrders;


#****************Third Moment Business Decision / Skewness************
#*********************************************************************
SELECT
(
SUM(POWER(NumberOfKits- (SELECT AVG(NumberOfKits) FROM CustomerOrders), 3)) /
(COUNT(*) * POWER((SELECT STDDEV(NumberOfKits) FROM CustomerOrders), 3))
) AS skewness

FROM CustomerOrders;

#************Fourth Moment Business Decision / Kurtosis************
#*******************************************************************
SELECT
(
(SUM(POWER(NumberOfKits- (SELECT AVG(NumberOfkits) FROM CustomerOrders), 4)) /
(COUNT(*) * POWER((SELECT STDDEV(NumberOfKits) FROM CustomerOrders), 4))) - 3
) AS kurtosis
FROM CustomerOrders;

    
# ********************** Data Pre-Processing ******************

# ************** Finding Missing-Value **************************
SELECT
COUNT(*) AS total_rows,
SUM(CASE WHEN CustomerCode IS NULL THEN 1 ELSE 0 END) AS CustomerCode_missing,
SUM(CASE WHEN CustomerName IS NULL THEN 1 ELSE 0 END) AS CustomerName_missing,
SUM(CASE WHEN KitItem IS NULL THEN 1 ELSE 0 END) AS KitItem_missing,
SUM(CASE WHEN OEM IS NULL THEN 1 ELSE 0 END) AS OEM_missing,
SUM(CASE WHEN ItemDescription IS NULL THEN 1 ELSE 0 END) AS ItemDescription_missing,
SUM(CASE WHEN ProductType IS NULL THEN 1 ELSE 0 END) AS ProductType_missing,
SUM(CASE WHEN ItemCode IS NULL THEN 1 ELSE 0 END) AS ItemCode_missing,
SUM(CASE WHEN NumberOfKits IS NULL THEN 1 ELSE 0 END) AS NumberOfKits_missing
FROM CustomerOrders;

# *****************Handling Missing Values*********************
SET @mean = (SELECT AVG(NumberOfKits) FROM CustomerOrders WHERE NumberOfKits IS NOT NULL);

-- Update the missing values with the calculated mean
UPDATE CustomerOrders
SET NumberOfKits = IFNULL(NumberOfKits, @mean);

#******************Handling Duplicates******************* 

SELECT 
CustomerCode, COUNT(*) as duplicate_count,
CustomerName, Count(*) as duplicate_Count,
KitItem, Count(*) as duplicate_Count,
OEM, Count(*) as duplicate_Count,
ItemDescription, Count(*) as duplicate_Count,
ProductType, Count(*) as duplicate_Count,
ItemCode, Count(*) as duplicate_Count,
NumberOfKits, Count(*) as duplicate_Count
FROM CustomerOrders
GROUP BY CustomerCode,CustomerName,KitItem,OEM,ItemDescription,ProductType,ItemCode,NumberofKits
HAVING COUNT(*) > 1;

# Drop duplicates
CREATE TABLE temp_CustomerOrders AS
SELECT DISTINCT *
FROM CustomerOrders;

TRUNCATE TABLE CustomerOrders;

INSERT INTO CustomerOrders
SELECT * FROM temp_CustomerOrders;

DROP TABLE temp_CustomerOrders;

select * from CustomerOrders;


#***********calculating zscore and find outliers****************
#******************Zscore**************
SELECT
    NumberOfKits,
    (NumberOfKits - avg(NumberOfKits) over())/stddev(NumberOfKits) over() as NumberofKits_Zscore
FROM
    CustomerOrders;
    
#****************Finding Outliers******************    

SELECT * from
(select
    NumberOfKits,
    (NumberOfKits - avg(NumberOfKits) over())/stddev(NumberOfKits) over() as NumberOfKits_Zscore
    from CustomerOrders ) as score_table
where NumberOfKits_Zscore >3 or NumberOfKits_zscore<-3;


SELECT 
    (SELECT NumberOfKits
     FROM (SELECT NumberOfKits, ROW_NUMBER() OVER (ORDER BY NumberOfKits) AS row_num
           FROM CustomerOrders) AS ranked
     WHERE row_num = CEIL(0.05 * COUNT(*))) AS lower_percentile,
    (SELECT NumberOfKits
     FROM (SELECT NumberOfKits, ROW_NUMBER() OVER (ORDER BY NumberOfKits) AS row_num
           FROM CustomerOrders) AS ranked
     WHERE row_num = CEIL(0.95 * COUNT(*))) AS upper_percentile
FROM CustomerOrders;

# Mean and Standard Deviation of the NumberOfKits column 
SET @mean = (SELECT AVG(NumberOfKits) FROM CustomerOrders); 
SET @stddev = (SELECT STDDEV(NumberOfKits) FROM CustomerOrders);

# ZERO NON ZERO VARIANCE
 SELECT VARIANCE(NumberOfKits) AS Column1_variance
 FROM CustomerOrders;
 
 # DESCRETISATION 
 SELECT CustomerCode, NTILE(5) OVER (ORDER BY NumberOfKits) AS NumberOfKits_bin
 FROM CustomerOrders;
 
 # LABEL ENCODING -- Assign numerical labels to categorical values using CASE statements 
 SELECT CASE WHEN ProductType = 'A' THEN 1 WHEN ProductType = 'B' THEN 2 ELSE 3 END AS ProductType_label
 FROM CustomerOrders;
 
 # DUMMY/ONE HOT/BINARY ENCODING 
 SELECT 
 CASE WHEN ProductType = 'A' THEN 1 ELSE 0 END AS ProductType_A, 
 CASE WHEN ProductType = 'B' THEN 1 else 0 end as productType_B,
 case when productType = 'C' then 1 else 0 end as productType_c
from CustomerOrders;

set sql_safe_updates = 0;

# Transformation for Linearization
update CustomerOrders
set NumbersOfKits = log(NumberOfKits);

# Normalization
select
    (log(NumberOfKits + 1) - min_max.min_log_kits) / (min_max.max_log_kits - min_max.min_log_kits) as normalized_log_kits
from 
    CustomerOrders,
    (select
		 min(log(NumberOfKits + 1)) as min_log_kits,
         max(log(NumberOfKits + 1)) as max_log_kits
    from
       CustomerOrders) as min_max;
       
       
# ********************After Preprocessing*******************       
       
# *******************Calculating Mean*****************
select
avg(NumberOfKits) as Mean_NumberOfKits
from CustomerOrders;
   
# ***********Calculating Median***************    
select
avg(NumberofKits) as Median_NumberOfKits
from(
select NumberOfKits, row_number() over(order by NumberOfKits) as row_num, count(*) over()
as total_rows
from CustomerOrders)
as ranked where row_num in (ceil(total_rows/2.0),floor(total_rows/2.0)+1);

# ***********Calculating Mode***************  
SELECT NumberOfKits AS Mode_NumberOfKits
FROM (
SELECT NumberOfKits, COUNT(NumberOfKits) AS frequency
FROM CustomerOrders
GROUP BY NumberOfKits
ORDER BY frequency DESC
LIMIT 1
) as subquery;

SELECT CustomerCode AS Mode_CustomerCode
FROM (
SELECT CustomerCode, COUNT(CustomerCode) AS frequency
FROM CustomerOrders
GROUP BY CustomerCode
ORDER BY frequency DESC
LIMIT 1
) as subquery;

SELECT CustomerName AS Mode_CustomerName
FROM (
SELECT CustomerName, COUNT(CustomerName) AS frequency
FROM CustomerOrders
GROUP BY Customername
ORDER BY frequency DESC
LIMIT 1
) as subquery;

SELECT KitItem AS Mode_KitItem
FROM (
SELECT KitItem, COUNT(KitItem) AS frequency
FROM CustomerOrders
GROUP BY KitItem
ORDER BY frequency DESC
LIMIT 1
) as subquery;

SELECT OEM AS Mode_OEM
FROM (
SELECT OEM, COUNT(OEM) AS frequency
FROM CustomerOrders
GROUP BY OEM
ORDER BY frequency DESC
LIMIT 1
) as subquery;

SELECT ItemDescription AS Mode_ItemDescription
FROM (
SELECT ItemDescription, COUNT(ItemDescription) AS frequency
FROM CustomerOrders
GROUP BY ItemDescription
ORDER BY frequency DESC
LIMIT 1
) as subquery;

SELECT ProductType AS Mode_ProductType
FROM (
SELECT ProductType, COUNT(ProductType) AS frequency
FROM CustomerOrders
GROUP BY ProductType
ORDER BY frequency DESC
LIMIT 1
) as subquery;

SELECT ItemCode AS Mode_ItemCode
FROM (
SELECT ItemCode, COUNT(ItemCode) AS frequency
FROM CustomerOrders
GROUP BY ItemCode
ORDER BY frequency DESC
LIMIT 1
) as subquery;

#****************Second Moment Business Decision / Measures of Dispersion***************
#***************************************************************************************

#***********Calculating standard deviation**************
select
stddev(NumberOfKits) as stddev_NumberOfKits
from CustomerOrders;   

#**************RANGE***************
select
max(NumberOfKits) - min(NumberOfKits) as NumberOfKits_Range
from CustomerOrders;

# ********************** Calculating Variance *********************
select
variance(NumberOfKits) as NumberOfKits_Variance
from CustomerOrders;


#****************Third Moment Business Decision / Skewness************
#*********************************************************************
SELECT
(
SUM(POWER(NumberOfKits- (SELECT AVG(NumberOfKits) FROM CustomerOrders), 3)) /
(COUNT(*) * POWER((SELECT STDDEV(NumberOfKits) FROM CustomerOrders), 3))
) AS skewness

FROM CustomerOrders;

#************Fourth Moment Business Decision / Kurtosis************
#*******************************************************************
SELECT
(
(SUM(POWER(NumberOfKits- (SELECT AVG(NumberOfkits) FROM CustomerOrders), 4)) /
(COUNT(*) * POWER((SELECT STDDEV(NumberOfKits) FROM CustomerOrders), 4))) - 3
) AS kurtosis
FROM CustomerOrders;











  
    
    
    
