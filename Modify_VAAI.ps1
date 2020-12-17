# Donner le nom du cluster ou liste de serveurs ESXi
$CLUS = "Cluster-Name"
$ESXs = Get-Cluster -Name $CLUS | Get-VMHost


# Creer une fonction pour recuperer les valeurs des VAAI
Function Get_VAAI (){
	# Recuperation des primitives ATS et XCOPY
	$valATS = Get-Cluster -Name $CLUS | Get-VMHost | Get-AdvancedSetting -Name VMFS3.UseATSForHBOnVMFS5
	$valXCOPY = Get-Cluster -Name $CLUS | Get-VMHost | Get-AdvancedSetting -Name DataMover.HardwareAcceleratedMove
	$valLocking = Get-Cluster -Name $CLUS | Get-VMHost | Get-AdvancedSetting -Name VMFS3.HardwareAcceleratedLocking
	$valInit = Get-Cluster -Name $CLUS | Get-VMHost | Get-AdvancedSetting -Name DataMover.HardwareAcceleratedInit

	# Creation d'un tableau
	$tableau =@()

	# Remplissage du tableau
	for($i = 0; $i -lt $ESXs.count; $i++){
		#echo $esx[$i].Name $valATS[$i].value $valXCOPY[$i].value
		$esx = $ESXs[$i].Name -replace '.vincic-fr.grpsc.net',''
		$Object = new-object PSObject
		 
		$Object | add-member -name "ESXi Name" -membertype Noteproperty -value $esx
		$Object | add-member -name "ATS Heartbeat" -membertype Noteproperty -value $valATS[$i].value
		$Object | add-member -name "XCOPY-MOVE" -membertype Noteproperty -value $valXCOPY[$i].value
		$Object | add-member -name "Locking" -membertype Noteproperty -value $valLocking[$i].value
		$Object | add-member -name "Init" -membertype Noteproperty -value $valInit[$i].value
		
		$tableau += $Object 
	}

	# Affichage des resultats
	echo $tableau | ft -autosize
}



Function Disable_VAAI (){
	# desactivation de ATS Heartbeat
	$ESXs | Get-AdvancedSetting -Name VMFS3.UseATSForHBOnVMFS5 | Set-AdvancedSetting -Value 0 -Confirm:$false
	
	# desactivation de XCOPY
	$ESXs | Get-AdvancedSetting -Name DataMover.HardwareAcceleratedMove | Set-AdvancedSetting -Value 0 -Confirm:$false
	
}

Function Enable_VAAI (){
	# Desactivation de ATS Heartbeat
	$ESXs | Get-AdvancedSetting -Name VMFS3.UseATSForHBOnVMFS5 | Set-AdvancedSetting -Value 1 -Confirm:$false
	
	# Desactivation de XCOPY
	$ESXs | Get-AdvancedSetting -Name DataMover.HardwareAcceleratedMove | Set-AdvancedSetting -Value 1 -Confirm:$false
	
}

# Disable_VAAI
#Enable_VAAI
Get_VAAI
