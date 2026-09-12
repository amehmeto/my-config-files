---
description: Copie du texte dans le presse-papier macOS (pbcopy). Avec argument = copie l'argument ; sans argument = copie la dernière commande/snippet que j'ai proposé.
argument-hint: "[texte à copier — vide = dernière commande suggérée]"
allowed-tools: Bash(pbcopy), Bash(pbpaste)
---

Mets du texte dans le presse-papier macOS de l'utilisateur via `pbcopy`.

**Quoi copier :**
- Si `$ARGUMENTS` est non vide → copie `$ARGUMENTS` **verbatim**, sans le reformuler, l'interpréter ni l'exécuter.
- Si `$ARGUMENTS` est vide → copie la **dernière commande shell ou le dernier bloc de code que tu as proposé** dans cette conversation (typiquement une commande à coller avec `!`). En cas de doute sur laquelle, prends la plus récente.

**Comment :** écris le texte via un heredoc *quoté* pour éviter tout problème d'échappement (apostrophes, `$`, etc.) :

```bash
cat <<'CLIP_EOF' | pbcopy
<le texte exact à copier>
CLIP_EOF
```

Puis confirme en une seule ligne (« Copié ✅ ») et montre le contenu avec un `pbpaste` de vérification.

Ne copie **que** le texte demandé — pas de prose autour, pas de backticks markdown, pas de commentaire ajouté.
