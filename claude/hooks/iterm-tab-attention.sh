#!/bin/bash
# Assombrit le FOND du pane iTerm2 (OSC 11, par session/pane) pendant que la
# session Claude Code travaille ; retour au fond normal quand elle a vraiment
# fini ou que l'utilisateur a repris la main. Ne touche pas aux couleurs de
# tab gérées par iterm-colors.zsh.
#
# Fond du profil : #FDF6E3 (Solarized Light) → version travail : #CDC5AE
# (~20% plus sombre, même teinte — assez marqué pour se voir sans pane de
# référence à côté).
#
# Règles :
#   - dès que Claude ATTEND l'input utilisateur (fin de tour, idle, prompt de
#     permission), on repasse au clair — même si des tâches background tournent
#     encore. Le pane se re-assombrit tout seul au prochain `work` quand la
#     session reprend vraiment la main. Une tâche bg qui tourne ≠ Claude bosse.
#   - interruption (Esc, Ctrl+C, peu importe la touche) : clair aussi —
#     détectée par l'ÉTAT de la session : le transcript se termine par un
#     marqueur "[Request interrupted…]". Un watchdog par session le surveille
#     chaque seconde tant que le pane est sombre, car aucun hook ne se
#     déclenche de façon fiable sur une interruption.
#
# Modes (hooks) :
#   work      : assombrit le pane + démarre le watchdog s'il ne tourne pas
#   done      : hook Stop — restaure (fin de tour = on attend l'input)
#   interrupt : hook PostToolUseFailure — restaure si is_interrupt (chemin
#               rapide quand un outil était en vol)
#   idle      : hook Notification idle_prompt — restaure
#   clear     : restaure inconditionnellement
#   watchdog  : interne — boucle de surveillance du transcript
#
# État partagé hooks/watchdog : /tmp/claude-attention-<pid claude>.state
# Debug : chaque action logge une ligne dans /tmp/iterm-attention.log.

dark="#CDC5AE"
log=/tmp/iterm-attention.log
mode="$1"

debug() { printf '%s %s %s\n' "$(date '+%H:%M:%S')" "$mode" "$*" >> "$log"; }

last_transcript_msg() { tail -n 30 "$1" 2>/dev/null | grep -E '"type": *"(user|assistant)"' | tail -1; }

# ---- Mode interne : watchdog -----------------------------------------------
if [ "$mode" = "watchdog" ]; then
  cpid="$2" wdev="$3" wtp="$4"
  state="/tmp/claude-attention-$cpid.state"
  lock="/tmp/claude-attention-$cpid.watchdog"
  debug "démarré pour claude($cpid) sur $wdev"
  while kill -0 "$cpid" 2>/dev/null; do
    if [ "$(cat "$state" 2>/dev/null)" = "dark" ]; then
      case "$(last_transcript_msg "$wtp")" in
        *'[Request interrupted'*)
          printf '\033]111\a' > "$wdev" 2>/dev/null
          echo clear > "$state"
          debug "interruption détectée, restauré sur $wdev"
          ;;
      esac
    fi
    sleep 1
  done
  rm -f "$lock" "$state"
  debug "claude($cpid) terminé, watchdog arrêté"
  exit 0
fi

# ---- Lecture du JSON du hook sur stdin --------------------------------------
input=""
[ ! -t 0 ] && input=$(cat)
tp=$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null)

interrupted=0
if [ -n "$tp" ] && [ -f "$tp" ]; then
  case "$(last_transcript_msg "$tp")" in
    *'[Request interrupted'*) interrupted=1 ;;
  esac
fi

case "$mode" in
  interrupt)
    if [ -n "$input" ]; then
      int=$(printf '%s' "$input" | jq -r '.is_interrupt // false' 2>/dev/null)
      if [ "$int" != "true" ]; then
        debug "skip: is_interrupt=$int"
        exit 0
      fi
    fi
    ;;
esac

# ---- Trouver le TTY du processus claude (les hooks n'en ont pas) ------------
pid=$$
dev=""
while [ -n "$pid" ] && [ "$pid" -gt 1 ]; do
  tty=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
  if [ -n "$tty" ] && [ "$tty" != "??" ]; then
    dev="/dev/$tty"
    break
  fi
  pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
done

if [ -z "$dev" ] || [ ! -w "$dev" ]; then
  debug "skip: pas de TTY accessible (dev=$dev)"
  exit 0
fi

state="/tmp/claude-attention-$pid.state"
lock="/tmp/claude-attention-$pid.watchdog"

# ---- Agir sur le fond du pane ------------------------------------------------
if [ "$mode" = "work" ]; then
  printf '\033]11;%s\a' "$dark" > "$dev"
  echo dark > "$state"
  debug "assombri sur $dev"
  wpid=$(cat "$lock" 2>/dev/null)
  if { [ -z "$wpid" ] || ! kill -0 "$wpid" 2>/dev/null; } && [ -n "$tp" ]; then
    nohup "$0" watchdog "$pid" "$dev" "$tp" </dev/null >/dev/null 2>&1 &
    echo $! > "$lock"
    debug "watchdog lancé (pid $!)"
  fi
else
  printf '\033]111\a' > "$dev"
  echo clear > "$state"
  debug "restauré sur $dev (interrupted=$interrupted)"
fi

exit 0
