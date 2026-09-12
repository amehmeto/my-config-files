---
description: Rend ma réponse/analyse en une page HTML light-theme graphique et l'ouvre dans Vitrail, l'app macOS dédiée à onglets (quand l'output serait trop long pour le terminal). Argument = sujet/portion à rendre ; vide = ma dernière analyse longue.
argument-hint: "[sujet à rendre — vide = dernière réponse longue]"
allowed-tools: Write, Bash(mkdir:*), Bash(~/.claude/tools/html-viewer/view.sh:*), Bash(date:*)
---

Transforme un contenu long en **une page HTML autonome, light-theme et graphique**, sauve-la, et ouvre-la dans le navigateur. But : sortir l'analyse du terminal sans rien perdre.

## Quoi rendre

- Si `$ARGUMENTS` est non vide → c'est le **sujet ou la consigne** (ex. « le plan de migration », « juste le tableau comparatif »). Rends cette portion-là.
- Si `$ARGUMENTS` est vide → rends **ma dernière analyse / réponse longue** de la conversation (la plus récente qui mérite un format visuel).

Ne réécris pas le fond : **traduis** le markdown en composants visuels (ne te contente pas de coller du texte brut).

## Règles de rendu

1. **Autonome** : un seul fichier `.html`, **zéro ressource externe** (pas de CDN, pas de `<script src>`, pas de webfont distante). Tout le CSS inline dans `<style>`. Doit s'ouvrir hors-ligne.
2. **Light theme** uniquement, responsive, police système.
3. **Traduis en composants**, pas en prose :
   - chiffres-clés → **stat pills** en haut
   - statuts (fait / à faire / attention) → **pills colorées** `ok` / `todo` / `warn`
   - comparaisons / matrices → **`<table>`**
   - point saillant / piège / décision → **callout** à barre latérale
   - étapes ou process / parallélisation → **lanes** ou **steps numérotés**
   - listes d'items courts → **chips**
4. **Titre** clair en `<h1>` + un kicker (sur-titre) + une phrase de résumé.
5. **Footer** : date du jour + une ligne de provenance.
6. N'invente pas de données : ne mets que ce qui est dans le contenu source.

## Design system (base à réutiliser telle quelle)

Pars de ce squelette — garde les variables et les classes, ajoute/retire des composants selon le contenu :

```html
<!DOCTYPE html>
<html lang="fr"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{TITRE}}</title>
<style>
  :root{
    --bg:#f7f8fa; --card:#fff; --ink:#1c2330; --muted:#5b6675; --line:#e6e9ef;
    --accent:#4f6bed; --green:#1f9d6b; --green-bg:#e6f6ef; --amber:#c2870b; --amber-bg:#fdf3df;
    --red:#d0463f; --red-bg:#fce9e8; --blue:#3b6fd4; --blue-bg:#e9f0fc; --purple:#7a52c7;
    --shadow:0 1px 3px rgba(18,30,55,.06),0 8px 24px rgba(18,30,55,.05);
  }
  *{box-sizing:border-box}
  body{margin:0;background:var(--bg);color:var(--ink);
    font:15px/1.55 -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;-webkit-font-smoothing:antialiased}
  .wrap{max-width:1080px;margin:0 auto;padding:40px 28px 80px}
  .kicker{font-size:12px;letter-spacing:.14em;text-transform:uppercase;color:var(--accent);font-weight:700}
  h1{font-size:30px;margin:6px 0 8px;letter-spacing:-.02em}
  .sub{color:var(--muted);max-width:720px}
  .card{background:var(--card);border:1px solid var(--line);border-radius:14px;padding:22px;box-shadow:var(--shadow);margin-bottom:18px}
  .card h2{font-size:13px;text-transform:uppercase;letter-spacing:.08em;color:var(--muted);margin:0 0 16px;font-weight:700}
  .grid{display:grid;gap:18px}
  @media(min-width:760px){.cols-2{grid-template-columns:1fr 1fr}}
  /* stat pills */
  .stats{display:flex;gap:12px;flex-wrap:wrap;margin:24px 0}
  .stat{flex:1 1 150px;background:var(--card);border:1px solid var(--line);border-radius:12px;padding:14px 16px;box-shadow:var(--shadow)}
  .stat .n{font-size:26px;font-weight:800;letter-spacing:-.02em}
  .stat .l{font-size:12px;color:var(--muted);margin-top:2px}
  .stat.green .n{color:var(--green)} .stat.red .n{color:var(--red)}
  .stat.amber .n{color:var(--amber)} .stat.blue .n{color:var(--blue)}
  /* status pills */
  .pill{display:inline-flex;align-items:center;gap:6px;font-size:12.5px;font-weight:700;padding:4px 10px;border-radius:20px;white-space:nowrap}
  .pill.ok{background:var(--green-bg);color:var(--green)}
  .pill.todo{background:var(--red-bg);color:var(--red)}
  .pill.warn{background:var(--amber-bg);color:var(--amber)}
  /* chips */
  .chip{display:inline-block;font-size:12px;font-weight:600;padding:2px 8px;border-radius:20px;background:#eef1f6;color:var(--muted);border:1px solid var(--line)}
  /* table */
  table{width:100%;border-collapse:collapse;font-size:14px}
  th{text-align:left;font-size:11px;text-transform:uppercase;letter-spacing:.06em;color:var(--muted);padding:0 10px 10px;border-bottom:1px solid var(--line)}
  td{padding:12px 10px;border-bottom:1px solid var(--line);vertical-align:middle}
  tr:last-child td{border-bottom:none}
  td .note{color:var(--muted);font-size:12.5px}
  /* callout */
  .callout{border-left:4px solid var(--accent);background:linear-gradient(90deg,#f0f3fe,#fff 60%);border-radius:0 12px 12px 0;padding:16px 20px;margin-bottom:18px}
  .callout.warn{border-left-color:var(--amber);background:linear-gradient(90deg,#fdf6e6,#fff 60%)}
  .callout .t{font-weight:700}
  .callout .d{color:var(--muted);font-size:14px;margin-top:2px}
  .callout code,td code,.sub code{background:#eceff5;padding:1px 6px;border-radius:5px;font-size:12.5px}
  /* numbered steps */
  .step{display:flex;gap:16px;padding:14px 0;border-top:1px dashed var(--line)}
  .step:first-child{border-top:none}
  .step .num{flex:0 0 30px;height:30px;border-radius:50%;background:var(--accent);color:#fff;font-weight:800;display:grid;place-items:center;font-size:14px}
  .step .h{font-weight:600}
  .step .p{color:var(--muted);font-size:13.5px;margin-top:1px}
  /* lanes (parallélisation) */
  .lanes{display:grid;gap:14px}
  @media(min-width:720px){.lanes{grid-template-columns:repeat(3,1fr)}}
  .lane{border:1px solid var(--line);border-radius:12px;padding:14px 15px;background:#fcfdff}
  .lane.foundation{border-color:#cdd8f5;background:linear-gradient(180deg,#f2f5fe,#fcfdff)}
  .lane .ln{font-size:11px;font-weight:700;letter-spacing:.06em;text-transform:uppercase;color:var(--accent)}
  .lane .pr{font-weight:700;margin-top:4px}
  .lane .ds{color:var(--muted);font-size:12.5px;margin-top:4px}
  footer{margin-top:36px;color:var(--muted);font-size:12.5px;text-align:center}
</style></head>
<body><div class="wrap">
  <header><div class="kicker">{{KICKER}}</div><h1>{{TITRE}}</h1><p class="sub">{{RÉSUMÉ}}</p></header>
  <!-- … composants … -->
  <footer>{{DATE}} · {{PROVENANCE}}</footer>
</div></body></html>
```

## Sauvegarde & ouverture

1. `mkdir -p ~/.claude/tmp` (dossier scratch global — **jamais** dans le repo, pour ne rien polluer/committer).
2. Nom de fichier : `~/.claude/tmp/<slug>-$(date +%Y%m%d-%H%M%S).html`, où `<slug>` est un kebab-case court tiré du titre.
3. Écris le fichier avec `Write`.
4. `~/.claude/tools/html-viewer/view.sh <chemin>` — ouvre la page dans **Vitrail**, l'app macOS dédiée à onglets (`/Applications/Vitrail.app`, pas le navigateur par défaut). Le premier appel lance Vitrail ; les suivants ajoutent un onglet à la même fenêtre. Onglets fermables (croix, `Cmd+W`), navigables (`Cmd+1..9`), rechargeables (`Cmd+R`).
5. Confirme en **une ligne** (« Ouvert dans Vitrail ✅ ») + donne le chemin du fichier. Pas de re-dump du contenu dans le terminal — c'est tout l'intérêt.
