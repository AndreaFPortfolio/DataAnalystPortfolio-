/* Cleaning data is SQL queries */

Select * 
From Portfolio_Project.dbo.NashvilleHousing

-- Standardize Date Format 

Select Convert (date, Saledate) 
From NashvilleHousing

update NashvilleHousing
SET Saledate = Convert(date, Saledate)

-- If the above code does not convert the coloum - please refer to the below coloumn 

Alter Table NashvilleHousing
Add Saledateconverted date 

update NashvilleHousing
SET Saledateconverted = Convert(date, Saledate) 

-- Populate property address data 


Select A.UniqueID, a.PropertyAddress, A.parcelid, B.PropertyAddress, isnull (a.propertyaddress,B.PropertyAddress) 
From NashvilleHousing A
Join NashvilleHousing B
	on  A.parcelid = B.parcelid
	and A.UniqueID <> B.UniqueID
where A.PropertyAddress is null 

Update a
Set PropertyAddress = isnull (a.propertyaddress,B.PropertyAddress) 
From NashvilleHousing A
Join NashvilleHousing B
	on  A.parcelid = B.parcelid
	and A.UniqueID <> B.UniqueID
where A.PropertyAddress is null

-- Breaking out Address into individual coloumns (address, City, State) 

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From NashvilleHousing

ALTER TABLE NashvilleHousing 
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing 
SET PropertySplitCity = SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) 


-- Using parsename to split the owners address 

Select 
PARSENAME(Replace(OwnerAddress,',','.'), 1),
PARSENAME(Replace(OwnerAddress,',','.'), 2),
PARSENAME(Replace(OwnerAddress,',','.'), 3)
From  NashvilleHousing

ALter Table NashvilleHousing 
Add OwnerSplitState nvarchar(255) ;

Update NashvilleHousing 
Set OwnerSplitState  = PARSENAME(Replace(OwnerAddress,',','.'), 1)

ALter Table NashvilleHousing 
Add OwnerSplitCity nvarchar(255) ;

Update NashvilleHousing 
Set OwnerSplitCity  = PARSENAME(Replace(OwnerAddress,',','.'), 2)


ALter Table NashvilleHousing 
Add OwnerSplitAddress nvarchar(255) ;

Update NashvilleHousing 
Set OwnerSplitAddress  = PARSENAME(Replace(OwnerAddress,',','.'), 3)


-- Change Y and N to Yes and No in "Sold as Vancant"

Select  Distinct (SoldAsVacant),Count (SoldAsVacant) as count_of_each
From NashvilleHousing
Group by SoldAsVacant
Order by count_of_each

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End 
From NashvilleHousing
Order by 2

Update NashvilleHousing
Set SoldAsVacant = 
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End 

-- Remove Duplicates 


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing)
select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- note - Used the above code to check for duplicate information - change sleect to delete to remove duplicates 

-- Delete Unsused Coloumns 

Select top 5 * 
From  NashvilleHousing

ALter Table NashvilleHousing
Drop COLUMN Owneraddress, TaxDistrict, PropertyAddress, SaleDate  

