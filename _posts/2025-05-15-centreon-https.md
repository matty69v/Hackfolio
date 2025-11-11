---
date: 2025-05-15 00:00:00 +0100
title: "Sécurisation Centreon : comment configurer l'accès HTTPS pour l'interface Web ?"
author: Matty
categories: [Centreon]
tags: [Linux, supervision, centreon, installation, securisation, selinux, firewall]
render_with_liquid: false
image:
    path: /images/centreon_https/Centreon-connexion-HTTPS-avec-un-certificat-TLS.jpg.jpeg
---

## I. Présentation

Dans ce tutoriel, nous allons voir comment configurer SSL/TLS sur Centreon pour passer en HTTPS, afin de protéger vos communications à l'aide de connexions chiffrées.

Précédemment, nous avons vu comment installer Centreon sous Linux et comment effectuer la sécurisation de Centreon en activant des outils essentiels tels que SELinux et firewalld, ainsi qu'en renforçant la sécurité des comptes utilisateurs et des fichiers de configuration. Maintenant que votre serveur est protégé au niveau des accès et du réseau, il est temps de sécuriser les communications : le passage en HTTPS pour l'accès à l'interface web.

Le protocole HTTPS chiffre les échanges entre votre navigateur et l'interface web de Centreon, garantissant ainsi la confidentialité et l'intégrité des données. Cela permet d'éviter les risques d'interception ou de modification des informations échangées.

Retrouvez les précédents tutoriels :

- Centreon : installation de votre serveur de supervision sous Linux
- Sécurisation Centreon : protection des utilisateurs, SELinux, pare-feu, etc.

## II. Sécuriser le serveur web en HTTPS

Par défaut, Centreon installe un serveur web en mode HTTP. Il est fortement recommandé de passer en mode HTTPS en ajoutant votre certificat. Il est également recommandé d'utiliser un certificat validé par une autorité plutôt qu'un certificat auto-signé.

- Si vous avez déjà un certificat délivré par une autorité de certification d'entreprise (AD CS, par exemple), vous pouvez passer directement à l'étape de configuration du HTTPS sur votre serveur Apache. Il s'agit du scénario idéal et recommandé pour la production.
- Si vous ne disposez pas d'un certificat validé par une autorité, vous pouvez en générer un sur des plateformes telles que Let's Encrypt. Néanmoins, cette méthode est plus contraignante dans le contexte de Centreon, car ce n'est pas une application destinée à être publiée.
- Si vous souhaitez créer un certificat selon la méthode auto-signée, suivez la prochaine partie de cet article avant d'activer le mode HTTPS sur votre serveur.

### A. Créer un certificat auto-signé

Cette procédure permet de créer :

- Une clé privée pour le serveur : `centreon7.key` dans notre cas. Elle sera utilisée par le service Apache.
- Un fichier CSR (Certificate Signing Request) : `centreon7.csr` dans notre cas.
- Une clé privée pour le certificat de l'autorité de certification : `ca_demo.key` dans notre cas.
- Un certificat x509 pour signer votre certificat pour le serveur : `ca_demo.crt` dans notre cas.
- Un certificat pour le serveur : `centreon7.crt` dans notre cas.

Soit un serveur Centreon avec le FQDN suivant : `centreon7.localdomain`.

**Note :** Dans ce document, nous utilisons le nom `centreon7.localdomain` à titre d'exemple, mais en environnement de production, on rencontre plutôt des noms sous la forme `centreon7.domaine.local`. Pensez à adapter les noms de domaine selon les pratiques de votre organisation et vos conventions DNS. La procédure reste identique.

**Préparez la configuration OpenSSL :**

Les certificats auto-signés peuvent être rejetés par le navigateur Google Chrome (sans qu'il soit possible d'ajouter une exception). Pour continuer à utiliser ce navigateur, vous devez modifier la configuration OpenSSL.

Ouvrez le fichier `/etc/pki/tls/openssl.cnf`.

Recherchez la section `[v3_ca]` afin d'ajouter le nouveau tag `alt_names` :

![IMAGE](/images/centreon_https/Creer-un-certificat-auto-signe-pour-Centreon.jpg.jpeg)

Créez une clé privée nommée `centreon7.key` sans mot de passe afin qu'elle puisse être utilisée par le service Apache.

```bash
openssl genrsa -out centreon7.key 2048
```

Afin de protéger le fichier, nous allons exécuter cette commande qui modifie ces droits :

```bash
chmod 400 centreon7.key
```

Avec la clé que vous venez de créer, créez un fichier CSR (Certificate Signing Request). Remplissez les champs avec les informations propres à votre entreprise. Le champ Common Name doit être identique au hostname de votre serveur Apache (dans notre cas, `centreon7.localdomain`).

```bash
openssl req -new -key centreon7.key -out centreon7.csr
```

Créez une clé privée pour cette autorité : `ca_demo.key` dans notre cas. Ajoutez l'option `-aes256` pour chiffrer la clé créée et y appliquer un mot de passe. Ce mot de passe sera demandé chaque fois que la clé sera utilisée.

```bash
openssl genrsa -aes256 2048 > ca_demo.key
```

Créez un certificat x509 qui sera valide pendant un an : `ca_demo.crt` dans notre cas.

Notez qu'il est nécessaire de simuler un tiers de confiance lors d'une utilisation de certificat auto-signé : le Common Name doit être différent de celui du certificat du serveur.

```bash
openssl req -new -x509 -days 365 -key ca_demo.key -out ca_demo.crt
```

Ce certificat étant créé, vous pourrez l'utiliser pour signer le certificat du serveur.

Créez votre certificat pour le serveur en utilisant le certificat x509 (`ca_demo.crt`) pour le signer.

```bash
openssl x509 -req -in centreon7.csr -out centreon7.crt -CA ca_demo.crt -CAkey ca_demo.key -CAcreateserial -CAserial ca_demo.srl -extfile /etc/pki/tls/openssl.cnf -extensions v3_ca
```

Le mot de passe créé à l'étape "Créez une clé privée pour cette autorité" doit être renseigné. Vous obtenez un certificat pour le serveur nommé `centreon7.crt`.

Vous pouvez voir le contenu du fichier :

```bash
less centreon7.crt
```

Vous devez ensuite récupérer le fichier du certificat x509 (`ca_demo.crt`) et l'importer dans le magasin de certificats de votre navigateur.

Maintenant que vous avez votre certificat auto-signé, vous pouvez suivre la procédure suivante pour activer le mode HTTPS sur votre serveur Apache.

### B. Activer le mode HTTPS sur le serveur web

Pour permettre à votre serveur web d'utiliser une connexion sécurisée en HTTPS, il est nécessaire d'installer les modules requis pour Apache en exécutant la commande suivante :

```bash
dnf install mod_ssl mod_security openssl
```

Ensuite, installez vos certificats SSL (dans notre cas `centreon7.key` et `centreon7.crt`) en les copiant dans les répertoires appropriés :

```bash
cp centreon7.key /etc/pki/tls/private/ 
cp centreon7.crt /etc/pki/tls/certs/
```

Avant de modifier la configuration d'Apache, il est recommandé de sauvegarder le fichier actuel pour éviter tout dysfonctionnement en cas d'erreur. La commande suivante crée une copie de sécurité :

```bash
cp /etc/httpd/conf.d/10-centreon.conf{,.origin}
```

Une fois cette sauvegarde effectuée, vous pouvez modifier le fichier `/etc/httpd/conf.d/10-centreon.conf` pour ajouter la configuration nécessaire à l'écoute sur le port sécurisé 443, en ajoutant une section `<VirtualHost *:443>` :

```apache
Define base_uri "/centreon" 
Define install_dir "/usr/share/centreon" 

ServerTokens Prod 

<VirtualHost *:80> 
RewriteEngine On 
RewriteCond %{HTTPS} off 
RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} 
</VirtualHost>
```

Voici un exemple de ce à quoi le fichier final peut ressembler dans notre cas après l'ajout du Virtual Host :

```apache
Define base_uri "/centreon"
Define install_dir "/usr/share/centreon"

ServerTokens Prod

<VirtualHost *:80>
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}
</VirtualHost>

<VirtualHost *:443>
    #####################
    # SSL configuration #
    #####################
    SSLEngine On
    SSLProtocol All -SSLv3 -SSLv2 -TLSv1 -TLSv1.1
    SSLCipherSuite ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-DSS-AES256-GCM-SHA384:DHE-DSS-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-GCM-SHA256:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!ADH:!IDEA
    SSLHonorCipherOrder On
    SSLCompression Off
    SSLCertificateFile /etc/pki/tls/certs/centreon7.crt
    SSLCertificateKeyFile /etc/pki/tls/private/centreon7.key

    Header set X-Frame-Options: "sameorigin"
    Header always edit Set-Cookie ^(.*)$ $1;HttpOnly;SameSite=Strict
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    ServerSignature Off
    TraceEnable Off

    Alias ${base_uri}/api ${install_dir}
    Alias ${base_uri} ${install_dir}/www/

    <IfModule mod_brotli.c>
        AddOutputFilterByType BROTLI_COMPRESS text/html text/plain text/xml text/css text/javascript application/javascript application/json
    </IfModule>

    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json

    <LocationMatch ^\${base_uri}/?(?!api/latest/|api/beta/|api/v[0-9]+/|api/v[0-9]+\.[0-9]+/)(.*\.php(/.*)?)$>
        ProxyPassMatch "fcgi://127.0.0.1:9042${install_dir}/www/$1"
    </LocationMatch>

    <LocationMatch ^\${base_uri}/?(authentication|api/(latest|beta|v[0-9]+|v[0-9]+\.[0-9]+))/.*$>
        ProxyPassMatch "fcgi://127.0.0.1:9042${install_dir}/api/index.php/$1"
    </LocationMatch>

    ProxyTimeout 300
    ErrorDocument 404 ${base_uri}/index.html
    Options -Indexes +FollowSymLinks

    <IfModule mod_security2.c>
        # https://github.com/SpiderLabs/ModSecurity/issues/652
        SecRuleRemoveById 200003
    </IfModule>

    <Directory "${install_dir}/www">
        DirectoryIndex index.php
        AllowOverride none
        Require all granted
        FallbackResource ${base_uri}/index.html
    </Directory>

    <Directory "${install_dir}/api">
        AllowOverride none
        Require all granted
    </Directory>

    <If "'${base_uri}' != '/'">
        RedirectMatch ^/$ ${base_uri}
    </If>
</VirtualHost>
```

N'oubliez pas de changer les directives `SSLCertificateFile` et `SSLCertificateKeyFile` avec les chemins d'accès vers votre clé et votre certificat. Dans notre cas : `SSLCertificateFile /etc/pki/tls/certs/centreon7.crt` et `SSLCertificateKeyFile /etc/pki/tls/private/centreon7.key`. Ces directives peuvent changer en fonction du nom de votre certificat et votre clé.

### C. Renforcer la sécurité d'Apache

Pour renforcer la sécurité de votre serveur web Apache, il est important d'activer certains paramètres dans la configuration. Dans le fichier `/etc/httpd/conf.d/10-centreon.conf`, on peut ajouter plusieurs directives avant la balise `<VirtualHost>` pour améliorer la protection contre certaines attaques :

- **HttpOnly / Secure / SameSite=Strict** : sécurisent les cookies contre les attaques XSS (exécution de scripts) et CSRF (requêtes malveillantes).
- **Strict-Transport-Security (HSTS)** : force l'usage du HTTPS pour éviter les attaques de type man-in-the-middle ou downgrade.
- **ServerSignature Off et ServerTokens Prod** : masquent les informations sur le serveur pour réduire la surface d'attaque et éviter le repérage de vulnérabilités spécifiques.

Ce qui donne :

```apache
Header always edit Set-Cookie ^(.*)$ $1;HttpOnly;Secure;SameSite=Strict
Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
ServerSignature Off
ServerTokens Prod
```

En désactivant le paramètre `expose_php = Off` dans le fichier `/etc/php.d/50-centreon.ini`, on empêche PHP d'ajouter son empreinte (comme `X-Powered-By: PHP/8.x`) dans les en-têtes HTTP.

Cela limite les informations exposées aux attaquants, qui pourraient utiliser la version de PHP pour cibler des failles connues. C'est une bonne pratique pour réduire la surface d'attaque :

```ini
expose_php = Off
```

Désormais, vous pouvez effectuer ce test vérifiant qu'Apache est bien configuré, en exécutant la commande suivante :

```bash
apachectl configtest
```

Le résultat attendu de la commande est :

```
Syntax OK
```

Après avoir modifié les fichiers de configuration d'Apache et PHP, il est essentiel de redémarrer les services pour que les changements soient pris en compte. La commande suivante redémarre à la fois PHP (via php-fpm) et le serveur web Apache :

```bash
systemctl restart php-fpm httpd
```

Ensuite, on vérifie que le service Apache a bien redémarré et fonctionne correctement avec :

```bash
systemctl status httpd
```

Si tout est correct lors de votre configuration vous devriez avoir quelque chose comme :

```
httpd.service - The Apache HTTP Server
Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; preset: disabled)
Drop-In: /etc/systemd/system/httpd.service.d
└─php-fpm.conf
Active: active (running) since Tue 2025-04-22 11:07:14 UTC; 6s ago
Docs: man:httpd.service(8)
Main PID: 59193 (httpd)
Status: "Started, listening on: port 443, port 80"
Tasks: 177 (limit: 10881)
Memory: 43.7M
CPU: 227ms
CGroup: /system.slice/httpd.service
├─59193 /usr/sbin/httpd -DFOREGROUND
├─59194 /usr/sbin/httpd -DFOREGROUND
├─59195 /usr/sbin/httpd -DFOREGROUND
├─59196 /usr/sbin/httpd -DFOREGROUND
└─59197 /usr/sbin/httpd -DFOREGROUND

Apr 22 11:07:14 localhost systemd[1]: Starting The Apache HTTP Server...
Apr 22 11:07:14 localhost httpd[59193]: AH00558: httpd: Could not reliably determine the server's fully qualified domai>
Apr 22 11:07:14 localhost httpd[59193]: Server configured, listening on: port 443, port 80
Apr 22 11:07:14 localhost systemd[1]: Started The Apache HTTP Server.
```

Vous pouvez maintenant accéder à votre plateforme via votre navigateur en mode HTTPS et apercevoir dans votre navigateur le certificat que nous venons de créer :

![Image](/images/centreon_https/Apercu-du-certificat-TLS-pour-le-HTTPS-de-Centreon.jpg.jpeg)

### D. Configuration de l'API de Gorgone

Dans le fichier `/etc/centreon-gorgone/config.d/31-centreon-api.yaml`, il faut remplacer `127.0.0.1` par le FQDN (nom de domaine complet) de votre serveur Centreon, par exemple pour nous : `centreon7.localdomain`.

Cela permet à Gorgone (le moteur d'automatisation de Centreon) d'accéder correctement à l'API REST, notamment si des communications doivent transiter par le réseau ou si des agents distants doivent s'y connecter.

```yaml
gorgone: 
tpapi: 
- name: centreonv2 
base_url: "http://centreon7.localdomain/centreon/api/latest/" 
username: "centreon-gorgone" 
password: "*********" 
- name: clapi 
username: "centreon-gorgone" 
password: "*********"
```

Une fois le fichier modifié, redémarrez le service Gorgone pour appliquer les changements :

```bash
systemctl restart gorgoned
```

Puis, vérifiez que le service fonctionne correctement avec :

```bash
systemctl status gorgoned
```

Si tout est correct, vous devriez obtenir un résultat comme celui-ci :

```
gorgoned.service - Centreon Gorgone
Loaded: loaded (/etc/systemd/system/gorgoned.service; enabled; preset: disabled)
Active: active (running) since Tue 2025-04-22 11:14:00 UTC; 5s ago
Main PID: 59695 (perl)
Tasks: 48 (limit: 10881)
CGroup: /system.slice/gorgoned.service
├─59695 /usr/bin/perl /usr/bin/gorgoned --config=/etc/centreon-gorgone/config.yaml --logfile=/var/log/cent>
├─59721 gorgone-dbcleaner
├─59722 gorgone-cron
├─59723 gorgone-proxy
├─59724 gorgone-proxy
├─59725 gorgone-proxy
├─59726 gorgone-proxy
├─59727 gorgone-proxy
├─59728 gorgone-engine
├─59729 gorgone-action
├─59730 gorgone-legacycmd
├─59731 gorgone-audit
├─59732 gorgone-nodes
├─59735 gorgone-autodiscovery
├─59738 gorgone-statistics
└─59739 gorgone-httpserver
Apr 22 11:14:00 localhost systemd[1]: Started Centreon Gorgone.
```

## III. Conclusion

En suivant ces étapes, vous devriez être en mesure de configurer votre serveur Centreon en HTTPS, assurant ainsi la sécurité des communications entre vos utilisateurs et votre serveur. Il est également recommandé d'utiliser un certificat valide d'une autorité reconnue pour renforcer la confiance dans la sécurité de votre serveur.

Dans les prochains articles, nous verrons comment superviser des hôtes et des services sur différents systèmes (Linux, Windows, équipements réseau, etc.), configurer des notifications, et affiner votre supervision.

Pour aller plus loin dès maintenant, vous pouvez consulter la documentation officielle de Centreon.

![Image](/images/centreon_https/Acces-a-Centreon-en-HTTPS.jpg.jpeg)