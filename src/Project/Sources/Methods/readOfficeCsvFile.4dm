//%attributes = {"invisible":true,"preemptive":"capable"}
/**
* 郵便番号データCSVを読み込み
*
* データは以下のサイトからダウンロード
* https://www.post.japanpost.jp/zipcode/dl/jigyosyo/index-zip.html
* まずjigyosho.csvを読み込み、あとは廃止データと新規追加データを
* 随時読み込めば良い。ただし廃止=>新規の順に読むこと。
* これは同じ郵便番号をいったん廃止してから同時に復活することが
* 行われるから。
*
* #########################################################
* 読み込みルール
* 同じ郵便番号が二行に渡るデータは町域データを連結してひとつとする
*
* #########################################################
* データ構造の説明
* https://www.post.japanpost.jp/zipcode/dl/jigyosyo/readme.html
*
* 抜粋
* 0. 大口事業所の所在地のJISコード（5バイト）
* 1. 大口事業所名（カナ）（100バイト）
* 2. 大口事業所名（漢字）（160バイト）
* 3. 都道府県名（漢字）（8バイト）
* 4. 市区町村名（漢字）（24バイト）
* 5. 町域名（漢字）（24バイト）
* 6. 小字名、丁目、番地等（漢字）（124バイト）
* 7. 大口事業所個別番号（7バイト）
* 8. 旧郵便番号（5バイト）
* 9. 取扱局（漢字）（40バイト）
* 10. 個別番号の種別の表示（1バイト）
*     「0」大口事業所、「1」私書箱
* 11. 複数番号の有無（1バイト）
*     「0」複数番号無し「1」複数番号を設定している場合の個別番号の1
*     「2」複数番号を設定している場合の個別番号の2
*     「3」複数番号を設定している場合の個別番号の3
*     一つの事業所が同一種別の個別番号を複数持つ場合に複数番号を設定しているものとします。
*     従って、一つの事業所で大口事業所、私書箱の個別番号をそれぞれ一つづつ設定している場合は 12）は「0」となります。
* 12. 修正コード（1バイト）
*     「0」修正なし、「1」新規追加、「5」廃止
*
* #########################################################
* シンタックス
* result readOfficeCsvFile(path)
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
C_LONGINT:C283($numFound_l)
C_TEXT:C284($code_t;$oldPostalCode_t;$postalCode_t)
C_TEXT:C284($prefecture_t;$city_t;$town_t)
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
					: ($currentLine_c.length<13)
						
						  // 最後の行を読んだ
						If ($previousLine_c.length>=13)
							
							  // 前行が残っているので処理
							$processLine_c:=$previousLine_c.copy()
							
						End if 
						
					: ($previousLine_c.length<13)
						
						  // 前行が存在しないので、現在行を前行にして続行
						$previousLine_c:=$currentLine_c.copy()
						$currentLine_c:=New collection:C1472()
						
					: ($currentLine_c[7]=$previousLine_c[7])
						
						  // 前行と現在行の郵便番号が一緒なので
						  // 前行と現在行の町域を連結し、現在行を初期化
						$previousLine_c[6]:=$previousLine_c[6]+$currentLine_c[6]
						$currentLine_c:=New collection:C1472()
						
					Else 
						
						  // 前行と現在行の郵便番号が異なるので
						  // 前行を処理し、現在行を前行にする
						$processLine_c:=$previousLine_c.copy()
						$previousLine_c:=$currentLine_c.copy()
						$currentLine_c:=New collection:C1472()
						
				End case 
				
				  // 登録処理
				C_TEXT:C284($officeNameKana_t;$officeName_t;$block_t)
				
				If ($processLine_c.length>=13)
					
					$code_t:=$processLine_c[0]
					$officeNameKana_t:=$processLine_c[1]
					$officeName_t:=$processLine_c[2]
					$prefecture_t:=$processLine_c[3]
					$city_t:=$processLine_c[4]
					$town_t:=$processLine_c[5]
					$block_t:=$processLine_c[6]
					$postalCode_t:=$processLine_c[7]
					$oldPostalCode_t:=$processLine_c[8]
					$removed_b:=($processLine_c[12]="5")
					
					  // 郵便番号の整形
					  // ダブルクォートを取り除く
					$code_t:=Replace string:C233($code_t;"\"";"")
					$officeNameKana_t:=Replace string:C233($officeNameKana_t;"\"";"")
					$officeName_t:=Replace string:C233($officeName_t;"\"";"")
					$prefecture_t:=Replace string:C233($prefecture_t;"\"";"")
					$city_t:=Replace string:C233($city_t;"\"";"")
					$town_t:=Replace string:C233($town_t;"\"";"")
					$block_t:=Replace string:C233($block_t;"\"";"")
					$postalCode_t:=Replace string:C233($postalCode_t;"\"";"")
					$oldPostalCode_t:=Replace string:C233($oldPostalCode_t;"\"";"")
					
					$address_t:=$prefecture_t+$city_t+$town_t+$block_t
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
							PREFECTURE,CITY,TOWN,BLOCK,ADDRESS,
							OFFICE_NAME,OFFICE_NAME_KANA,
							IS_GENERAL,IS_OFFICE,REMOVED) VALUES (
							:$code_t,:$oldPostalCode_t,:$postalCode_t,
							:$prefecture_t,:$city_t,:$town_t,:$block_t,:$address_t,
							:$officeName_t,:$officeNameKana_t,
							false,true,:$removed_b);
							
						End SQL
						
					Else 
						
						  // 対象郵便番号は登録済みなので、上書きする
						Begin SQL
							
							USE DATABASE DATAFILE :$extDatabasePath_t;
							UPDATE POSTAL_CODES SET 
							CODE=:$code_t,OLD_POSTAL_CODE=:$oldPostalCode_t,
							PREFECTURE=:$prefecture_t,CITY=:$city_t,TOWN=:$town_t,BLOCK=:$block_t,ADDRESS=:$address_t,
							OFFICE_NAME=:$officeName_t,OFFICE_NAME_KANA=:$officeNameKana_t,
							IS_GENERAL=false,IS_OFFICE=true,REMOVED=:$removed_b 
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
