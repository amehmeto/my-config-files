---
description: Liste les PRs ouvertes du repo courant, triées par LoC modifiées — la plus petite à reviewer en premier.
argument-hint: "(aucun argument)"
allowed-tools: Bash(~/.claude/scripts/pr-queue.sh:*)
---

Classe les PRs ouvertes du repo courant par nombre de lignes modifiées, la plus
petite d'abord, pour que la review la moins coûteuse passe en premier.

**Comment :** lance le script et restitue sa sortie **verbatim**.

```bash
~/.claude/scripts/pr-queue.sh --markdown
```

Il produit déjà un tableau Markdown (rang, LoC, nombre de fichiers, barre de diff
verte/rouge façon GitHub, lien cliquable vers la PR). Ne reformate rien, ne
retrie rien, n'ajoute aucun commentaire.

Si le script affiche `No open PR.`, dis-le en une ligne et arrête-toi.

**Ne fais pas :**

- Rejouer `gh pr list` ou retrier toi-même — le tri (`additions + deletions`
  croissant) vit dans le script pour rester reproductible depuis n'importe quel
  shell.
- Recommander quelle PR reviewer : la colonne rang **est** la recommandation.

**Version terminal colorée :** `~/.claude/scripts/pr-queue.sh` sans argument sort
la variante ANSI (`+` vert, `-` rouge, URLs grisées). Si l'utilisateur la veut,
copie `! ~/.claude/scripts/pr-queue.sh` dans son presse-papier avec `pbcopy`.
