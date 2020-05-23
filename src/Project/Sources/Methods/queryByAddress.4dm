//%attributes = {"invisible":true,"preemptive":"capable"}
/**
* 住所・所在地をキーにして郵便番号を前方一致検索する
*
* @param {Text} $1 検索する住所・所在地
* @return {Collection} $0 検索結果
*/

C_TEXT:C284($1;$address_t)
C_COLLECTION:C1488($0;$result_c)

C_TEXT:C284($extDatabasePath_t)

$address_t:=$1+"%"

$extDatabasePath_t:=getDatabasePath 

ARRAY TEXT:C222($postalCode_at;0)
ARRAY TEXT:C222($prefecture_at;0)
ARRAY TEXT:C222($city_at;0)
ARRAY TEXT:C222($town_at;0)
ARRAY TEXT:C222($block_at;0)
ARRAY TEXT:C222($officeName_at;0)

Begin SQL
	
	USE DATABASE DATAFILE :$extDatabasePath_t;
	SELECT 
	POSTAL_CODE, PREFECTURE, CITY, TOWN, BLOCK, OFFICE_NAME
	FROM POSTAL_CODES 
	WHERE (POSTAL_CODES.ADDRESS LIKE :$address_t) 
	AND (POSTAL_CODES.REMOVED = false)
	INTO :$postalCode_at, :$prefecture_at, :$city_at, :$town_at, :$block_at, :$officeName_at;
	
End SQL

$result_c:=New collection:C1472()
ARRAY TO COLLECTION:C1563($result_c;\
$postalCode_at;"postalCode";\
$prefecture_at;"prefecture";\
$city_at;"city";\
$town_at;"town";\
$block_at;"block";\
$officeName_at;"office"\
)

$0:=$result_c
