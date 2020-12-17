# Chemin du repertoire de destination
$path = "C:\Export\Snapshot"

$VMsList = get-vm
$tableau = @()
foreach($vm in $VMsList){
	$snaplist = $vm | get-snapshot
	
	foreach($snap in $snaplist){
		$snapsize = [MATH]::Round($snap.SizeGB,0)
		
		# On stocke le nom de la VM et la valeur de l'attribut dans le tableau		
		$Object = new-object PSObject
		$Object | add-member -name "VMName" -membertype Noteproperty -value $vm.Name
		$Object | add-member -name "SnapshotCreationDate" -membertype Noteproperty -value $snap.Created
		$Object | add-member -name "SnapshotSizeGB" -membertype Noteproperty -value $snapsize
		
        $tableau += $Object
	}
}
echo $tableau | Sort-Object -Property SnapshotCreationDate | ft

#### EXPORTS DU FICHIER CSV
# Nom du fichier final
$CSVfilename = "Snapshot_Report_" + (Get-Date -Format "yyyy-MM-dd") + ".csv"
write-host "Export du fichier CSV: $CSVfilename" -foregroundcolor "green"
$out = $path + "\" + $CSVfilename
$tableau | Sort-Object -Property SnapshotCreationDate | Export-csv -Path $out -NoTypeInformation