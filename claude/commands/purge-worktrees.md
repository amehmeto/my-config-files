---
description: Libère du disque en supprimant les node_modules des worktrees périmés du repo courant.
argument-hint: "(aucun argument)"
allowed-tools: Bash(~/.claude/scripts/purge-worktrees.sh:*), Bash(df:*)
---

Chaque worktree sous `.claude/worktrees/` installe son propre `node_modules`
complet, environ 1,8 Go. Rien ne les supprime quand une branche est mergée, donc
ils s'accumulent jusqu'à saturer le disque.

Le script ne supprime que `node_modules`. Il ne touche ni au code, ni aux
branches, ni aux worktrees, ni au travail non commité. `npm ci` reconstruit
n'importe quel répertoire supprimé.

**Déroulé, dans cet ordre :**

1. **Montre ce qui partirait.** Lance `~/.claude/scripts/purge-worktrees.sh`
   (passage à blanc par défaut) et `df -h /System/Volumes/Data | tail -1`.
2. **Rapporte avant de supprimer.** Donne le nombre de worktrees purgeables,
   les Go récupérables, le nombre conservés avec la raison, et l'espace libre
   actuel. Puis demande le feu vert. C'est une suppression : jamais automatique.
3. **Purge**, une fois l'accord donné : `APPLY=true ~/.claude/scripts/purge-worktrees.sh`.
   Redonne l'espace libéré et le `df` après.
4. **Dis ce que ça ne fait pas.** La suppression des worktrees déjà mergés
   (`git worktree remove`) est une décision distincte : signale-la si beaucoup
   de worktrees purgés portent des branches déjà mergées, ne la prends pas.

Trois gardes, parce que d'autres sessions peuvent travailler dans ces
répertoires : le script ignore un worktree touché depuis moins de `KEEP_DAYS`
jours (2 par défaut), un worktree avec des modifications non commitées, et le
répertoire courant.

Le script marche dans n'importe quel repo : il trouve la racine des worktrees
par `git --git-common-dir`, donc depuis le checkout principal comme depuis un
worktree. Allonge la fenêtre de sécurité avec `KEEP_DAYS=<n>`.
