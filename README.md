# PSauditAD

Script Powershell d'audit d'un annuaire Active Directory.

La configuration s'effectue dans le fichier PSauditAD.ini :
```ini
[Config]
DelaiConnexionCompte=90
DelaiExpirationCompte=10
DelaiConnexionOrdinateurs=90
OUUtilisateurs="OU=Paris,OU=Utilisateurs,DC=domaine,DC=lan","OU=Lyon,OU=Utilisateurs,DC=domaine,DC=lan"

[Alertes]
ServeurSMTP=smtp.domaine.lan
Expediteur=psauditad@domaine.lan
Destinataires=auditeur@domaine.lan
```
