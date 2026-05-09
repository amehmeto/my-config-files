---
description: Fix une permission prompt Claude Code en ajoutant la règle allow minimale (least permission). Usage - /fix-permission [paste de la permission prompt]
---

L'utilisateur a copié-collé une permission prompt qui s'affiche dans Claude Code (le bloc qui demande "Do you want to proceed? Yes/No" pour une commande Bash bloquée). Ton job : diagnostiquer + ajouter la règle allow **minimale** (least permission principle) dans `.claude/settings.json` (project) ou `~/.claude/settings.json` (user). Exécute autonomement.

## Étape 1 : extraire la commande bloquée

`$ARGUMENTS` contient le paste. Cherche le bloc `Bash command` ou `Edit file` ou similaire. Extrait :
- La commande **exacte** telle qu'elle apparaît (multi-ligne accepté, conserve les retours à la ligne)
- Le tool concerné (Bash, Edit, Write, WebFetch, Read, etc.)

Si le paste ne ressemble pas à une permission prompt parsable, dis-le et arrête.

## Étape 2 : déterminer le scope (project vs user) + le format

Lis :
- `.claude/settings.json` (project, dans le cwd)
- `~/.claude/settings.json` (user)

**Toujours préférer `regexPermissions`** (plugin `amehmeto/regex-permissions`) plutôt que `permissions` natif quand le plugin est activé dans le project. Le natif n'a que des wildcards `:*` qui sont trop grossiers ; les regex permettent de scoper précisément (anchors, classes de caractères, exclure des flags). N'ajoute du natif que si le projet n'a pas le plugin configuré.

**Scope par défaut : project** (`.claude/settings.json`). User-level uniquement si la commande est cross-project (ex. `~/.claude/commands/`).

## Étape 3 : classifier la commande (read-only vs destructive)

**Avant** d'écrire la règle, classifie :

- **Read-only** : `git status/log/diff/show/blame`, `gh pr/issue view/list`, `gh api` GET (sans `-X POST/PUT/PATCH/DELETE`), `ls/find/grep/cat/head/tail/jq`, `npm view/ls/why`, etc.
  → Allow plus large autorisé (ex. famille `^gh\\s+api\\s+['\"]?repos/`), à condition que les mutations restantes soient déjà bloquées par une deny rule existante.

- **Potentiellement destructive ou avec effet de bord** : tout ce qui écrit, supprime, push, modifie un système distant ou local — `rm`, `git push`, `npm install/uninstall/update/publish`, `gh pr edit/close`, `gh api -X POST/PUT/PATCH/DELETE`, `curl --data`, scripts inconnus, etc.
  → **Règle minimale stricte**. Match la commande spécifique, jamais la famille. Aucun flag dégradant inclus.

Si tu doutes → traite comme destructive (default-secure).

**Pour `gh api`** : c'est read-only par défaut (GET) MAIS peut être destructive avec `-X POST/PUT/PATCH/DELETE`, `--method`, `-f/-F`, `--field`, `--input`. Avant d'élargir un allow `gh api`, vérifie qu'il existe une deny rule qui catch ces flags. Si oui, allow par chemin (`repos/`, `orgs/`, etc.) est OK. Sinon, règle stricte uniquement.

## Étape 4 : composer la règle minimale (least permission)

**Principes stricts** :

1. **Matche la commande spécifique, pas la famille.** Pour `node scripts/foo/bar.mjs --flag`, écris `Bash(node\\s+scripts/foo/bar\\.mjs\\b)` — **pas** `Bash(^node\\b)` qui autoriserait tout Node.
2. **Inclus le path complet** quand c'est un script local. `scripts/foo/bar.mjs` est plus sûr que `scripts/.*\\.mjs`.
3. **N'autorise pas les flags qui peuvent dégrader.** Ex: `--force`, `--no-verify`, `-X DELETE` — ne pas inclure dans la règle. Si la commande bloquée les utilise, c'est probablement intentionnel (deny rule).
4. **Une règle = une commande logique.** Pas de "j'autorise tous les scripts" en regex large. Si plusieurs scripts différents prompt, ajoute plusieurs règles.
5. **Échappe correctement** : double-backslash dans le JSON (`\\b`, `\\s+`, `\\.`).
6. **Reason clair** : 1 ligne qui dit ce que la commande fait (genre "Activity report generator — used by /cofounder").

**Anti-patterns à refuser** :
- `Bash(.*)` — wildcard total
- `Bash(node.*)` — toute commande node
- `Bash(.*\\.mjs)` — n'importe quel script mjs
- `Bash(scripts/.*)` — n'importe quel script du dossier
- Une règle qui matche le wrapper bash + tous arguments libres

**Avant d'écrire la règle, vérifie** : existe-t-il déjà une règle qui devrait matcher cette commande mais ne match pas ? Si oui, **ne pas dupliquer** — ajuster l'existante (typo, anchor manquant, escape cassé). Le least permission inclut "ne pas accumuler des règles redondantes".

## Étape 5 : appliquer + valider

1. Edit le fichier de settings en ajoutant la règle au bon endroit (groupé thématiquement avec règles similaires si possible).
2. Valide JSON :
   - `regexPermissions` : `jq -e '.regexPermissions.allow | length' <file>`
   - `permissions` natif : `jq -e '.permissions.allow | length' <file>`
3. Si invalide : revert immédiat, montre l'erreur, demande quoi faire.
4. Si valide : confirme à l'utilisateur en 2-3 lignes maximum.

## Étape 6 : check anti-leak

Si la commande bloquée correspond à une règle `deny` ou `ask` existante, **NE PAS L'OUTREPASSER**. Affiche l'erreur :
> "Cette commande matche la règle deny/ask `<rule>` (raison: `<reason>`). Ne sera pas autorisée — c'est intentionnel."

Et arrête. Ne propose pas de bypass.

## Format de réponse type

```
Commande bloquée : `node scripts/foo/bar.mjs --period=day`
Règle ajoutée à `.claude/settings.json` (regexPermissions.allow) :
  `Bash(node\\s+scripts/foo/bar\\.mjs\\b)` — Bar generator script
JSON valide. Cette commande exacte passera maintenant sans prompt. Variations (autres flags, autres paths) ne sont pas autorisées et reprompt.
```

## Garde-fous

- **Jamais d'override deny/ask** — elles existent pour une raison.
- **Jamais de wildcard total ou de famille entière** — least permission. Exception : famille read-only confirmée à l'étape 3, avec deny rule séparée pour les mutations.
- **Pas de touche aux env vars / hooks / autres sections** que `permissions.allow` ou `regexPermissions.allow`.
- **Privilégie regexPermissions au natif** quand le plugin est configuré dans le project (cf. étape 2).
- **Français, tutoiement, concision.**

## Étape 7 : reprendre le travail interrompu

Après avoir confirmé la règle ajoutée, **reprends spontanément** la commande/tâche que l'utilisateur était en train de faire avant ce `/fix-permission` — celle qui a justement déclenché la permission prompt. L'utilisateur ne devrait pas avoir à te dire "reprend" manuellement.

Repère le contexte de la conversation : la dernière tool call avant le `/fix-permission` est typiquement la commande à re-exécuter maintenant qu'elle est autorisée. Re-essaie cette commande exacte et continue la chaîne d'actions qui était en cours.
