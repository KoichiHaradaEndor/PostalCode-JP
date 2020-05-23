//%attributes = {"invisible":true,"preemptive":"capable"}
/**
* 所定のフォルダー内にあるCSVファイルを下記の順に並び替える
* KEN_ALL.CSV
* DEL_yymm.CSV
* ADD_yymm.CSV
* JIGYOSYO.CSV
* JDELyymm.CSV
* JADDyymm.CSV
*
* @author HARADA Koichi
*/

C_OBJECT:C1216($1)

C_OBJECT:C1216($file1_o;$file2_o)
C_TEXT:C284($filename1_t;$filename2_t)

$file1_o:=$1.value
$file2_o:=$1.value2

$filename1_t:=$file1_o.name
$filename2_t:=$file2_o.name

Case of 
	: ($filename1_t="KEN_ALL")
		
		$1.result:=True:C214
		
	: ($filename2_t="KEN_ALL")
		
		$1.result:=False:C215
		
	: ($filename1_t="DEL_@")
		
		$1.result:=True:C214
		
	: ($filename2_t="DEL_@")
		
		$1.result:=False:C215
		
	: ($filename1_t="ADD_@")
		
		$1.result:=True:C214
		
	: ($filename2_t="ADD_@")
		
		$1.result:=False:C215
		
	: ($filename1_t="JIGYOSYO")
		
		$1.result:=True:C214
		
	: ($filename2_t="JIGYOSYO")
		
		$1.result:=False:C215
		
	: ($filename1_t="JDEL@")
		
		$1.result:=True:C214
		
	: ($filename2_t="JDEL@")
		
		$1.result:=False:C215
		
	: ($filename1_t="JADD@")
		
		$1.result:=True:C214
		
	: ($filename2_t="JADD@")
		
		$1.result:=False:C215
		
End case 
