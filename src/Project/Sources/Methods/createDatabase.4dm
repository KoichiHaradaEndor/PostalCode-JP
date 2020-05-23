//%attributes = {"invisible":true,"preemptive":"capable"}
/**
* エクスターナルデータベースを作成
* 郵便番号データを格納する外部データベースを
* 作成します。
* 作成後はSQLを使用してデータの書き込み・読み出しを行います。
*
* @author HARADA Koichi
*/

C_OBJECT:C1216($0;$error_o)

C_TEXT:C284($extDatabasePath_t;$errorHandler_t)
C_COLLECTION:C1488($error_c)

$errorHandler_t:=error_try 
$extDatabasePath_t:=getDatabasePath 

  // データベース作成
Begin SQL
	
	CREATE DATABASE IF NOT EXISTS DATAFILE <<$extDatabasePath_t>>;
	
	USE DATABASE DATAFILE <<$extDatabasePath_t>>;
	
	CREATE TABLE IF NOT EXISTS POSTAL_CODES (
	ID INT AUTO_INCREMENT PRIMARY KEY,
	CODE VARCHAR,
	OLD_POSTAL_CODE VARCHAR,
	POSTAL_CODE VARCHAR,
	PREFECTURE_KANA VARCHAR,
	CITY_KANA VARCHAR,
	TOWN_KANA VARCHAR,
	PREFECTURE VARCHAR,
	CITY VARCHAR,
	TOWN VARCHAR,
	BLOCK VARCHAR,
	ADDRESS VARCHAR,
	OFFICE_NAME VARCHAR,
	OFFICE_NAME_KANA VARCHAR,
	IS_GENERAL BOOLEAN,
	IS_OFFICE BOOLEAN,
	REMOVED BOOLEAN
	);
	
End SQL

  // インデックス作成
ARRAY TEXT:C222($indexNames_at;0)
Begin SQL
	
	USE DATABASE DATAFILE <<$extDatabasePath_t>>;
	SELECT INDEX_NAME FROM _USER_INDEXES INTO :$indexNames_at;
	
End SQL

If (Find in array:C230($indexNames_at;"POSTAL_CODE_INDEX")=-1)
	
	Begin SQL
		
		USE DATABASE DATAFILE <<$extDatabasePath_t>>;
		CREATE INDEX POSTAL_CODE_INDEX ON POSTAL_CODES (POSTAL_CODE);
		
	End SQL
	
End if 

If (Find in array:C230($indexNames_at;"ADDRESS_INDEX")=-1)
	
	Begin SQL
		
		USE DATABASE DATAFILE <<$extDatabasePath_t>>;
		CREATE INDEX ADDRESS_INDEX ON POSTAL_CODES (ADDRESS);
		
	End SQL
	
End if 

$error_c:=New collection:C1472()
$error_o:=New object:C1471()
$error_o.success:=True:C214
$error_o.message:=""

If (error_catch ($errorHandler_t))
	
	$error_o.success:=False:C215
	
	$error_c:=error_get 
	If ($error_c.length>0)
		
		$error_o.message:=$error_c[0].message
		
	End if 
	
End if 

$0:=$error_o
