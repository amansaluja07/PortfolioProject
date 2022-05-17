-- Standarize date Format

Select *
From [Portfolio Project]..NashvilleHousing

Alter Table NashvilleHousing
Drop Column SalesdateConverted

Alter Table NashvilleHousing
Add SaledateConverted date

Update NashvilleHousing
Set SaledateConverted= Convert(Date,SaleDate)

Select *
From [Portfolio Project]..NashvilleHousing

-- Populate Property Address data

Select *
From [Portfolio Project]..NashvilleHousing
where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.[UniqueID ], b.ParcelID, b.UniqueID
FROM [Portfolio Project]..NashvilleHousing a
Join [Portfolio Project]..NashvilleHousing b
On a.ParcelID=b.ParcelID and
a.[UniqueID ] <> b.[UniqueID ]

Select *
From [Portfolio Project]..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID,b.ParcelID, a.PropertyAddress, b.PropertyAddress, a.[UniqueID ], b.[UniqueID ], ISNULL(a.propertyaddress,b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing a
Join [Portfolio Project]..NashvilleHousing b
On a.ParcelID=b.ParcelID and
a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is Null

Update a
Set PropertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing a
Join [Portfolio Project]..NashvilleHousing b
On a.ParcelID=b.ParcelID and
a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is Null
Substring(PropertyAddress, CHARINDEX(',',PropertyAddress), (LEN(PropertyAddress)-CHARINDEX(',',PropertyAddress))as City

-- Breaking out address into Individual Columns(Address, City , State)

Select PropertyAddress, SubString(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, (LEN(PropertyAddress)-(CHARINDEX(',',PropertyAddress))))
From [Portfolio Project]..NashvilleHousing


Select PropertyAddress, SubString(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
From [Portfolio Project]..NashvilleHousing

Alter Table [Portfolio Project]..NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Alter Table [Portfolio Project]..NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress=SubString(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

Update NashvilleHousing
SET PropertySplitCity =Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

Select *
From [Portfolio Project]..NashvilleHousing

--Breaking out address into Individual Columns(Address, City , State)


Select OwnerAddress
From [Portfolio Project]..NashvilleHousing

Select OwnerAddress, SUBSTRING(OwnerAddress, 1, CharIndex(',',OwnerAddress)-1) as OwnerSplitAdresss
From [Portfolio Project]..NashvilleHousing

Select OwnerAddress, SUBSTRING(OwnerAddress, (CharIndex(',',OwnerAddress)+1), Len(OwnerAddress)) as OwnerSplitCity
From [Portfolio Project]..NashvilleHousing

Select PARSENAME(Replace(OwnerAddress,',','.'),3) as Address
From [Portfolio Project]..NashvilleHousing 

Select PARSENAME(Replace(OwnerAddress,',','.'),2) as City
From [Portfolio Project]..NashvilleHousing

Select PARSENAME(Replace(OwnerAddress,',','.'),1) as State
From [Portfolio Project]..NashvilleHousing

Alter Table [Portfolio Project]..NashvilleHousing
Add Address Nvarchar(255)

Alter Table [Portfolio Project]..NashvilleHousing
Add City Nvarchar(255)

Alter Table [Portfolio Project]..NashvilleHousing
Add State Nvarchar(255)

Update [Portfolio Project]..NashvilleHousing
Set Address= PARSENAME(Replace(OwnerAddress,',','.'),3)

Update [Portfolio Project]..NashvilleHousing
Set City= PARSENAME(Replace(OwnerAddress,',','.'),2)

Update [Portfolio Project]..NashvilleHousing
Set State= PARSENAME(Replace(OwnerAddress,',','.'),1)

Select *
From [Portfolio Project]..NashvilleHousing


-- Change Y and N to Yes and No in "Sold As vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project]..NashvilleHousing
Group by SoldAsVacant
order by 2

Select Replace(SoldAsVacant,"N","No")
From [Portfolio Project]..NashvilleHousing

Select Replace(SoldAsVacant,"Y","Yes")
From [Portfolio Project]..NashvilleHousing

Select SoldAsVacant,
Case When SoldAsVacant='Y' then 'Yes'
     When SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 END
From [Portfolio Project]..NashvilleHousing

Update [Portfolio Project]..NashvilleHousing
Set SoldAsVacant= Case When SoldAsVacant='Y' then 'Yes'
     When SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 END

Select Distinct(SoldAsVacant)
From [Portfolio Project]..NashvilleHousing

--Remove Duplicates
    With RowNumCTE AS(
	Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
				  UniqueID
				  ) row_num
From [Portfolio Project]..NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
where row_num>1
order by PropertyAddress


-- Delete Unused Columns

Select *
From [Portfolio Project]..NashvilleHousing

Alter Table [Portfolio Project]..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress


Alter Table [Portfolio Project]..NashvilleHousing
Drop Column SaleDate