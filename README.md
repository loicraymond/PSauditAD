# PSauditAD

Script Powershell d'audit d'un annuaire Active Directory.

## Configuration

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

**DelaiConnexionCompte** : Délai de connexion au domaine d'un compte utilisateur (en jours)

**DelaiExpirationCompte** : Délai d'expiration d'un compte utilisateur (en jours)

**DelaiConnexionOrdinateurs** : Délai de connexion au domaine d'un ordinateur (en jours)

**OUUtilisateurs** : Liste des OU contenant les comptes utilisateurs à auditer. Si plusieurs OU renseignées, les séparer par une virgule.


**ServeurSMTP** : Nom de domaine ou Adresse IP du serveur SMTP

**Expediteur** : Adresse de l'expéditeur du rapport.

**Destinataires** : Adresse e-mail du destinataire du rapport. Si plusieurs destinataires, séparer les adresses par une virgule.

## Rapport 

Un rapport est envoyé par mail à l'adresse indiquée dans le fichier INI.

Il aura la forme suivante :
![Exemple de rapport](https://zupimages.net/up/21/40/rbyi.png)
