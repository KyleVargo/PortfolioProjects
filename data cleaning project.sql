--Cleaning Data in SQL Queries
Select *
From PortfolioProject..NashvilleHousing


-- Standerdize/Change Sales Date
Select SalesDateConverted, CONVERT(date,SaleDate)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(date,SaleDate)

Alter Table NashvilleHousing
Add SalesDateConverted Date;

Update NashvilleHousing
Set SalesDateConverted = convert(date,SaleDate)



--Populate Property Adress Data


Select *
From PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNull(A.PropertyAddress,B.PropertyAddress)
From PortfolioProject..NashvilleHousing A
join PortfolioProject..NashvilleHousing B
on A.ParcelID = B.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where A.PropertyAddress is null

Update A
SET PropertyAddress = ISNull(A.PropertyAddress,B.PropertyAddress)
From PortfolioProject..NashvilleHousing A
join PortfolioProject..NashvilleHousing B
on A.ParcelID = B.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where A.PropertyAddress is null

--Sepertate Adress(Adress, City, Sate) into indivdual columns

Select PropertyAddress
From PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) As Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) As Address
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Varchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


Alter Table NashvilleHousing
Add PropertySplitCity Varchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing
ORDER BY [UniqueID ]



Select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

Select
ParseName(Replace(OwnerAddress, ',', '.'), 3)
,ParseName(Replace(OwnerAddress, ',', '.'), 2)
,ParseName(Replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing



Alter Table NashvilleHousing
Add OwnerSplitAddress Varchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = ParseName(Replace(OwnerAddress, ',', '.'), 3)


Alter Table NashvilleHousing
Add OwnerSplitCity Varchar(255);

Update NashvilleHousing
Set PropertySplitCity = ParseName(Replace(OwnerAddress, ',', '.'), 2)



Alter Table NashvilleHousing
Add OwnerSplitState Varchar(255);

Update NashvilleHousing
Set OwnerSplitState = ParseName(Replace(OwnerAddress, ',', '.'), 1)

---Change Y and N to Yes and NO in 'Sold as Vacant'

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldasVacant
, Case When SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldasVacant = Case When SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	END

	--Remove Duplicates
With RowNumCTE AS(
Select *,
ROW_NUMBER () OVER(
Partition by ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			Order by 
			UniqueID
			)row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Delete
From RowNumCTE
where RoW_Num > 1
--order by PropertyAddress



-- Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing


Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress,SaleDate

