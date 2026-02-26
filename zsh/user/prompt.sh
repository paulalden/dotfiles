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

# -- Async git info -----------------------------------------------------------
_prompt_git_info=""
_prompt_async_fd=""

_prompt_git_worker() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  [[ -z "$branch" ]] && { print "NONE"; return }

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

  print "${branch}${status_str}"
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

_prompt_async_start() {
  # Clean up any existing worker
  if [[ -n "$_prompt_async_fd" ]] && { true <&$_prompt_async_fd } 2>/dev/null; then
    zle -F $_prompt_async_fd
    exec {_prompt_async_fd}<&-
  fi
  _prompt_async_fd=""

  # Only start if we're in a git repo
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    _prompt_git_info=""
    return
  fi

  exec {_prompt_async_fd} < <(_prompt_git_worker)
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

  _prompt_format_git "$result"
  zle reset-prompt
}

# -- Language versions --------------------------------------------------------
_prompt_ruby_version() {
  local ver
  ver=$(ruby -e 'print RUBY_VERSION' 2>/dev/null) || return
  [[ -n "$ver" ]] && print "${ver}"
}

_prompt_node_version() {
  local ver
  ver=$(node --version 2>/dev/null) || return
  [[ -n "$ver" ]] && print "${ver#v}"
}

# -- Build prompt -------------------------------------------------------------
_prompt_precmd() {
  # Async git (non-blocking)
  _prompt_async_start

  # Language versions (cached per directory)
  if [[ "$PWD" != "$_prompt_lang_pwd" ]]; then
    _prompt_lang_pwd="$PWD"
    _prompt_ruby_cache=""
    _prompt_node_cache=""
    [[ -f Gemfile || -f .ruby-version ]] && _prompt_ruby_cache=$(_prompt_ruby_version)
    [[ -f package.json || -f .node-version || -f .nvmrc ]] && _prompt_node_cache=$(_prompt_node_version)
  fi

  # SSH hostname
  local host=""
  [[ -n "$SSH_TTY" ]] && host="%m "

  # Directory (full path, bold grey)
  local dir="${_prompt_grey}%B%~%b${_prompt_reset}"

  # Prompt character (red on error)
  local char="%(?:%F{white}:%F{red})❯${_prompt_reset}"

  # Language version indicators (magenta)
  local langs=""
  [[ -n "$_prompt_ruby_cache" ]] && langs+="${_prompt_magenta}${_prompt_ruby_cache}${_prompt_reset} "
  [[ -n "$_prompt_node_cache" ]] && langs+="${_prompt_magenta}${_prompt_node_cache}${_prompt_reset} "

  PROMPT=$'\n'"${host}${dir} \${_prompt_git_info}${langs}
${char} "
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _prompt_precmd
