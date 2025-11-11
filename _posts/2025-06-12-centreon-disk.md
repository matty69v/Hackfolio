---
date: 2025-06-12 00:00:00 +0100
title: "Centreon : supervision de l'espace disque de vos serveurs Linux et Windows"
author: Matty
categories: [Centreon]
tags: [Linux, supervision, centreon, disk, snmp]
render_with_liquid: false
image:
    path: /images/centreon_disk/Centreon-monitoring-espace-disque-linux-windows.jpg.jpeg
---

## I. Présentation

Comment surveiller l'espace disque de serveurs Linux ou Windows via Centreon ? Voici la problématique à laquelle va répondre cet article. Précédemment, nous avons vu comment superviser un serveur, qu'il soit sous Linux ou Windows.

Cette fois-ci, nous verrons comment créer un service personnalisé afin de superviser efficacement l'espace disque sur un système Linux et Windows. Plutôt que de s'appuyer sur des solutions prêtes à l'emploi pour des cas génériques, cette méthode permet de répondre à des besoins spécifiques et d'adapter la supervision à votre environnement. Grâce à Centreon, il est possible d'ajouter des vérifications ciblées via des plugins ou des commandes personnalisées, ce qui permet de surveiller précisément les volumes critiques de vos serveurs.

Avant de commencer, vous devez configurer votre hôte Linux / Windows pour l'intégrer dans Centreon. Nous utiliserons le protocole SNMP dans les deux cas.

Vous pouvez vous référer à nos précédents articles sur Centreon :

- Centreon : installation de votre serveur de supervision sous Linux
- Sécurisation Centreon : protection des utilisateurs, SELinux, pare-feu, etc.
- Sécurisation Centreon : comment configurer l'accès HTTPS pour l'interface Web ?
- Centreon : comment superviser des serveurs Linux avec SNMPv3 ?
- Centreon : comment superviser Windows Server ?
- Centreon : comment importer des hôtes via un fichier CSV et l'API CLAPI ?
- Centreon : supervision d'un serveur VMware ESXi avec le connecteur de Centreon
- Centreon : mise en place des notifications par e-mail pour votre supervision

## II. Supervision de l'espace disque Linux

Dans le précédent article, nous avons utilisé le template fourni par Centreon, à savoir `OS-Linux-SNMPv3-custom`, ce qui nous a permis de surveiller des services tels que le CPU, la mémoire ou encore l'uptime, directement liés à cette template.

Cependant, Centreon propose également des services additionnels qui ne sont pas directement liés à la template principale. Ces services permettent une personnalisation plus fine de la supervision. C'est notamment le cas du Disk, que l'on retrouve dans les services non liés à la template principale (Disk-Global, Disk-Generic-Name, etc.). Ils sont visibles sur l'image suivante :

![Services non liés à la template principale dans Centreon]( /images/centreon_disk/1.png)

Désormais, afin de créer un service personnalisé pour notre serveur Linux sur l'interface WEB, rendez-vous dans **Configuration → Services → Services by host**. Ici, vous allez pouvoir apercevoir vos services déjà configurés sur votre serveur.

![Services configurés pour un hôte dans Centreon]( /images/centreon_disk/2.png)

Afin de pouvoir ajouter notre service personnalisé, nous devons cliquer sur **« Add »** :

![Ajout d'un service personnalisé dans Centreon]( /images/centreon_disk/3.png)

Dans la section **Service Basic Information**, nous renseignons le nom du service avec `Serveur-Linux-Disk`. Nous sélectionnons ensuite l'hôte concerné, ici notre serveur Linux. Nous choisissons la template `OS-Linux-Disk-Global-SNMPv3-custom`, qui est conçue pour superviser globalement l'état des disques via SNMPv3.

Ensuite, dans la partie **Service Check Options**, nous sélectionnons la commande de vérification `OS-Linux-SNMPv3-Disk-Global`. Cette commande nous permet de définir plusieurs macros personnalisées. Dans la macro `FILTER`, nous indiquons la valeur `.*` afin de superviser tous les systèmes de fichiers détectés. Les champs `TRANSFORMSRC` et `TRANSFORMDST` restent vides, car nous n'appliquons ici aucune transformation sur les noms.

Nous définissons ensuite des seuils d'alerte : `80` pour le niveau `WARNING` et `90` pour le niveau `CRITICAL`. Cela signifie qu'une alerte sera générée si l'espace disque utilisé dépasse 80 %, et une alerte critique à partir de 90 %. Enfin, dans la macro `EXTRAOPTIONS`, nous ajoutons `--verbose --filter-perfdata='storage'` afin d'obtenir plus de détails dans les résultats et de filtrer les données de performance spécifiquement sur le stockage.

Dans la section **Service Scheduling Options**, nous choisissons un contrôle permanent 24h/24 et 7j/7 avec une période de vérification `24x7`. Nous fixons le nombre maximal de tentatives à `5`, avec un intervalle normal de vérification toutes les minutes (valeur `0`, soit 60 secondes) et un intervalle de `1` avant toute nouvelle tentative (soit 60 secondes également).

Une fois toutes ces informations saisies, nous cliquons sur **Save** pour enregistrer le service. Ce dernier sera désormais associé à notre hôte et permettra de surveiller efficacement l'état de l'espace disque via SNMPv3.

Ce qui donne la configuration suivante :

![Configuration du service de supervision de l'espace disque dans Centreon]( /images/centreon_disk/4.png)

> **Attention**, après chaque modification, veillez à bien exporter et recharger la configuration de Centreon comme vu dans les modifications lors de la création des hôtes.

Désormais, vous pouvez vous rendre dans la page de visualisation de vos services et vous pouvez observer les valeurs données par le service que nous venons de créer. Voici un exemple de résultats que vous pouvez obtenir :

![Résultats de la supervision de l'espace disque dans Centreon]( /images/centreon_disk/5.png)

## III. Supervision de l'espace disque Windows

Dans le précédent article, nous avons utilisé le template fourni par Centreon, à savoir `OS-Windows-SNMP-custom`, ce qui nous a permis de surveiller des services tels que le CPU, la mémoire ou encore l'uptime, directement liés à cette template.

Cependant, Centreon propose également des services additionnels qui ne sont pas directement liés à la template principale. Ces services permettent une personnalisation plus fine de la supervision. C'est notamment le cas du Disk, que l'on retrouve dans les services non liés à la template principale (Disk-Global, Disk-Generic-Name, etc.). Les noms de ces services sont visibles sur cette image :

![Services non liés à la template principale dans Centreon]( /images/centreon_disk/6.png)

Désormais, afin de créer un service personnalisé comme pour notre serveur Linux sur l'interface WEB rendez-vous dans **Configuration → Services → Services by host**. Sur cette page, vous allez pouvoir apercevoir les services déjà configurés précédemment pour votre serveur.

![Services configurés pour un hôte dans Centreon]( /images/centreon_disk/7.png)

Afin de pouvoir ajouter notre service personnalisé, nous devons cliquer sur **« Add »** :

![Ajout d'un service personnalisé dans Centreon]( /images/centreon_disk/8.png)

Dans la section **Service Basic Information**, nous renseignons le nom du service avec `Serveur-Windows-Disk`. Nous sélectionnons ensuite l'hôte concerné, ici `Windows-Server`, puis nous choisissons le modèle `OS-Windows-Disk-Global-SNMP-custom`, qui est conçu pour superviser l'état global des disques d'un serveur Windows via SNMP.

Dans la section **Service Check Options**, nous sélectionnons la commande de vérification `OS-Windows-SNMP-Disk-Global`. Cette commande nous permet de définir plusieurs macros personnalisées pour affiner la supervision :

- `FILTER` : la valeur `.*` permet de superviser tous les systèmes de fichiers détectés.
- `TRANSFORMSRC` : avec la valeur `^(.*)`, on capture l'ensemble du nom du système de fichiers.
- `TRANSFORMDST` : avec la valeur `$1`, on restitue tel quel le nom capturé précédemment, sans modification.
- `WARNING` : seuil d'alerte fixé à `80` % d'espace disque utilisé.
- `CRITICAL` : seuil critique fixé à `90`.
- `EXTRAOPTIONS` : `--verbose --filter-perfdata='storage'` permet d'obtenir des résultats détaillés et de filtrer les données de performance uniquement sur la partie stockage.

Dans la section **Service Scheduling Options**, nous définissons les paramètres de vérification du service :

- **Check Period** : `24x7`, pour un contrôle en continu 24h/24 et 7j/7.
- **Max Check Attempts** : `5`, pour ne considérer une alerte qu'après 5 échecs consécutifs.
- **Normal Check Interval** : `0` (équivalent à 60 secondes), pour une vérification toutes les minutes.
- **Retry Check Interval** : `1` (soit également 60 secondes), en cas d'échec.

Enfin, nous laissons les options de vérifications actives et passives activées. Une fois toutes ces informations correctement saisies, nous cliquons sur **Save** pour enregistrer le service. Il sera alors associé à notre hôte Windows et permettra une supervision efficace de l'espace disque via SNMP.

![Configuration du service de supervision de l'espace disque dans Centreon]( /images/centreon_disk/9.png)

> **Attention**, après chaque modification, veillez à bien exporter et recharger la configuration de Centreon comme vu dans les modifications lors de la création des hôtes.

Désormais, vous pouvez vous rendre dans la page de visualisation de vos services. Comme pour Linux, vous pourrez observer les valeurs obtenues auprès de votre hôte Windows via le service que nous venons de créer. Voici un exemple de résultats que vous pouvez obtenir, où nous parvenons bien à récupérer des informations sur l'espace disque du volume C d'une machine Windows :

![Résultats de la supervision de l'espace disque dans Centreon]( /images/centreon_disk/10.png)

## IV. Conclusion

La mise en place d'une supervision personnalisée de l'espace disque avec Centreon est essentielle pour correctement monitorer les serveurs, qu'ils soient sous Linux ou Windows. En s'appuyant sur des services spécifiques non liés aux templates par défaut, il devient possible d'adapter précisément la surveillance aux besoins réels de l'infrastructure.

Facilement déployable via l'interface web de Centreon, cette méthode renforce la pertinence de la supervision tout en restant accessible. Au même titre que la surveille du CPU et de la RAM, la surveillance de l'espace disque constitue une bonne pratique en matière de supervision des hôtes.

Pour aller plus loin dès maintenant, vous pouvez consulter la documentation officielle de Centreon.
