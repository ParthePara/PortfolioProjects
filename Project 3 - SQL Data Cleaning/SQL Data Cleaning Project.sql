/*
Cleaning Data in SQL Queries
*/


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- 1) Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- 2) Populate Property Address data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

-- Need to do a self join in order to match the missing addresses to a reference point
SELECT ref.[UniqueID ], ref. ParcelID, ref.PropertyAddress, 
new.[UniqueID ], new.ParcelID, new.PropertyAddress,
ISNULL(new.PropertyAddress, ref.PropertyAddress) AS Input
FROM PortfolioProject..NashvilleHousing ref
JOIN PortfolioProject..NashvilleHousing new
	ON ref.ParcelID = new.ParcelID
	AND ref.[UniqueID ] <> new.[UniqueID ]
WHERE new.PropertyAddress IS NULL

UPDATE new
SET new.PropertyAddress = ISNULL(new.PropertyAddress, ref.PropertyAddress)
FROM PortfolioProject..NashvilleHousing ref
JOIN PortfolioProject..NashvilleHousing new
	ON ref.ParcelID = new.ParcelID
	AND ref.[UniqueID ] <> new.[UniqueID ]


--------------------------------------------------------------------------------------------------------------------------

-- 3) Breaking out Address into Individual Columns (Address, City, State)


--- Part 1: Using SUBSTRING, CHARINDEX, and LEN

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertyAddressONLY nvarchar(50),
PropertyAddressCITY nvarchar(50)

UPDATE NashvilleHousing
SET PropertyAddressONLY = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1),
PropertyAddressCITY = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT PropertyAddress, PropertyAddressONLY, PropertyAddressCITY
FROM PortfolioProject.dbo.NashvilleHousing

--- Part 2: Using PARSENAME and REPLACE

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM PortfolioProject..NashvilleHousing
ORDER BY 1 DESC

ALTER TABLE NashvilleHousing
ADD OwnerAddressONLY nvarchar(255),
OwnerAddressCITY nvarchar(255),
OwnerAddressSTATE nvarchar(255)

UPDATE NashvilleHousing
SET OwnerAddressONLY = PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
OwnerAddressCITY = PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
OwnerAddressSTATE = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


--------------------------------------------------------------------------------------------------------------------------


-- 4) Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY (SoldAsVacant)
ORDER BY 2

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing
ORDER BY 1

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- 5) Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) row_num
FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

---------------------------------------------------------------------------------------------------------

-- 6) Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate, OwnerAddress, PropertyAddress
