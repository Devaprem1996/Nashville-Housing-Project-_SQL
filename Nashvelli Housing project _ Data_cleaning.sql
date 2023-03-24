/*

Cleaning Data in SQL queries

*/

select *
from NashvilleHousingProject..NashvilleHousing

                                        -- Standardize Date Format 

select saleDateConverted, CONVERT(date,SaleDate)
from NashvilleHousingProject..NashvilleHousing

Update NashvilleHousingProject..NashvilleHousing
SET SaleDate =  CONVERT(date,SaleDate)

Alter Table NashvilleHousingProject..NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousingProject..NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

                                         -- Populate property address data

select *
from NashvilleHousingProject..NashvilleHousing
where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousingProject..NashvilleHousing a
join  NashvilleHousingProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousingProject..NashvilleHousing a
join  NashvilleHousingProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



                      -- Breaking out Address Into Individual Columns (Address,city,state)


select propertyAddress
from NashvilleHousingProject..NashvilleHousing


select 
Substring(propertyAddress, 1, charindex(',', propertyAddress)-1) as Address
, Substring(propertyAddress, charindex(',', propertyAddress)+1, len(propertyAddress)) as city 
from NashvilleHousingProject..NashvilleHousing


Alter Table NashvilleHousingProject..NashvilleHousing
add PropertySplitAddress NVARCHAR(255);

update NashvilleHousingProject..NashvilleHousing
set PropertySplitAddress = Substring(propertyAddress, 1, charindex(',', propertyAddress)-1)

Alter Table NashvilleHousingProject..NashvilleHousing
add PropertySplitCity NVARCHAR(255);

update NashvilleHousingProject..NashvilleHousing
set PropertySplitCity = Substring(propertyAddress, charindex(',', propertyAddress)+1, len(propertyAddress))



                 -- lets do this to OwnerAddtress also with PARSENAME methods:



select OwnerAddress
from NashvilleHousingProject..NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from NashvilleHousingProject..NashvilleHousing


Alter Table NashvilleHousingProject..NashvilleHousing
add OwnerSplitAddress NVARCHAR(255);

update NashvilleHousingProject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

Alter Table NashvilleHousingProject..NashvilleHousing
add OwnerSplitCity NVARCHAR(255);

update NashvilleHousingProject..NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

Alter Table NashvilleHousingProject..NashvilleHousing
add OwnerSplitState NVARCHAR(255);

update NashvilleHousingProject..NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

select OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
from NashvilleHousingProject..NashvilleHousing


                       -- Change Y and N to yes and No in 'Sold as vacant' field

select Distinct(SoldAsVacant),count(SoldAsVacant)
from NashvilleHousingProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
from NashvilleHousingProject..NashvilleHousing

UPDATE NashvilleHousingProject..NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


                                               -- Remove Duplicates


Select *,
ROW_NUMBER() Over (
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			Order by
			UniqueiD
				)rowNum

from NashvilleHousingProject..NashvilleHousing

order by 2

                         -- use CTE to REMOVE dUPLICATES (Best practices)

WITH RowNumCTE as (
Select *,
ROW_NUMBER() Over (
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			Order by
			UniqueiD
				)rowNum

from NashvilleHousingProject..NashvilleHousing
)

SELECT DISTINCT(rowNum)
from RowNumCTE
--where rowNum > 1


                                              -- Delete unused Columns

select  *
from NashvilleHousingProject..NashvilleHousing

Alter Table  NashvilleHousingProject..NashvilleHousing
Drop Column ownerAddress,TaxDistrict,PropertyAddress,SaleDate