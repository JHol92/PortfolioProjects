SELECT
*
FROM
 PortfolioProject..NashvilleHousing

 -- Standardise Date Format

SELECT
SaleDateConverted,
CONVERT(Date,SaleDate)
FROM
 PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET	SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET	SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Porperty Address Data

SELECT
*
FROM
 PortfolioProject..NashvilleHousing
--WHERE
--PropertyAddress IS Null
ORder By
ParcelID -- PacelID a match for unique address


SELECT
a.ParcelID,
a.PropertyAddress,
b.ParcelID,
b.PropertyAddress,
ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM
 PortfolioProject..NashvilleHousing AS a
 JOIN PortfolioProject..NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM
 PortfolioProject..NashvilleHousing AS a
 JOIN PortfolioProject..NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into individual columns (Address, city, State)

SELECT
PropertyAddress
FROM
 PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN (PropertyAddress)) AS Address
FROM
 PortfolioProject..NashvilleHousing


 ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET	PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN (PropertyAddress))

SELECT
*
FROM
 PortfolioProject..NashvilleHousing


 SELECT
OwnerAddress
FROM
 PortfolioProject..NashvilleHousing

 SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM
 PortfolioProject..NashvilleHousing

 ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET	OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
Add OnwerSplitCity Nvarchar(255);

Update NashvilleHousing
SET	OnwerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)



 -- Change Y and N to yes and No in "Sold as Vacanct" field

 SELECT
 DISTINCT(SoldAsVacant),
 COUNT(SoldAsVacant)
FROM
 PortfolioProject..NashvilleHousing
GROUP BY
SoldAsVacant
ORDER BY
2

SELECT
 SoldAsVacant,
 CASE
 WHEN SoldAsVacant = 'Y' THEN 'Yes'
 WHEN SoldAsVacant = 'N' THEN 'No'
 ELSE SoldAsVacant
 END
FROM
 PortfolioProject..NashvilleHousing

 Update NashvilleHousing
SET	SoldAsVacant = CASE
 WHEN SoldAsVacant = 'Y' THEN 'Yes'
 WHEN SoldAsVacant = 'N' THEN 'No'
 ELSE SoldAsVacant
 END

-- Remove Duplcates (CTE)

WITH RowNumCTE AS (
SELECT
*,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
PropertyAddress, 
SalePrice,
SaleDate,
LegalReference
ORDER BY 
UniqueID) As Row_num
FROM 
PortfolioProject..NashvilleHousing
--ORDER BY
--ParcelID
)
DELETE
FROM 
RowNumCTE
WHERE Row_num > 1
--ORDER BY PropertyAddress

-- Delete Unused Columns

SELECT
*
FROM
 PortfolioProject..NashvilleHousing

 ALTER TABLE PortfolioProject..NashvilleHousing
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

 ALTER TABLE PortfolioProject..NashvilleHousing
 DROP COLUMN SaleDate