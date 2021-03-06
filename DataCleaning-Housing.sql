use learning;
-- Converted SaleDate from text to date datatype
SELECT 
  SaleDate, 
  STR_TO_DATE(saledate, '%M %d, %Y') AS date 
FROM 
  nashvillehousing;
UPDATE 
  nashvillehousing 
SET 
  SaleDate = STR_TO_DATE(saledate, '%M %d, %Y');
alter table 
  nashvillehousing modify SaleDate date;

-- Populate Property Address
UPDATE 
  nashvillehousing 
SET 
  propertyaddress = NULL 
WHERE 
  propertyaddress = '';
SELECT 
  a.ParcelID, 
  a.PropertyAddress, 
  b.ParcelID, 
  b.PropertyAddress, 
  IFNULL(
    a.PropertyAddress, b.PropertyAddress
  ) 
FROM 
  nashvillehousing a 
  JOIN nashvillehousing b ON a.ParcelID = b.ParcelID 
  AND a.UniqueID <> b.UniqueID 
WHERE 
  a.PropertyAddress IS NULL;
UPDATE 
  nashvillehousing a 
  JOIN nashvillehousing b ON a.ParcelID = b.ParcelID 
  AND a.UniqueID <> b.UniqueID 
SET 
  a.PropertyAddress = IFNULL(
    a.PropertyAddress, b.PropertyAddress
  ) 
WHERE 
  a.PropertyAddress IS NULL;

-- Separating Property Address into Address and City using subtring and position
SELECT 
  SUBSTRING(
    PropertyAddress, 
    1, 
    POSITION(',' IN PropertyAddress) -1
  ) AS Address_of_Property, 
  SUBSTRING(
    PropertyAddress, 
    POSITION(',' IN PropertyAddress) + 1, 
    CHAR_LENGTH(PropertyAddress)
  ) AS PropertyCity 
FROM 
  nashvillehousing;
alter table 
  nashvillehousing 
add 
  Address_of_Property varchar(255);
alter table 
  nashvillehousing 
add 
  PropertyCity varchar(255);
UPDATE 
  nashvillehousing 
SET 
  Address_of_Property = SUBSTRING(
    PropertyAddress, 
    1, 
    POSITION(',' IN PropertyAddress) -1
  );
UPDATE 
  nashvillehousing 
SET 
  PropertyCity = SUBSTRING(
    PropertyAddress, 
    POSITION(',' IN PropertyAddress) + 1, 
    CHAR_LENGTH(PropertyAddress)
  );

-- Separating Owner Address into Address, City and State using substring_index
SELECT 
  SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Owner_Address, 
  SUBSTRING_INDEX(
    SUBSTRING_INDEX(OwnerAddress, ',', 2), 
    ',', 
    -1
  ) AS Owner_City, 
  SUBSTRING_INDEX(OwnerAddress, ',', -1) AS Owner_State 
FROM 
  nashvillehousing;
alter table 
  nashvillehousing 
add 
  Owner_Address varchar(255);
alter table 
  nashvillehousing 
add 
  Owner_City varchar(255);
alter table 
  nashvillehousing 
add 
  Owner_State varchar(255);
UPDATE 
  nashvillehousing 
SET 
  Owner_Address = SUBSTRING_INDEX(OwnerAddress, ',', 1);
UPDATE 
  nashvillehousing 
SET 
  Owner_City = SUBSTRING_INDEX(
    SUBSTRING_INDEX(OwnerAddress, ',', 2), 
    ',', 
    -1
  );
UPDATE 
  nashvillehousing 
SET 
  Owner_State = SUBSTRING_INDEX(OwnerAddress, ',', -1);

-- Modificatin for SoldAsVacant: Y to Yes and N to No
SELECT 
  DISTINCT (soldasvacant), 
  COUNT(SoldAsVacant) 
FROM 
  nashvillehousing 
GROUP BY 
  1 
ORDER BY 
  2;
SELECT 
  SoldAsVacant, 
  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' WHEN SoldAsVacant = 'N' THEN 'No' ELSE SoldAsVacant END 
FROM 
  nashvillehousing;
UPDATE 
  nashvillehousing 
SET 
  SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' WHEN SoldAsVacant = 'N' THEN 'No' ELSE SoldAsVacant END;

-- Remove duplicates using row_number
delete from 
  nashvillehousing 
where 
  UniqueID in(
    select 
      uniqueid 
    from 
      (
        select 
          uniqueid, 
          row_number() over (
            partition by parcelid, 
            saledate, 
            legalreference 
            order by 
              parcelid, 
              saledate, 
              legalreference
          ) as row_num 
        from 
          nashvillehousing
      ) t 
    where 
      row_num > 1
  );
