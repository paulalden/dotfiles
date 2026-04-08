#!/usr/bin/env bash
# Claude Code statusLine — mirrors the ZSH prompt style (Nord palette)
# Receives JSON on stdin

input=$(cat)

# -- Extract fields from JSON --------------------------------------------------
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
rate_pct=$(echo "$input" | jq -r '
  (.rate_limits // []) |
  if type == "array" then .[0].used_percentage
  elif type == "object" then (.five_hour // .hour_5 // .[keys[0]]).used_percentage
  else empty
  end // empty' 2>/dev/null)

# -- Directory (shorten $HOME to ~) -------------------------------------------
home="$HOME"
dir="${cwd/#$home/\~}"

# -- Git info (skip optional locks for speed) ----------------------------------
git_info=""
if branch=$(git --git-dir="$cwd/.git" --work-tree="$cwd" symbolic-ref --short HEAD 2>/dev/null \
            || git --git-dir="$cwd/.git" --work-tree="$cwd" rev-parse --short HEAD 2>/dev/null); then
  staged=0; modified=0; untracked=0; ahead=0; behind=0
  while IFS= read -r line; do
    case "${line:0:2}" in
      "##"*)
        [[ "$line" =~ ahead\ ([0-9]+) ]]  && ahead="${BASH_REMATCH[1]}"
        [[ "$line" =~ behind\ ([0-9]+) ]] && behind="${BASH_REMATCH[1]}"
        ;;
      [ADMRC]\ |[ADMRC][ADMRC]*) ((staged++)) ;;
    esac
    case "${line:1:1}" in M|D) ((modified++)) ;; esac
    case "${line:0:2}" in "??") ((untracked++)) ;; esac
  done < <(git -C "$cwd" -c gc.auto=0 status --porcelain=v2 --branch 2>/dev/null)

  status_str=""
  ((staged    > 0)) && status_str+=" +${staged}"
  ((modified  > 0)) && status_str+=" !${modified}"
  ((untracked > 0)) && status_str+=" ?${untracked}"
  ((ahead     > 0)) && status_str+=" ⇡${ahead}"
  ((behind    > 0)) && status_str+=" ⇣${behind}"

  if [[ -n "$status_str" ]]; then
    git_info="${branch} [${status_str# }]"
  else
    git_info="${branch}"
  fi
fi

# -- Assemble output (ANSI: Nord palette, dimmed-friendly) ---------------------
# Grey  = \e[2;37m  (dim white, close to #4C566A feel in terminals)
# Blue  = \e[34m    (branch, close to #5E81AC)
# Magenta = \e[35m  (model, close to #B48EAD)
# Reset = \e[0m

GREY='\e[2;37m'
BLUE='\e[34m'
MAGENTA='\e[35m'
ORANGE='\e[38;5;208m'
RED='\e[31m'
RESET='\e[0m'

parts=()

# Directory
parts+=("${GREY}${dir}${RESET}")

# Git
[[ -n "$git_info" ]] && parts+=("${BLUE}${git_info}${RESET}")

# Model
[[ -n "$model" ]] && parts+=("${MAGENTA}${model}${RESET}")

# -- Combined context + rate-limit segment ------------------------------------
# Format: "Context:X% · Usage:5h:X%"
# Color is driven by whichever percentage is higher; thresholds 70% = orange, 90% = red.
# Either half is omitted gracefully when the data is absent.
combined_str=""
if [[ -n "$used_pct" ]]; then
  combined_str="Context:$(printf '%.0f' "$used_pct")%"
fi
if [[ -n "$rate_pct" ]]; then
  rate_part="Usage:5h:$(printf '%.0f' "$rate_pct")%"
  if [[ -n "$combined_str" ]]; then
    combined_str="${combined_str} · ${rate_part}"
  else
    combined_str="$rate_part"
  fi
fi

if [[ -n "$combined_str" ]]; then
  # Determine the higher of the two percentages to pick colour
  ctx_int=0
  rate_int=0
  [[ -n "$used_pct" ]] && ctx_int=$(printf '%.0f' "$used_pct")
  [[ -n "$rate_pct" ]] && rate_int=$(printf '%.0f' "$rate_pct")
  higher=$(( ctx_int > rate_int ? ctx_int : rate_int ))

  if (( higher >= 90 )); then
    combined_color=$RED
  elif (( higher >= 70 )); then
    combined_color=$ORANGE
  else
    combined_color=$GREY
  fi
  parts+=("${combined_color}${combined_str}${RESET}")
fi

# Join with separator
output=""
for part in "${parts[@]}"; do
  [[ -n "$output" ]] && output+=" ${GREY}·${RESET} "
  output+="$part"
done

printf "%b\n" "$output"
