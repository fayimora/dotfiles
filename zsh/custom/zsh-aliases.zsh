# Global aliases
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
# alias -g C='| wc -l'
# alias -g H='| head'
# alias -g L="| less"
# alias -g N="| /dev/null"
# alias -g S='| sort'
# alias -g G='| grep' # now you can do: ls foo G something

# Functions
#
# (f)ind by (n)ame
# usage: fn foo 
# to find all files containing 'foo' in the name
function fn() { ls **/*$1* }

# Usage: stagedpatch [base-name]
# Examples:
#   stagedpatch                 -> staged-20260105-143012.patch
#   stagedpatch hotfix          -> hotfix-20260105-143012.patch
#   stagedpatch hotfix.patch    -> hotfix-20260105-143012.patch
stagedpatch() {
  local base="${1:-staged}"
  base="${base%.patch}"                 # strip trailing .patch if provided
  local ts
  ts="$(date +%Y%m%d-%H%M%S)"
  local out="${base}-${ts}.patch"

  git diff --cached --binary > "$out" || return
  echo "Wrote staged patch to: $out"
}

# Initial solution from https://johnnymatthews.dev/blog/2025-10-02-open-neovim-at-specified-directory/
# but extended it to work for files
nvim() {
  if [ $# -eq 1 ]; then
    if [ -d "$1" ]; then
      # Argument is a directory - cd into it
      command nvim -c "cd $1"
    elif [ -f "$1" ]; then
      # Argument is a file - cd into its parent directory and open the file
      local dir
      dir=$(dirname "$1")
      command nvim -c "cd $dir" "$1"
    else
      # File/dir doesn't exist yet, just pass through
      command nvim "$@"
    fi
  else
    command nvim "$@"
  fi
}
