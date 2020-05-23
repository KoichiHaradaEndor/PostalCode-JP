//%attributes = {"invisible":true,"preemptive":"capable"}
/**
* 郵便番号をキーにして住所・所在地を前方一致検索する
*
* @param {Text} $1 検索する郵便番号
* @return {Collection} $0 検索結果
*/

C_TEXT:C284($1;$postalCode_t)
C_COLLECTION:C1488($0;$result_c)

C_TEXT:C284($extDatabasePath_t)

$postalCode_t:=$1

$postalCode_t:=Replace string:C233($postalCode_t;"０";"0")
$postalCode_t:=Replace string:C233($postalCode_t;"１";"1")
$postalCode_t:=Replace string:C233($postalCode_t;"２";"2")
$postalCode_t:=Replace string:C233($postalCode_t;"３";"3")
$postalCode_t:=Replace string:C233($postalCode_t;"４";"4")
$postalCode_t:=Replace string:C233($postalCode_t;"５";"5")
$postalCode_t:=Replace string:C233($postalCode_t;"６";"6")
$postalCode_t:=Replace string:C233($postalCode_t;"７";"7")
$postalCode_t:=Replace string:C233($postalCode_t;"８";"8")
$postalCode_t:=Replace string:C233($postalCode_t;"９";"9")
$postalCode_t:=$postalCode_t+"%"

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
	WHERE (POSTAL_CODES.POSTAL_CODE LIKE :$postalCode_t) 
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
