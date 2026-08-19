---
name: carrousel
description: Écrit ou réécrit un carrousel court-format (TikTok, Instagram) en appliquant des règles de copywriting mesurées, puis se relit contre chacune avant de rendre. Le projet fournit son avatar, son produit et son vocabulaire dans un fichier de profil ; le skill n'en connaît aucun d'avance. Utiliser quand l'utilisateur invoque /carrousel, ou demande d'écrire, réécrire ou critiquer un carrousel, des diapositives, un hook, un titre ou une légende de réseau social.
---

# Écrire un carrousel

Invocation : `/carrousel <format> <idée en une phrase>`.
Sans argument, prendre le sujet de la conversation en cours.

Ce fichier ne contient **aucune** donnée de projet : pas de nom de compte, pas de produit,
pas de marché. Tout cela vit dans le profil, chargé à l'étape 0.

---

## 0. Charger le profil du projet

Chercher dans cet ordre, s'arrêter au premier trouvé :

1. le chemin donné dans l'invocation, `--profil <chemin>` ;
2. `.carrousel/profil.md`, depuis le dossier courant puis en remontant jusqu'à la racine
   du dépôt ;
3. `CARROUSEL_PROFIL` dans l'environnement.

**Aucun profil trouvé** : poser les 9 questions du modèle `profil.modele.md`, une à la fois,
puis écrire `.carrousel/profil.md` avant d'écrire quoi que ce soit d'autre. Ne jamais
inventer un avatar, un produit ou un marché.

Le profil peut **écraser n'importe quelle règle de ce fichier**. Une règle écrasée est
signalée à la relecture, avec la ligne du profil qui l'écrase.

---

## 1. La décision qui précède l'écriture : le pool

**Écrire du contenu de la niche large qui contient le produit, jamais du contenu sur le
produit.** Le hashtag et le sujet ne causent rien, ils étiquettent deux publics de tailles
très différentes, et le plafond de diffusion se choisit là.

Mesuré sur un corpus TikTok de 24 fiches de niche en août 2026 : le contenu qui sert
l'activité de l'audience fait **×5,38** la médiane, le contenu qui parle d'une application
fait **×0,05**. Ordre de grandeur : 12 000 vues contre plus d'un million.

**Si l'idée fournie parle du produit, la reformuler en situation vécue de la niche et le dire
en une phrase avant de rendre le carrousel.** C'est le seul endroit où ce skill discute la
commande.

Le profil donne la niche large et la niche produit. S'il ne les donne pas, les demander.

---

## 2. Les règles d'écriture

Chacune porte le chiffre qui la fonde. Provenance : corpus de 11 032 posts TikTok et
75 fiches dépouillées, août 2026, plus les études publiques citées. Un projet dont la
plateforme ou l'audience diffère peut les écraser depuis son profil, mais pas les ignorer
en silence.

| # | Règle | Le chiffre |
|---|---|---|
| 1 | **L'aveu bat la promesse.** Montrer une tentative en cours, jamais un résultat acquis. L'avatar n'a pas à être crédible sur un résultat, seulement sur une tentative. | 416 300 vues contre 9 537, même compte, même semaine : **×44** |
| 2 | **Le produit n'apparaît pas avant la 3ᵉ diapositive**, ni dans le titre, ni en ouverture de légende. | les 2 plus mauvais scores du corpus ouvrent sur le nom du produit : 0,05 % et 0,37 % d'engagement |
| 3 | **Le hook porte une autorité, un décompte ou une échéance**, plus une parenthèse de désamorçage qui prend de vitesse l'objection. | les 4 meilleurs engagements portent l'un des trois : 23,22 %, 18,84 %, 10,61 %, 3,97 % |
| 4 | **Décider le geste avant d'écrire le hook, et ne jamais viser les deux.** Commentaire : une question fermée sur un comportement précis et un peu honteux, adressée à un groupe nommé. Partage : une conséquence sociale qui demande un destinataire. | 1 commentaire / 156 vues contre 1 / 2 202 : **×14** |
| 5 | **Le hook est repris tel quel sur la diapositive 1.** Un lecteur qui arrive en cours de route doit comprendre la scène. | les 2 plus gros scores le font : 11 600 000 et 4 000 000 de vues |
| 6 | **Une liste d'objets distincts et nommés qui n'appartiennent pas au créateur.** Une diapositive, un objet. Le lecteur repart avec quelque chose d'utilisable sans nous. L'essai explicatif qui développe un seul raisonnement sur toutes les diapositives perd. | 38,8 partages+enregistrements par mille contre 2,7 |
| 7 | **Vocabulaire de l'audience, repris tel quel.** Jamais le vocabulaire de la catégorie du produit. La liste vient du profil. | relevé sur les fiches de veille |
| 8 | **Connaître le discours dominant de la catégorie, et savoir si on le prend à contre-courant.** Le profil dit lequel des deux. | 3 relevés concordants |
| 9 | **Produit nommé une fois, tard, dans une formule jetable.** Jamais décrit, jamais expliqué. La formule vient du profil. | patron de 9 posts hors catégorie, jusqu'à 26,42 % d'engagement |
| 10 | **L'appel à l'action est une consigne de recherche, en fin de légende, pas un lien.** Les plateformes étouffent les liens sortants, et la recherche par nom envoie en prime un signal de marque. | relevé sur un post à 2 700 000 vues |
| 11 | **Annoncer le fait commercial le plus fort** quand il existe : gratuité, essai, absence de compte. Le profil le donne. | patron hors catégorie |
| 12 | **Demander une sauvegarde ou un commentaire, jamais un J'aime. Un seul appel par post.** | commentaires **+14 %**, J'aime **−60 %** |
| 13 | **Légende courte, minuscules, 1re personne, emojis**, le mot `swipe` quelque part, et **une mention @ d'un compte de la niche** tant que le compte est petit. | portée **+21 %**, commentaires **+45 %** ; l'effet s'inverse au-delà de 100 000 abonnés |
| 14 | **1 ou 2 hashtags descriptifs.** Lesquels, et lesquels sont interdits, viennent du profil. | présence d'au moins un hashtag : +5 % de vues ; les hashtags de catégorie mesurés font ×0,05 à ×0,06 |
| 15 | **Respecter les contraintes de vraisemblance de l'avatar** : lieu, âge, statut, langue. Rien dans le texte ni dans les descriptions d'illustration ne doit les contredire. | contrainte du profil |

---

## 3. Le style d'écriture

Réglages par défaut. Le profil peut les changer champ par champ.

**A. Em-dash strictement interdit, aucune exception.** Virgule, point, deux-points ou
parenthèse.

**B. Toujours le chiffre, jamais la forme en toutes lettres.** `6 hrs`, jamais `six hours`.

**C. Contractions et phrases simples.** Une idée par phrase. Pas de subordonnées empilées.

**D. Ne jamais nommer un concurrent.**

**E. Se concentrer sur la situation, les émotions, la douleur.** Pas les outils, pas les
fonctionnalités, pas la comparaison.

**F. Abréviations, et l'écriture d'un natif qui envoie un texto.** En anglais américain :
`hrs`, `tmrw`, `u`, `n` pour `and`, `abt`, `bc`, `rn`, `idk`, `ngl`, `pls`. Les apostrophes
tombent : `its`, `thats`, `wasnt`. Le pronom d'ouverture saute quand la phrase tient sans lui.
Minuscules partout, ponctuation minimale.

**G. Aucun tic de rédaction automatique.** Pas de `in a world where`, pas de paragraphes de
longueur régulière, pas de prose lisse. Voix brute.

---

## 4. Interdits durs

- **Ne jamais promettre une fonctionnalité qui n'est pas livrée.** Le profil liste les
  promesses interdites. Une promesse fausse dans un post public est un risque produit.
- **Ne jamais ouvrir sur le nom du produit, ni le décrire.**
- **Ne jamais écrire une donnée chiffrée qui n'est pas dans le profil ou mesurable.**

---

## 5. Ce que ce skill ne fait pas

- **Il ne choisit pas les images.** Il écrit un `imageWanted` par diapositive : une scène
  concrète, 2 à 4 mots cherchables, dans la langue de la banque d'images.
- **Il ne chasse pas le son tendance.** Mesuré à ×1,16, le plus faible des attributs testés,
  et 0 % du trafic direct. Proposer un son de la liste du profil, s'il y en a une, et passer.
- **Il ne fixe pas le nombre de diapositives.** Les mesures se contredisent : un corpus dit
  que le nombre ne prédit rien, une étude dit d'éviter la bande 4-7. Viser court par défaut,
  le dire, et ne rien refuser. Le meilleur post du corpus de référence est une image unique
  à 1 700 000 vues.

---

## 6. La sortie

Le profil donne le format attendu, champ `sortie` : `json` ou `markdown`.
Par défaut, `markdown` : titre, une ligne par diapositive numérotée avec son `imageWanted`,
puis la légende et les hashtags.

En `json`, rendre exactement le schéma déclaré dans le profil, dans un bloc ` ```json `,
sans texte autour sauf la note de reformulation du pool si elle a eu lieu.

---

## 7. La relecture, obligatoire avant de rendre

Se relire contre les 15 règles et les 7 réglages de style, et rendre le verdict sous la
sortie, une ligne par règle enfreinte ou écrasée par le profil. **Une règle enfreinte est
réécrite, pas signalée.**

Trois vérifications mécaniques systématiques, parce qu'elles échouent souvent :

1. **Compter les em-dash** dans le titre, les diapositives et la légende. Le compte doit être 0.
2. **Chercher tout nombre écrit en lettres** et le convertir en chiffres.
3. **Vérifier qu'un seul appel à l'action existe**, et que c'est le geste décidé à la règle 4.

Puis afficher : `relecture : 22 règles, N tenues, M écrasées par le profil`.

---

## Fichiers du skill

- `profil.modele.md` : le modèle à copier dans un nouveau projet, avec les 9 questions.

Les mesures citées viennent d'un corpus TikTok d'août 2026 en niche étudiante anglophone.
Un projet sur une autre plateforme ou une autre audience doit les traiter comme des
hypothèses de départ, pas comme des acquis, et les écraser depuis son profil au premier
chiffre contraire mesuré chez lui.
