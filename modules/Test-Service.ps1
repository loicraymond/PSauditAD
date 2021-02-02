$NbRelance = 0

Function TestSvc()
{
    If((Get-Service -Name $Service -ErrorAction SilentlyContinue).Status -eq "Stopped")
    {
		# Je vérifie si le reboot a déjà été effectué
        If((Test-Path "C:\temp\reboot.txt") -eq $False)
        {
            # Je lance le service
            Start-Service -Name $Service
            
            # J'attend 10 secondes
            Start-Sleep 10

            # J'incrémente le compteur de relances du service 
            $NbRelance++

            # Je test si le service a déjà été relancé
            If($NbRelance -gt 1)
            {
				# Je créé le fichier indiquant le reboot
                New-Item -Path "C:\temp\" -Name "reboot.txt" -ItemType file -Value "reboot date"
				
				# J'attend 5 secondes
                Start-Sleep 5

                #Je redémarre l'ordinateur
                Restart-Computer -Force
            }
            Else
            {
                #Je relance le test
                TestSvc
            }
        }
        
    }
    ElseIf((Get-Service -Name $Service -ErrorAction SilentlyContinue).Status -eq "Running")
    {
        # Je teste si le fichier existe et le supprime le cas échéant
        If((Test-Path "C:\Temp\reboot.txt") -eq $True)
        {
            Remove-Item -Path "C:\Temp\reboot.txt" -Force
        }
		
    }
	
	# Je retourne le nom et statut du service Airlan
	return ("Airlan;"+(Get-Service -Name $Service -ErrorAction SilentlyContinue).Status)
}

# PROGRAMME
TestSvc
