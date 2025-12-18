Comment lancer le tout ?
Dans votre terminal, dans le dossier contenant ces 4 fichiers :

Initialiser :


```tofu init```

Préparer (Planifier) en utilisant vos variables :

```tofu plan -var-file="config.tfvars"```
(Vérifiez qu'il n'y a pas d'erreurs rouges).

Appliquer :

```tofu apply -var-file="config.tfvars"```

Note importante sur le stockage : 
Si le pool de stockage sur iaas.phorge.fr ne s'appelle pas default, 
il faudra changer pool = "default" dans le fichier main.tf par le vrai nom 
(vous le verrez dans Incus UI -> Storage).