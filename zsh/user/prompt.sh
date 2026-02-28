################################################################################
# Pure ZSH prompt (replaces Starship)
# Features: directory, git branch, git status, ruby/node version, ssh hostname
################################################################################

setopt PROMPT_SUBST

# -- Colors (Nord palette) ----------------------------------------------------
_prompt_grey="%F{#4C566A}"
_prompt_blue="%F{#5E81AC}"
_prompt_magenta="%F{#B48EAD}"
_prompt_reset="%f"

# -- Async worker -------------------------------------------------------------
_prompt_git_info=""
_prompt_lang_info=""
_prompt_async_fd=""

_prompt_async_worker() {
  # Git info
  local git_result="NONE"
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  if [[ -n "$branch" ]]; then
    local staged=0 modified=0 untracked=0 ahead=0 behind=0
    local line
    while IFS= read -r line; do
      case "${line:0:2}" in
        "##"*)
          [[ "$line" =~ "ahead ([0-9]+)" ]] && ahead=${match[1]}
          [[ "$line" =~ "behind ([0-9]+)" ]] && behind=${match[1]}
          ;;
        [ADMRC]?" "|[ADMRC][ADMRC]*) ((staged++)) ;;
      esac
      case "${line:1:1}" in
        M|D) ((modified++)) ;;
      esac
      case "${line:0:2}" in
        "??") ((untracked++)) ;;
      esac
    done < <(git status --porcelain=v2 --branch 2>/dev/null)

    local status_str=""
    ((staged > 0))    && status_str+=" +${staged}"
    ((modified > 0))  && status_str+=" !${modified}"
    ((untracked > 0)) && status_str+=" ?${untracked}"
    ((ahead > 0))     && status_str+=" ⇡${ahead}"
    ((behind > 0))    && status_str+=" ⇣${behind}"

    git_result="${branch}${status_str}"
  fi

  # Language versions (only check if relevant files exist)
  local ruby_ver="" node_ver=""
  [[ -f Gemfile || -f .ruby-version ]] && ruby_ver=$(ruby -e 'print RUBY_VERSION' 2>/dev/null)
  [[ -f package.json || -f .node-version || -f .nvmrc ]] && node_ver=$(node --version 2>/dev/null) && node_ver="${node_ver#v}"

  # Output all results on one line, tab-separated
  print "${git_result}\t${ruby_ver}\t${node_ver}"
}

_prompt_format_git() {
  local result=$1
  if [[ "$result" == "NONE" || -z "$result" ]]; then
    _prompt_git_info=""
    return
  fi
  local branch="${result%% *}"
  local status_part="${result#$branch}"
  _prompt_git_info="${_prompt_blue}${branch}${_prompt_reset}"
  if [[ -n "$status_part" ]]; then
    _prompt_git_info+=" ${_prompt_grey}[${status_part# }]${_prompt_reset}"
  fi
  _prompt_git_info+=" "
}

_prompt_format_langs() {
  local ruby=$1 node=$2
  _prompt_lang_info=""
  [[ -n "$ruby" ]] && _prompt_lang_info+="${_prompt_magenta}${ruby}${_prompt_reset} "
  [[ -n "$node" ]] && _prompt_lang_info+="${_prompt_magenta}${node}${_prompt_reset} "
}

_prompt_async_start() {
  # Clean up any existing worker
  if [[ -n "$_prompt_async_fd" ]] && { true <&$_prompt_async_fd } 2>/dev/null; then
    zle -F $_prompt_async_fd
    exec {_prompt_async_fd}<&-
  fi
  _prompt_async_fd=""

  exec {_prompt_async_fd} < <(_prompt_async_worker)
  zle -F $_prompt_async_fd _prompt_async_callback
}

_prompt_async_callback() {
  local fd=$1
  local result=""
  IFS= read -r -u "$fd" result
  # Clean up fd
  zle -F "$fd"
  exec {fd}<&-
  _prompt_async_fd=""

  # Parse tab-separated results
  local git_part="${result%%	*}"
  local rest="${result#*	}"
  local ruby_part="${rest%%	*}"
  local node_part="${rest#*	}"

  _prompt_format_git "$git_part"
  _prompt_format_langs "$ruby_part" "$node_part"
  zle reset-prompt
}

# -- Build prompt -------------------------------------------------------------
_prompt_precmd() {
  # Async git + language versions (non-blocking)
  _prompt_async_start

  # SSH hostname
  local host=""
  [[ -n "$SSH_TTY" ]] && host="%m "

  # Directory (full path, bold grey)
  local dir="${_prompt_grey}%B%~%b${_prompt_reset}"

  # Prompt character (red on error)
  local char="%(?:%F{white}:%F{red})❯${_prompt_reset}"

  PROMPT=$'\n'"${host}${dir} \${_prompt_git_info}\${_prompt_lang_info}
${char} "
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _prompt_precmd
