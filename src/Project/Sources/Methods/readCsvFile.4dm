//%attributes = {"invisible":true,"preemptive":"capable"}
/**
* 郵便番号CSVファイルを読み込み
*
* folder引数で指定されたフォルダーにある
* 以下のファイルを順番に読み込む。
* KEN_ALL.CSV
* DEL_yymm.CSV
* ADD_yymm.CSV
* JIGYOSYO.CSV
* JDELyymm.CSV
* JADDyymm.CSV
* 読み込んだファイルは削除する
* 
* @param {Object} $1 ファイルが格納されているフォルダーオブジェクト
* @author HARADA Koichi
*/

C_OBJECT:C1216($1;$folder_o)

C_COLLECTION:C1488($files_c)
C_OBJECT:C1216($file_o;$result_o)
C_TEXT:C284($filename_t)

ASSERT:C1129(OB Instance of:C1731($1;4D:C1709.Folder))

$folder_o:=$1

Case of 
	: ($folder_o.exists=False:C215)
		
		
	Else 
		
		$files_c:=New collection:C1472()
		$files_c:=$folder_o.files(fk ignore invisible:K87:22)
		$files_c.sort("sortCsvFiles")
		
		For each ($file_o;$files_c)
			
			$filename_t:=$file_o.name
			$result_o:=New object:C1471()
			
			Case of 
				: ($filename_t="KEN_ALL") | ($filename_t="DEL_@") | ($filename_t="ADD_@")
					
					$result_o:=readGeneralCsvFile ($file_o)
					
				: ($filename_t="JIGYOSYO") | ($filename_t="JDEL@") | ($filename_t="JADD@")
					
					$result_o:=readOfficeCsvFile ($file_o)
					
			End case 
			
			If ($result_o.success)
				
				$file_o.delete()
				
			End if 
			
		End for each 
		
End case 
