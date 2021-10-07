#--------------------------------------------
#
# Nom : PSauditAD.ps1
# Date : 07/10/2021
# Auteur : Loïc RAYMOND 
# 
#--------------------------------------------

import-module ActiveDirectory
$Emplacement = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
cd $Emplacement

$EncodageMail = [System.Text.Encoding]::UTF8

# Récupération des paramètres dans le fichier INI
$FichierINI = "PSauditAD.ini"
$Parametres = .\modules\Parametres.ps1
$DateActuelle = Get-Date -Format "dd/MM/yyyy"
$DelaiConnexion = (Get-Date).AddDays(-($Parametres.Config.DelaiConnexionCompte))
$DelaiOrdinateurs = (Get-Date).AddDays(-($Parametres.Config.DelaiConnexionOrdinateurs))
$DelaiExpiration = (Get-Date).AddDays($Parametres.Config.DelaiExpirationCompte).ToString('yyyyMMdd')
$Destinataires = $Parametres.Alertes.Destinataires.split(",")
$OUutilisateurs = @()
$OUutilisateurs = @( ($Parametres.Config.OUUtilisateurs) -split '","') -replace '"',''

# Création du corps du message
$MsgCorps = ("<html><head><meta charset='utf-8'><style>body{font-family:Arial, Helvetica, sans-serif; font-size:12px;} table{border:1px; border-collapse:collapse; width:100%;} h1{color:#008fd3} h2{color:#6c6b6a} table tbody tr td{border:1px solid #444; padding:5px;} table thead tr{background:#008fd3;} table thead tr th{border:1px solid #444; color:#fff; padding:5px;}</style></head>")
$MsgCorps += ("<body><h1>PSauditAD</h1>")


#
# Utilisateurs avec l'attribut NOTREQ_PWD (mot de passe non-requis)
#
$usersWithNoPwdRequired = Get-ADUser -Filter {Enabled -eq $True -and userAccountControl -eq "544"} -Properties *

If($usersWithNoPwdRequired -ne $NULL)
{
    Write-Host "Des utilisateurs possèdent l'attribut NOTREQ_PWD" -ForegroundColor red
    $MsgCorps += "<h2>Utilisateurs avec l'attribut NOTREQ_PWD</h2><table><thead><tr><th>Utilisateur</th><th>Identifiant</th></tr></thead><tbody>"
    foreach($user in $usersWithNoPwdRequired )
    {  
        $MsgCorps += ("<tr><td>"+$user.cn+"</td><td>"+$user.sAMAccountName+"</td></tr>")
    }
    $MsgCorps += "</tbody></table>"
}

#
# Utilisateurs non connectés depuis X jours
# 
$MsgCorps += "<h2>Utilisateurs non connectés depuis "+($Parametres.Config.DelaiConnexionCompte)+" jours</h2><table><thead><tr><th>Utilisateur</th><th>Identifiant</th><th>Date de dernière connexion</th></tr></thead><tbody>"

$OUutilisateurs | ForEach-Object{
    $Utilisateurs = Get-ADUser -SearchBase $_ -Filter {Enabled -eq $True -and LastLogonTimeStamp -lt $DelaiConnexion} -Properties Name, LastLogonTimestamp, displayName, physicalDeliveryOfficeName

    If($Utilisateurs -ne $NULL)
    {
        Foreach($Utilisateur in $Utilisateurs)
        {
            $DateConnexion = [DateTime]::FromFileTime($Utilisateur.LastLogonTimeStamp).ToString('dd/MM/yyyy')
            $UtilisateurLogin = $Utilisateur.sAMAccountName
            $UtilisateurNom = $Utilisateur.displayName

            $MsgCorps += ("<tr><td>"+$UtilisateurNom+"</td><td>"+$UtilisateurLogin+"</td><td>"+$DateConnexion+"</td></tr>")
        }
    }
}
$MsgCorps += "</tbody></table>"

#
# Utilisateurs dont le mot de passe n'expire jamais
# 
     
$OUutilisateurs | ForEach-Object{
    $Utilisateurs = Get-ADUser -SearchBase $_ -Filter {Enabled -eq $True -and passwordNeverExpires -eq "True"} -Properties *

    If($Utilisateurs -ne $NULL)
    {
        Write-Host "Des utilisateurs possède l'attribut `"Le mot de passe n'expire jamais`"" -Foregroundcolor Red
        $MsgCorps += "<h2>Utilisateurs dont le mot de passe n'expire jamais</h2><table><thead><tr><th>Utilisateur</th><th>Identifiant</th></tr></thead><tbody>"
        foreach($user in $Utilisateurs)
        {  
            $MsgCorps += ("<tr><td>"+$user.cn+"</td><td>"+$user.sAMAccountName+"</td></tr>")
        }
        
        $MsgCorps += "</tbody></table>"
    }
}


#
# Utilisateurs dont le compte est expiré ou arrive à expiration
# 
$OUutilisateurs | ForEach-Object{
    $Utilisateurs = Get-ADUser -SearchBase $_ -Filter {Enabled -eq $True -and AccountExpirationDate -ne "<Never>"} -Properties Name, accountExpires, displayName
    
    If($Utilisateurs -ne $NULL)
    {
        
        Foreach($Utilisateur in $Utilisateurs)
        {
        
            $DateExpiration = [DateTime]::FromFileTime($Utilisateur.accountExpires).ToString('dd/MM/yyyy')
            $DateLimite = [DateTime]::FromFileTime($Utilisateur.accountExpires).ToString('yyyyMMdd')
            $UtilisateurLogin = $Utilisateur.sAMAccountName
            $UtilisateurNom = $Utilisateur.displayName

            If($DateLimite -lt $DelaiExpiration)
            {
                $MsgcompteExpire += ("<tr><td>"+$UtilisateurNom+"</td><td>"+$UtilisateurLogin+"</td><td>"+$DateExpiration+"</td></tr>")
                $ComptesExpire = 1
            }
        }
        

        If($MsgcompteExpire -eq 1)
        {
            $MsgCorps += "<h2>Comptes expirés ou arrivant à expiration dans moins de "+($Parametres.Config.DelaiExpirationCompte)+" jours</h2><table><thead><tr><th>Utilisateur</th><th>Identifiant</th><th>Date d'expiration</th></tr></thead><tbody>"
            $MsgCorps += $MsgCompteExpire
            $MsgCorps += "</tbody></table>" 
            Write-Host "Des comptes sont expirés ou arrivent à expiration" -ForegroundColor Green
        }
        Else
        {
            Write-Host "Aucun compte n'est expiré ou arrive à expiration" -ForegroundColor Green
        }
    }
}



#
# Utilisateurs administrateurs
# 
$usersAdmin = Get-ADUser -Filter {Enabled -eq $True -and adminCount -eq "1"} -Properties *
If($usersAdmin -ne $NULL)
{
    $MsgCorps += "<h2>Utilisateurs administrateurs</h2><table><thead><tr><th>Utilisateur</th><th>Identifiant</th></tr></thead><tbody>"
    
    foreach($user in $usersAdmin)
    {  
        $MsgCorps += ("<tr><td>"+$user.cn+"</td><td>"+$user.sAMAccountName+"</td></tr>")
    }
    $MsgCorps += "</tbody></table>"
}



#
# Ordinateurs inactifs depuis X jours
# 
$OrdinateursInactifs = Get-ADComputer -Filter {LastLogonTimeStamp -lt $DelaiOrdinateurs} -Properties *
If($OrdinateursInactifs -ne $NULL)
{
    $MsgCorps += ("<h2>Ordinateurs non connecté depuis "+($Parametres.Config.DelaiConnexionOrdinateurs)+" jours</h2><table><thead><tr><th>Nom d'hôte</th><th>Système d'exploitation</th><th>Date de dernière connexion</th></tr></thead><tbody>")
    foreach($ordinateur in $OrdinateursInactifs)
    {  
        $MsgCorps += ("<tr><td>"+$ordinateur.name+"</td><td>"+$ordinateur.OperatingSystem+"</td><td>"+$ordinateur.LastLogonDate+"</td></tr>")
    }
    $MsgCorps += "</tbody></table>"  
}




# FIN

$MsgCorps += "<div style=`"margin-top:50px; color:#888; font-size:10px;`">Développé par <b>Loïc RAYMOND</b> - Code Source disponible : <a href=`"https://github.com/loicraymond/PSauditAD\`">https://github.com/loicraymond/PSauditAD</a></div></body></html>"

# Envoi du rapport au format HTML
Send-MailMessage -To @($Destinataires) -Subject ("PSauditAD : Rapport du "+$DateActuelle) -bodyashtml -body $MsgCorps -from ($Parametres.Alertes.Expediteur) -SmtpServer ($Parametres.Alertes.ServeurSMTP) -Encoding $EncodageMail
