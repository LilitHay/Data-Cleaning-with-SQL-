SELECT * 
FROM Portfolio_projects.dbo.NashvilleHousing

-- Standartize date format
SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM Portfolio_projects.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate property address data
SELECT a.PropertyAddress, b.PropertyAddress, a.ParcelID,b.ParcelID, ISNULL(a.PropertyAddress,b.PropertyAddress) 
FROM Portfolio_projects.dbo.NashvilleHousing a
JOIN Portfolio_projects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <>b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio_projects.dbo.NashvilleHousing a
JOIN Portfolio_projects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <>b.[UniqueID ]
WHERE a.PropertyAddress is null
 
SELECT * 
FROM Portfolio_projects.dbo.NashvilleHousing
WHERE PropertyAddress is null



-- Breaking out address into individual columns(address, city)

SELECT PropertyAddress, 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address, 
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM Portfolio_projects.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertyCityAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

 



SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Portfolio_projects.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * 
FROM Portfolio_projects.dbo.NashvilleHousing



-- Change N and Y with NO and Yes in column SoldAsVacant


SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant) as Count
FROM Portfolio_projects.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY Count


SELECT 
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM Portfolio_projects.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END



-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress, 
				SaleDate, SalePrice, 
				LegalReference
				ORDER BY 
					UniqueID) row_num
FROM Portfolio_projects.dbo.NashvilleHousing)
DELETE
FROM RowNumCTE
WHERE row_num > 1





-- Delete unused columns
SELECT *
FROM Portfolio_projects.dbo.NashvilleHousing


ALTER TABLE Portfolio_projects.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict


ALTER TABLE Portfolio_projects.dbo.NashvilleHousing
DROP COLUMN SaleDate