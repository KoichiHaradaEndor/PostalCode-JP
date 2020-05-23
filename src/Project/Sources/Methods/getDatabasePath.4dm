//%attributes = {"invisible":true,"preemptive":"capable"}
C_TEXT:C284($0;$extDatabasePath_t)

C_OBJECT:C1216($folder_o)

$folder_o:=Folder:C1567(fk resources folder:K87:11).folder("zipCodesDB")
$folder_o.create()

$extDatabasePath_t:=$folder_o.file("zipCodeDB").platformPath

$0:=$extDatabasePath_t
