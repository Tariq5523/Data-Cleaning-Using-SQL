SELECT *
FROM t..NashvilleHousing


-- Data CLeaning of Housing Data

-- Standerdize Date Format

-- Updating the sales date column by removing the time to the right of it	


UPDATE t..NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)

-- Populate PropertyAddress

SELECT COUNT(CASE WHEN PropertyAddress IS NULL THEN 1 END) AS NullCount
FROM t..NashvilleHousing;

SELECT COUNT(CASE WHEN OwnerAddress IS NULL THEN 1 END) AS NullCount
FROM t..NashvilleHousing;

-- Check for addresses of dupicate ParecelID's and populate the PropertyAddress column based on that

SELECT nash1.ParcelID, nash1.PropertyAddress, nash2.ParcelID, nash2.PropertyAddress, ISNULL(nash1.PropertyAddress, nash2.PropertyAddress)
FROM t..NashvilleHousing AS nash1
JOIN t..NashvilleHousing AS nash2 
	ON nash1.ParcelID  = nash2.ParcelID
	AND nash1.[UniqueID ] <> nash2.[UniqueID ]
WHERE nash1.PropertyAddress IS NULL;

UPDATE nash1
SET PropertyAddress = ISNULL(nash1.PropertyAddress, nash2.PropertyAddress)
FROM t..NashvilleHousing AS nash1
JOIN t..NashvilleHousing AS nash2 
	ON nash1.ParcelID  = nash2.ParcelID
	AND nash1.[UniqueID ] <> nash2.[UniqueID ]
WHERE nash1.PropertyAddress IS NULL;

SELECT COUNT(CASE WHEN PropertyAddress IS NULL THEN 1 END) AS NullCount
FROM t..NashvilleHousing; -- Now we have no null values in the PropertyAddress column.


--Breaking out Address cloumns (PropertyAddress and OwenerAddress) into seperate columns

-- Updating PropertyAddress Column Using SUBSTRING and CHARINDEX

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS ADDRESS,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS CITY
FROM t..NashvilleHousing;

ALTER TABLE t..NashvilleHousing
ADD PropertyStreetAddress NVARCHAR(255);

UPDATE t..NashvilleHousing
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE t..NashvilleHousing
ADD PropertyCity NVARCHAR(255);

UPDATE t..NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--Updating OwnerAddress Column Using PARSENAME
SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM t..NashvilleHousing;


ALTER TABLE t..NashvilleHousing
ADD OwnerStreetAddress NVARCHAR(255);

UPDATE t..NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE t..NashvilleHousing
ADD OwnerCity NVARCHAR(255);

UPDATE t..NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE t..NashvilleHousing
ADD OwnerState NVARCHAR(255);

UPDATE t..NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



--Change 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM t..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM t..NashvilleHousing;

UPDATE t..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END


-- Remove Duplicates

SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM t..NashvilleHousing;



--Remove Unused Colmuns

ALTER TABLE t..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict


