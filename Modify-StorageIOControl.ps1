# Datastores a ne pas prendre en compte, dans mon exemple tous les datastore locaux dont le nom contient "LOCAL"
$exclude = "*LOCAL*"

# Liste des datastores sur lesquels on travaille
$datastores = Get-Datastore | ? {$_.name -like "*PA*" -and $_.name -notlike $exclude}

# Seuil de latence manuel en millisecondes pour SIOC; From 10 to 100 ; Default is 30
$threshold = 10

# Seuil de latence auto en pourcentage pour SIOC; From 0 to 100 ; Default is 90
$thresholdauto = 80

# fonction pour verifier si SIOC est active ou pas
function Get-SIOC-Status () {
	$tableau = @()

	foreach($ds in $datastores){
		
		# Création d'un objet pour stocker le résultat du DS en cours d'analyse
		$Object = new-object PSObject
		
		# Ajout du champ "DS Name" dans l'objet
		$Object | add-member -name "DS Name" -membertype Noteproperty -value $ds.Name
		
		# Ajout du champ "SIOC Enabled ?" dans l'objet
		$Object | add-member -name "SIOC Enabled" -membertype Noteproperty -value $ds.StorageIOControlEnabled
		
		# Ajout du champ "Congestion Threshold Mode" dans l'objet
		$Object | add-member -name "SIOC Mode" -membertype Noteproperty -value $ds.Extensiondata.iormConfiguration.CongestionThresholdMode
		
		# Ajout du champ "Congestion Threshold Millisecond" dans l'objet
		#$Object | add-member -name "Manual(ms)" -membertype Noteproperty -value $ds.CongestionThresholdMillisecond
		
		# Ajout du champ "Congestion Percent Of Peak Throughput" dans l'objet
		$Object | add-member -name "Threshold(%)" -membertype Noteproperty -value $ds.Extensiondata.iormConfiguration.PercentOfPeakThroughput
		
		# Ajout de l'objet dans le tableau
		$tableau += $Object
		
	}
	# Affichage des résultat
	echo $tableau | Sort-Object -Property "DS Name"
}


# fonction pour activer SIOC
function Enable-SIOC () {
	foreach($ds in $datastores){
		#Set-Datastore $ds -StorageIOControlEnabled $true -CongestionThresholdMillisecond $threshold
		Set-Datastore $ds -StorageIOControlEnabled $true
	}
}

# fonction pour désactiver SIOC
function Disable-SIOC () {
	foreach($ds in $datastores){
		Set-Datastore $ds -StorageIOControlEnabled $false
	}
}

# Enable-SIOC
#Disable-SIOC
Get-SIOC-Status
