Rends un **diff git en page HTML façon GitHub** — autonome, light-theme, avec coloration syntaxique et highlighting intra-ligne — puis ouvre-la dans Vitrail. But : reviewer un diff confortablement hors du terminal.

## Quoi rendre

- Si `$ARGUMENTS` est non vide → c'est la **cible du diff** :
  - une plage (`abc123..def456`), un commit (`abc123` → `abc123~1..abc123`), `HEAD~1`…
  - un numéro de PR (entier seul) → `gh pr diff <N>`
  - éventuellement suivi d'une consigne (« seulement les fichiers infra », « sans les tests »)
- Si `$ARGUMENTS` est vide → le dernier commit (`git diff HEAD~1..HEAD`), ou le diff dont on vient de parler dans la conversation.

Récupère le diff avec `git diff <range>` (ou `gh pr diff <N>`) + `--stat` pour les compteurs par fichier. Ne tronque pas silencieusement : si le diff est énorme (> ~800 lignes changées), regroupe les fichiers secondaires (lockfiles, snapshots, docs générées) dans un panneau replié `<details>` et dis-le dans la page.

## Règles de rendu

1. **Autonome** : un seul `.html`, zéro ressource externe, tout le CSS/JS inline. Doit s'ouvrir hors-ligne.
2. **Un panneau par fichier** (`.file`) : en-tête sticky-ish avec le chemin en mono + badges `+N` / `−N` (verts/rouges) + éventuel badge note (« le cœur du fix », « 3 tests ajoutés »). Table à 3 colonnes : n° ligne old, n° ligne new, code. Les numéros viennent des en-têtes de hunk `@@ -a,b +c,d @@` — recalcule-les fidèlement, ne les invente pas.
3. **Lignes** : ajout fond vert (`tr.add`), suppression fond rouge (`tr.del`), contexte blanc, en-tête de hunk bleu clair (`tr.hunk`). Signe `+`/`−` dans la cellule code.
4. **Highlighting intra-ligne** (le vrai plus vs `git diff`) : pour chaque **paire del/add qui est une modification** de la même ligne (pas un pur ajout ou une pure suppression), calcule le **préfixe et le suffixe communs** aux deux lignes et wrappe le segment qui diffère dans `<span class="chg">` — des deux côtés. Exemple :
   - del : `await repository.init<span class="chg"></span>()` → rien à wrapper côté del si le segment supprimé est vide ; wrappe alors seulement côté add : `await repository.init(<span class="chg">logger</span>)`
   - del : `dbFilename: <span class="chg">'powersync.db'</span>,` / add : `dbFilename: <span class="chg">PowersyncRepository.DB_NAME</span>,`
   - Ne wrappe PAS les lignes d'un bloc entièrement ajouté/supprimé (elles n'ont pas de contrepartie).
5. **Coloration syntaxique — appliquée PAR TOI à la génération**, pas par une lib (autonomie oblige, et tu tokenises mieux qu'une regex). Wrappe les tokens dans des spans avec ces classes, sur TOUTES les lignes de code (add, del, contexte) :
   - `tok-kw` : mots-clés (`import`, `from`, `export`, `class`, `static`, `private`, `readonly`, `async`, `await`, `return`, `if`, `const`, `let`, `new`, `throw`, `null`, `this`, `typeof`, `extends`, `implements`…)
   - `tok-str` : littéraux string (quotes incluses)
   - `tok-com` : commentaires (`//…`, `/*…*/`, `#…`)
   - `tok-num` : nombres
   - `tok-type` : identifiants de type (PascalCase : `Logger`, `Promise`, `PowerSyncDatabase`…)
   - `tok-fn` : nom de fonction/méthode à l'appel ou à la déclaration (`init`, `open`, `warn`…)
   - Le `<span class="chg">` de la règle 4 s'imbrique PAR-DESSUS (le chg contient les tok-*).
   - Adapte au langage du fichier (TS/JS, Kotlin, Markdown → seuls `tok-com`/`tok-str` pertinents, JSON → `tok-str`/`tok-num`).
6. **Header de page** : kicker (PR/commit), `<h1>` du sujet, une phrase de résumé du diff, stat pills (fichiers, +ajouts, −suppressions, tests si pertinent), et si utile un callout expliquant la logique du changement.
7. **Footer** : date + la commande `git diff` exacte + provenance.
8. N'invente rien : le code affiché est le code du diff, verbatim (échappe `<`, `>`, `&`).

## Design system (squelette à réutiliser tel quel)

```html
<!DOCTYPE html>
<html lang="fr"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{TITRE}}</title>
<style>
  :root{
    --bg:#f7f8fa; --card:#fff; --ink:#1c2330; --muted:#5b6675; --line:#e6e9ef;
    --accent:#4f6bed; --green:#1f9d6b; --green-bg:#e6f6ef; --red:#d0463f; --red-bg:#fce9e8;
    --blue:#3b6fd4; --shadow:0 1px 3px rgba(18,30,55,.06),0 8px 24px rgba(18,30,55,.05);
    --add:#e6ffec; --add-num:#ccffd8; --add-chg:#abf2bc;
    --del:#ffebe9; --del-num:#ffd7d5; --del-chg:#ffc0bd;
    --hunk:#f1f8ff; --hunk-ink:#57606a; --numink:#8b949e;
    /* palette syntaxe (GitHub light) */
    --kw:#cf222e; --str:#0a3069; --com:#6e7781; --num:#0550ae; --type:#953800; --fn:#8250df;
  }
  *{box-sizing:border-box}
  body{margin:0;background:var(--bg);color:var(--ink);
    font:15px/1.55 -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;-webkit-font-smoothing:antialiased}
  .wrap{max-width:1100px;margin:0 auto;padding:40px 28px 80px}
  .kicker{font-size:12px;letter-spacing:.14em;text-transform:uppercase;color:var(--accent);font-weight:700}
  h1{font-size:28px;margin:6px 0 8px;letter-spacing:-.02em}
  .sub{color:var(--muted);max-width:780px}
  .sub code,.callout code{background:#eceff5;padding:1px 6px;border-radius:5px;font-size:12.5px;font-family:ui-monospace,SFMono-Regular,Menlo,monospace}
  .stats{display:flex;gap:12px;flex-wrap:wrap;margin:24px 0}
  .stat{flex:1 1 130px;background:var(--card);border:1px solid var(--line);border-radius:12px;padding:14px 16px;box-shadow:var(--shadow)}
  .stat .n{font-size:24px;font-weight:800;letter-spacing:-.02em}
  .stat .l{font-size:12px;color:var(--muted);margin-top:2px}
  .stat.green .n{color:var(--green)} .stat.red .n{color:var(--red)} .stat.blue .n{color:var(--blue)}
  .callout{border-left:4px solid var(--accent);background:linear-gradient(90deg,#f0f3fe,#fff 60%);border-radius:0 12px 12px 0;padding:14px 20px;margin:0 0 22px}
  .callout .t{font-weight:700} .callout .d{color:var(--muted);font-size:14px;margin-top:2px}
  /* ---- diff façon GitHub ---- */
  .file{background:var(--card);border:1px solid var(--line);border-radius:12px;box-shadow:var(--shadow);margin-bottom:22px;overflow:hidden}
  .fhead{display:flex;align-items:center;gap:10px;padding:10px 14px;border-bottom:1px solid var(--line);background:#f6f8fa;flex-wrap:wrap}
  .fname{font-family:ui-monospace,SFMono-Regular,Menlo,monospace;font-size:12.5px;font-weight:700}
  .badge{font-size:11.5px;font-weight:700;padding:2px 8px;border-radius:20px}
  .b-add{background:var(--green-bg);color:var(--green)} .b-del{background:var(--red-bg);color:var(--red)}
  .b-note{background:#eef1f6;color:var(--muted);font-weight:600}
  table.diff{width:100%;border-collapse:collapse;font-family:ui-monospace,SFMono-Regular,Menlo,monospace;font-size:12px;line-height:1.5}
  .diff td{padding:0 8px;vertical-align:top;border:none}
  .diff td.n{width:1%;min-width:38px;text-align:right;color:var(--numink);user-select:none;background:#f6f8fa;border-right:1px solid var(--line)}
  .diff td.c{white-space:pre-wrap;word-break:break-word;width:98%}
  .diff tr.add td.c{background:var(--add)} .diff tr.add td.n{background:var(--add-num);color:#1a7f37}
  .diff tr.del td.c{background:var(--del)} .diff tr.del td.n{background:var(--del-num);color:#cf222e}
  .diff tr.hunk td{background:var(--hunk);color:var(--hunk-ink);padding:4px 12px;font-size:11.5px}
  .sign{display:inline-block;width:12px}
  /* intra-ligne : le segment qui change dans une paire del/add */
  tr.add .chg{background:var(--add-chg);border-radius:3px;padding:0 1px}
  tr.del .chg{background:var(--del-chg);border-radius:3px;padding:0 1px}
  /* coloration syntaxique */
  .tok-kw{color:var(--kw)} .tok-str{color:var(--str)} .tok-com{color:var(--com);font-style:italic}
  .tok-num{color:var(--num)} .tok-type{color:var(--type)} .tok-fn{color:var(--fn)}
  details.minor{margin-bottom:22px} details.minor summary{cursor:pointer;color:var(--muted);font-size:13px;padding:8px 4px}
  footer{margin-top:36px;color:var(--muted);font-size:12.5px;text-align:center}
</style></head>
<body><div class="wrap">
  <header><div class="kicker">{{KICKER}}</div><h1>{{TITRE}}</h1><p class="sub">{{RÉSUMÉ}}</p></header>
  <div class="stats"><!-- fichiers / +adds / −dels / … --></div>
  <!-- … un .file par fichier, tables .diff … -->
  <footer>{{DATE}} · <code>git diff {{RANGE}}</code> · {{PROVENANCE}}</footer>
</div></body></html>
```

Exemple d'une ligne modifiée complète (les trois couches combinées — diff, intra-ligne, syntaxe) :

```html
<tr class="del"><td class="n">22</td><td class="n"></td><td class="c"><span class="sign">−</span>      <span class="tok-kw">await</span> <span class="tok-type">PowersyncRepository</span>.<span class="tok-fn">init</span>()</td></tr>
<tr class="add"><td class="n"></td><td class="n">22</td><td class="c"><span class="sign">+</span>      <span class="tok-kw">await</span> <span class="tok-type">PowersyncRepository</span>.<span class="tok-fn">init</span>(<span class="chg">logger</span>)</td></tr>
```

## Sauvegarde & ouverture

1. `mkdir -p ~/.claude/tmp` (scratch global — jamais dans le repo).
2. Nom : `~/.claude/tmp/diff-<slug>-$(date +%Y%m%d-%H%M%S).html`.
3. Écris avec `Write`, puis `~/Development/vitrail/view.sh <chemin>` (Vitrail, pas le navigateur par défaut).
4. Confirme en **une ligne** (« Ouvert dans Vitrail ✅ ») + le chemin. Ne re-dumpe pas le diff dans le terminal.
