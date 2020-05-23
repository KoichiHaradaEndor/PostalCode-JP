//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
/**
* コンポーネントメソッドとして公開するメソッド
*
*/

C_OBJECT:C1216($0;$this_o)

$this_o:=New object:C1471()

$this_o.queryByCode:=Formula:C1597(queryByCode )
$this_o.queryByAddress:=Formula:C1597(queryByAddress )
$this_o.update:=Formula:C1597(readCsvFile )
$this_o.webServer:=Formula:C1597(webServer )
$this_o.webQueryByCode:=Formula:C1597(webQueryByCode )
$this_o.webQueryByAddress:=Formula:C1597(webQueryByAddress )

$0:=$this_o
