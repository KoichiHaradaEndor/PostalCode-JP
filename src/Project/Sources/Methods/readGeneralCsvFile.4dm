//%attributes = {"invisible":true,"preemptive":"capable"}
/**
* 郵便番号データCSVを読み込み
*
* データは以下のサイトからダウンロード
* https://www.post.japanpost.jp/zipcode/dl/kogaki-zip.html
* まずken_all.csvを読み込み、あとは廃止データと新規追加データを
* 随時読み込めば良い。ただし廃止=>新規の順に読むこと。
* これは同じ郵便番号をいったん廃止してから同時に復活することが
* 行われるから。
*
* #########################################################
* 読み込みルール
* 同じ郵便番号が二行に渡るデータは町域データを連結してひとつとする
* 「（）括弧」に囲まれる町域データ部分は無視する
* 以下の町域データは空にする
* - 以下に掲載がない場合
* - 〜の次に番地がくる場合
* - 〜一円を取り除く（ただし滋賀県犬上郡多賀町一円を除く）
*
* #########################################################
* データ構造の説明
* https://www.post.japanpost.jp/zipcode/dl/readme.html
*
* 抜粋
* 0. 全国地方公共団体コード（JIS X0401、X0402）………　半角数字
* 1. （旧）郵便番号（5桁）………………………………………　半角数字
* 2. 郵便番号（7桁）………………………………………　半角数字
* 3. 都道府県名　…………　半角カタカナ（コード順に掲載）　（注1）
* 4. 市区町村名　…………　半角カタカナ（コード順に掲載）　（注1）
* 5. 町域名　………………　半角カタカナ（五十音順に掲載）　（注1）
* 6. 都道府県名　…………　漢字（コード順に掲載）　（注1,2）
* 7. 市区町村名　…………　漢字（コード順に掲載）　（注1,2）
* 8. 町域名　………………　漢字（五十音順に掲載）　（注1,2）
* 9. 一町域が二以上の郵便番号で表される場合の表示　（注3）　（「1」は該当、「0」は該当せず）
* 10. 小字毎に番地が起番されている町域の表示　（注4）　（「1」は該当、「0」は該当せず）
* 11. 丁目を有する町域の場合の表示　（「1」は該当、「0」は該当せず）
* 12. 一つの郵便番号で二以上の町域を表す場合の表示　（注5）　（「1」は該当、「0」は該当せず）
* 13. 更新の表示（注6）（「0」は変更なし、「1」は変更あり、「2」廃止（廃止データのみ使用））
* 14. 変更理由　（「0」は変更なし、「1」市政・区政・町政・分区・政令指定都市施行、
* 「2」住居表示の実施、「3」区画整理、「4」郵便区調整等、「5」訂正、「6」廃止（廃止データのみ使用））
*
* #########################################################
* シンタックス
* result readGeneralCsvFile(path)
*
* @param {Object} 読み込むCSVのファイルオブジェクト
* @return {Object} {"success":boolean, "message":"結果メッセージ"}
* @author HARADA Koichi
*/

C_OBJECT:C1216($1;$file_o)
C_OBJECT:C1216($0;$result_o)

C_TEXT:C284($path_t;$aLine_t;$extDatabasePath_t)
C_TIME:C306($docCsv_h)
C_COLLECTION:C1488($currentLine_c;$previousLine_c;$processLine_c)
C_LONGINT:C283($numFound_l;$position_l)
C_TEXT:C284($code_t;$oldPostalCode_t;$postalCode_t)
C_TEXT:C284($prefectureKana_t;$cityKana_t;$townKana_t)
C_TEXT:C284($prefecture_t;$city_t;$town_t;$address_t)
C_BOOLEAN:C305($removed_b;$stop_b)

ASSERT:C1129(OB Instance of:C1731($1;4D:C1709.File);"The first parameter must be a File object.")

$file_o:=$1
$result_o:=New object:C1471()
$result_o:=createDatabase 

Case of 
	: ($result_o.success=False:C215)
		
	: ($file_o.exists)
		
		$path_t:=$file_o.platformPath
		
		USE CHARACTER SET:C205("Windows-31J";1)
		$docCsv_h:=Open document:C264($path_t;Read mode:K24:5)
		If (OK=1)
			
			$currentLine_c:=New collection:C1472()
			$previousLine_c:=New collection:C1472()
			
			$stop_b:=False:C215
			Repeat 
				
				$processLine_c:=New collection:C1472()
				RECEIVE PACKET:C104($docCsv_h;$aLine_t;"\r\n")
				$stop_b:=(OK=0)
				$currentLine_c:=Split string:C1554($aLine_t;",";sk trim spaces:K86:2)
				
				  // $aLine_tが空であるかのテストを行ってはいけない
				  // 最終行を読み込んだら前行の処理がある
				Case of 
					: ($currentLine_c.length<15)
						
						  // 最後の行を読んだ
						If ($previousLine_c.length>=15)
							
							  // 前行が残っているので処理
							$processLine_c:=$previousLine_c.copy()
							
						End if 
						
					: ($previousLine_c.length<15)
						
						  // 前行が存在しないので、現在行を前行にして続行
						$previousLine_c:=$currentLine_c.copy()
						$currentLine_c:=New collection:C1472()
						
					: ($currentLine_c[2]=$previousLine_c[2])
						
						  // 前行と現在行の郵便番号が一緒なので
						  // 前行と現在行の町域を連結し、現在行を初期化
						$previousLine_c[5]:=$previousLine_c[5]+$currentLine_c[5]
						$previousLine_c[8]:=$previousLine_c[8]+$currentLine_c[8]
						$currentLine_c:=New collection:C1472()
						
					Else 
						
						  // 前行と現在行の郵便番号が異なるので
						  // 前行を処理し、現在行を前行にする
						$processLine_c:=$previousLine_c.copy()
						$previousLine_c:=$currentLine_c.copy()
						$currentLine_c:=New collection:C1472()
						
				End case 
				
				  // 登録処理
				
				If ($processLine_c.length>=15)
					
					$code_t:=$processLine_c[0]
					$oldPostalCode_t:=$processLine_c[1]
					$postalCode_t:=$processLine_c[2]
					$prefectureKana_t:=$processLine_c[3]
					$cityKana_t:=$processLine_c[4]
					$townKana_t:=$processLine_c[5]
					$prefecture_t:=$processLine_c[6]
					$city_t:=$processLine_c[7]
					$town_t:=$processLine_c[8]
					$removed_b:=($processLine_c[14]="6")
					
					  // 郵便番号の整形
					  // ダブルクォートを取り除く
					$oldPostalCode_t:=Replace string:C233($oldPostalCode_t;"\"";"")
					$postalCode_t:=Replace string:C233($postalCode_t;"\"";"")
					$prefectureKana_t:=Replace string:C233($prefectureKana_t;"\"";"")
					$cityKana_t:=Replace string:C233($cityKana_t;"\"";"")
					$townKana_t:=Replace string:C233($townKana_t;"\"";"")
					$prefecture_t:=Replace string:C233($prefecture_t;"\"";"")
					$city_t:=Replace string:C233($city_t;"\"";"")
					$town_t:=Replace string:C233($town_t;"\"";"")
					
					  // 以下に掲載がない場合、〜の次に番地がくる場合、〜一円を取り除く
					If ($town_t="@以下に掲載がない場合@")
						
						$townKana_t:=""
						$town_t:=""
						
					End if 
					
					If ($town_t="@の次に番地がくる場合@")
						
						$townKana_t:=""
						$town_t:=""
						
					End if 
					
					If ($postalCode_t#"5220317") & ($town_t="@一円@")
						
						  // 郵便番号5220317は滋賀県犬上郡多賀町一円なので消去しない
						$townKana_t:=""
						$town_t:=""
						
					End if 
					
					  // 町域のカッコは取り除く
					$position_l:=Position:C15("（";$town_t)
					If ($position_l>0)
						
						$town_t:=Substring:C12($town_t;1;$position_l-1)
						
					End if 
					
					$position_l:=Position:C15("(";$townKana_t)
					If ($position_l>0)
						
						$townKana_t:=Substring:C12($townKana_t;1;$position_l-1)
						
					End if 
					
					$address_t:=$prefecture_t+$city_t+$town_t
					$extDatabasePath_t:=getDatabasePath 
					Begin SQL
						
						USE DATABASE DATAFILE :$extDatabasePath_t;
						SELECT COUNT(*) FROM POSTAL_CODES WHERE POSTAL_CODES.POSTAL_CODE = :$postalCode_t INTO :$numFound_l;
						
					End SQL
					
					If ($numFound_l=0)
						
						  // 対象郵便番号はまだ登録されていないので、新規登録する
						Begin SQL
							
							USE DATABASE DATAFILE :$extDatabasePath_t;
							INSERT INTO POSTAL_CODES(CODE,OLD_POSTAL_CODE,POSTAL_CODE,
							PREFECTURE_KANA,CITY_KANA,TOWN_KANA,
							PREFECTURE,CITY,TOWN,ADDRESS,
							IS_GENERAL,IS_OFFICE,REMOVED) VALUES (
							:$code_t,:$oldPostalCode_t,:$postalCode_t,
							:$prefectureKana_t,:$cityKana_t,:$townKana_t,
							:$prefecture_t,:$city_t,:$town_t,:$address_t,
							true,false,:$removed_b);
							
						End SQL
						
					Else 
						
						  // 対象郵便番号は登録済みなので、上書きする
						Begin SQL
							
							USE DATABASE DATAFILE :$extDatabasePath_t;
							UPDATE POSTAL_CODES SET 
							CODE=:$code_t,OLD_POSTAL_CODE=:$oldPostalCode_t,
							PREFECTURE_KANA=:$prefectureKana_t,CITY_KANA=:$cityKana_t,TOWN_KANA=:$townKana_t,
							PREFECTURE=:$prefecture_t,CITY=:$city_t,TOWN=:$town_t,ADDRESS=:$address_t,
							IS_GENERAL=true,IS_OFFICE=false,REMOVED=:$removed_b 
							WHERE POSTAL_CODES.POSTAL_CODE = :$postalCode_t;
							
						End SQL
						
					End if 
					
				End if 
				
			Until ($stop_b)
			
			CLOSE DOCUMENT:C267($docCsv_h)
			
		Else 
			
			$result_o.success:=False:C215
			$result_o.message:="Could not open the file specified."
			
		End if 
		
		USE CHARACTER SET:C205(*;1)
		
	Else 
		
		$result_o.success:=False:C215
		$result_o.message:="The specified file does not exist."
		
End case 

$0:=$result_o
