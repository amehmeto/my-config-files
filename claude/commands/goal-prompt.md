---
description: Génère un « goal prompt » — un brief d'exécution autoportant (critère de succès final, état de départ, plan par étapes avec vérifs, contraintes, hors-périmètre) **dimensionné pour être collé tel quel dans le `/goal` natif (≤ 4000 caractères, condition budgétée)**. Utilise-le quand je dis « génère un goal prompt », « goal prompt », ou que je veux transformer une tâche en brief exécutable / en goal condition.
argument-hint: "[objectif à cadrer — vide = contexte de la conversation]"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash(gh pr view:*), Bash(gh pr list:*), Bash(gh issue view:*), Bash(gh issue list:*), Bash(git log:*), Bash(git branch:*), Bash(git status:*)
---

Produis **un goal prompt** : un document d'exécution autoportant qu'un agent frais (ou une session neuve, sans accès à cette conversation) peut suivre du début à la fin. Ta sortie EST le document — pas un résumé, pas le début de l'exécution.

## Source de l'objectif

- `$ARGUMENTS` non vide → c'est l'**objectif à cadrer** (une phrase ou un paragraphe). Pars de là.
- `$ARGUMENTS` vide → **distille l'objectif depuis la conversation courante** (la tâche en cours, les décisions déjà prises).

## Règles de production (dans cet ordre)

1. **Vérifie les ancrages AVANT d'écrire.** C'est ce qui sépare un bon goal prompt d'un fragile. Ne devine jamais un chemin de fichier, un numéro de PR/issue, un nom de branche, un SHA, un pin de dépendance : confirme-les avec `Read`/`Grep`/`Glob`/`gh`/`git`. Un brief qui référence un `example.foo` inventé envoie l'agent dans le mur.
2. **Ne t'arrête pas pour poser des questions.** Le but est de LIVRER le brief. S'il manque un détail non-bloquant, prends le défaut le plus raisonnable et **note-le comme hypothèse explicite** dans le brief. Ne réserve une vraie question qu'à un choix genuinement bloquant et irréversible.
3. **Écris pour un agent sans mémoire de cette conversation.** Zéro « comme on a dit », zéro référence implicite. Tout le contexte nécessaire vit dans le document.
4. **Impératif, 2e personne** (« tu ») dirigé vers l'agent exécutant. Messages/prose en français ; identifiants de code, chemins, commandes en anglais tels quels.
5. **Adapte l'altitude à la taille de la tâche.** Petit fix → brief court (Objectif + Étapes + Contraintes suffisent). Épopée multi-repo → toutes les sections. Ne gonfle pas ; ne rogne pas l'essentiel.
6. **N'exécute pas le plan.** Tu produis le brief et tu t'arrêtes — sauf si je dis « go » ensuite.

## Structure du document

Rends **un seul bloc de code ` ```markdown `** copiable, contenant ces sections (retire celles qui ne s'appliquent pas) :

- `# GOAL — <id> · <titre court>` — `<id>` = numéro d'issue / ticket si connu, sinon rien.
- **## Objectif final (success criterion)** — l'état vérifiable qui prouve que c'est fini (« une PR ouverte sur X qui… », « la commande Y renvoie Z », « CI verte »). Mesurable, pas vague.
- **## Décision / contexte tranché (ne pas re-litiger)** — les choix déjà arrêtés, en une liste. Empêche l'agent de rouvrir des débats clos.
- **## État de départ** — ce qui est déjà fait, avec **ancrages réels vérifiés** : `fichier:ligne`, PR #, SHA courts, pins, noms de branches. C'est ici que la règle 1 paie.
- **## Plan par étapes** — chaque étape = *quoi faire* **+ une vérification** (commande, test, ou critère observable) qui prouve qu'elle est terminée. Si c'est du code : TDD (test en premier). Numérote ; ordonne par dépendance.
- **## Contraintes non-négociables** — règles du repo et garde-fous (hooks à ne pas bypasser, conventions de nommage/branche, format des pins, gates CI). Tire-les du CLAUDE.md / des règles du projet quand elles existent.
- **## Hors de ta portée (signaler, pas forcer)** — ce qui appartient à l'humain (merges, QA on-device, décisions produit) et les points à remonter au lieu de forcer.

## Sortie

- Le bloc ` ```markdown ` d'abord, prêt à coller **dans le `/goal` natif**. Au plus **1–2 lignes** avant (ce que tu as vérifié) et **1 ligne** après (« Dis “go” et je lance l'étape 1 »).
- **Budget dur : le contenu du bloc ≤ 4000 caractères** (vise ~3800 pour la marge). C'est LA contrainte — le `/goal` natif refuse au-delà. **Auto-vérifie** : écris ton brouillon dans un fichier scratch et compte (`wc -c`) ; s'il dépasse, compresse jusqu'à passer.
- **Ordre de compression quand ça déborde** (garde le haut, sacrifie le bas) : Objectif final > Décisions tranchées > Contraintes non-négociables > ancrages de l'État de départ > détail du Plan par étapes > Hors-périmètre. Fusionne les puces, coupe la prose, garde `fichier:ligne`/PR#/SHA/pins — jamais un ancrage vérifié au profit d'une phrase.
- Pour un plan trop riche pour 4000 car., le bloc reste une **goal condition** (le QUOI + le fini-quand + les garde-fous) ; l'agent exécutant déduit les micro-étapes. Ne sacrifie pas le critère de succès ni les décisions pour caser le pas-à-pas.
