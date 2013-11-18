# Aliases
alias redo='sudo \!-1'
alias rmlog="sudo rm /var/log/asl/*" #clear out old log files

# Easier navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Better file listing
alias ls="ls -G" # list
alias la="ls -Ga" # list all, includes dot files
alias ll="ls -Gl" # long list, excludes dot files
alias lla="ls -Gla" # long list all, includes dot files

# Stopwatch
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date' # Stopwatch

# Gzip-enabled `curl`
alias gurl='curl --compressed'

# Get week number
alias week='date +%V'

alias stfu="osascript -e 'set volume output muted true'"
alias pumpitup="sudo osascript -e 'set volume 10'"

alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"
alias flush="dscacheutil -flushcache" # Flush DNS cache

alias gzip="gzip -9n" # set strongest compression level as ‘default’ for gzip
alias ping="ping -c 5" # ping 5 times ‘by default’
alias ql="qlmanage -p 2>/dev/null" # preview a file using QuickLook

alias gemlist='gem list | egrep -v "^( |$)"'
alias top='top -ocpu'

# Kill all the tabs in Chrome to free up memory
# [C] explained: http://www.commandlinefu.com/commands/view/402/exclude-grep-from-your-grepped-output-of-ps-alias-included-in-description
alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"

# Bundler Aliases
alias bi='echo Running: bundle install... ; bundle install ;'
alias brb='echo Running: bundle exec rake build... ; bundle exec rake build ;'
alias brc='echo Running: bundle exec rake clean... ; bundle exec rake clean ;'
alias bg='echo Running: bundle exec guard... ; bundle exec guard ;'

# Git Aliases
alias gb='git branch'
alias gba='git branch -a'
alias gcav='git commit -av'
alias gca='git commit -a'
alias gd='git diff | subl'
alias gdc='git diff --cached | subl'
alias gp?='git log --pretty=oneline origin/master..HEAD'
alias gs='git status'
alias gpom='git pull origin master'
alias gf='git fetch origin -v'
alias gfu='git fetch upstream -v'

# Get OS X Software Updates, and update installed Ruby gems, Homebrew, npm, and their installed packages
alias update='sudo softwareupdate -i -a; brew update; brew upgrade `brew outdated`; brew cleanup; npm update npm -g; sudo npm update -g; sudo gem update --system; sudo gem update;'

# HomeBrew Aliases
alias bu='brew update && brew upgrade `brew outdated`'

# Gem Aliases
alias gu='gem update --system; gem update;'

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Make Grunt print stack traces by default
command -v grunt > /dev/null && alias grunt="grunt --stack"

# Canonical hex dump; some systems have this symlinked
command -v hd > /dev/null || alias hd="hexdump -C"

# OS X has no `md5sum`, so use `md5` as a fallback
command -v md5sum > /dev/null || alias md5sum="md5"

# OS X has no `sha1sum`, so use `shasum` as a fallback
command -v sha1sum > /dev/null || alias sha1sum="shasum"


# Functions
# Simple calculator
function calc() {
  local result=""
  result="$(printf "scale=10;$*\n" | bc --mathlib | tr -d '\\\n')"
  #                       └─ default (when `--mathlib` is used) is 20
  #
  if [[ "$result" == *.* ]]; then
    # improve the output for decimal numbers
    printf "$result" |
    sed -e 's/^\./0./'        `# add "0" for cases like ".5"` \
        -e 's/^-\./-0./'      `# add "0" for cases like "-.5"`\
        -e 's/0*$//;s/\.$//'   # remove trailing zeros
  else
    printf "$result"
  fi
  printf "\n"
}

# Apply SSH
function apply_ssh() {
  ssh $1 "cat >> ~/.ssh/authorized_keys" < ~/.ssh/id_rsa.pub
}

# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
function tre() {
  tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX
}

# Install Grunt plugins and add them as `devDependencies` to `package.json`
# Usage: `gi contrib-watch contrib-uglify zopfli`
function gi() {
  local IFS=,
  eval npm install --save-dev grunt-{"$*"}
}

# `s` with no arguments opens the current directory in Sublime Text, otherwise
# opens the given location
function s() {
  if [ $# -eq 0 ]; then
    subl .
  else
    subl "$@"
  fi
}

# `o` with no arguments opens current directory, otherwise opens the given
# location
function o() {
  if [ $# -eq 0 ]; then
    open .
  else
    open "$@"
  fi
}

# Create a git.io short URL
function gitio() {
  if [ -z "${1}" -o -z "${2}" ]; then
    echo "Usage: \`gitio slug url\`"
    return 1
  fi
  curl -i http://git.io/ -F "url=${2}" -F "code=${1}"
}

# Preview man page
function pman() {
  man -t "${1}" | open -f -a /Applications/Preview.app/
}

# Create a new directory and enter it
function mkd() {
  mkdir -p "$@" && cd "$@"
}

# Change working directory to the top-most Finder window location
function cdf() { # short for `cdfinder`
  cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')"
}

# Create a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
function targz() {
  local tmpFile="${@%/}.tar"
  tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1

  size=$(
    stat -f"%z" "${tmpFile}" 2> /dev/null; # OS X `stat`
    stat -c"%s" "${tmpFile}" 2> /dev/null # GNU `stat`
  )

  local cmd=""
  if (( size < 52428800 )) && hash zopfli 2> /dev/null; then
    # the .tar file is smaller than 50 MB and Zopfli is available; use it
    cmd="zopfli"
  else
    if hash pigz 2> /dev/null; then
      cmd="pigz"
    else
      cmd="gzip"
    fi
  fi

  echo "Compressing .tar using \`${cmd}\`…"
  "${cmd}" -v "${tmpFile}" || return 1
  [ -f "${tmpFile}" ] && rm "${tmpFile}"
  echo "${tmpFile}.gz created successfully."
}

# Compare original and gzipped file size
function gz() {
  local origsize=$(wc -c < "$1")
  local gzipsize=$(gzip -c "$1" | wc -c)
  local ratio=$(echo "$gzipsize * 100/ $origsize" | bc -l)
  printf "orig: %d bytes\n" "$origsize"
  printf "gzip: %d bytes (%2.2f%%)\n" "$gzipsize" "$ratio"
}

# Syntax-highlight JSON strings or files
# Usage: `json '{"foo":42}'`
#        `echo '{"foo":42}' | json`
#        `json < file.json`
function json() {
  if [ -t 0 ]; then # argument
    python -mjson.tool <<< "$*" | pygmentize -l javascript
  else # pipe
    python -mjson.tool | pygmentize -l javascript
  fi
}

# Create a data URL from a file
function dataurl() {
  local mimeType=$(file -b --mime-type "$1")
  if [[ $mimeType == text/* ]]; then
    mimeType="${mimeType};charset=utf-8"
  fi
  echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}

# Escape UTF-8 characters into their 3-byte format
function escape() {
  printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u)
  # print a newline unless we’re piping the output to another program
  if [ -t 1 ]; then
    echo # newline
  fi
}

# Show all the names (CNs and SANs) listed in the SSL certificate
# for a given domain
function getcertnames() {
  if [ -z "${1}" ]; then
    echo "ERROR: No domain specified."
    return 1
  fi

  local domain="${1}"
  echo "Testing ${domain}…"
  echo # newline

  local tmp=$(echo -e "GET / HTTP/1.0\nEOT" \
    | openssl s_client -connect "${domain}:443" 2>&1);

  if [[ "${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
    local certText=$(echo "${tmp}" \
      | openssl x509 -text -certopt "no_header, no_serial, no_version, \
      no_signame, no_validity, no_issuer, no_pubkey, no_sigdump, no_aux");
      echo "Common Name:"
      echo # newline
      echo "${certText}" | grep "Subject:" | sed -e "s/^.*CN=//";
      echo # newline
      echo "Subject Alternative Name(s):"
      echo # newline
      echo "${certText}" | grep -A 1 "Subject Alternative Name:" \
        | sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\n" | tail -n +2
      return 0
  else
    echo "ERROR: Certificate not found.";
    return 1
  fi
}

# Determine size of a file or total size of a directory
function fs() {
  if du -b /dev/null > /dev/null 2>&1; then
    local arg=-sbh
  else
    local arg=-sh
  fi
  if [[ -n "$@" ]]; then
    du $arg -- "$@"
  else
    du $arg .[^.]* *
  fi
}

# Start an HTTP server from a directory, optionally specifying the port
function server() {
  local port="${1:-8000}"
  sleep 1 && open "http://localhost:${port}/" &
  # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
  # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
  python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"
}


# Shell options
shopt -s histappend
set +o histexpand # enable strings with !


# Build PATH
PATH=/usr/local/heroku/bin:/usr/local/share/npm/bin:/usr/local/bin:/usr/local/sbin:~/bin:/usr/bin:/bin:/usr/sbin:/sbin
if [ -d "/opt/subversion" ]; then
  PATH=/opt/subversion/bin:$PATH
fi

# Update PATH. Use rbenv to dynamically select which Ruby to use.
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Export ENV variables
export PATH
export HISTSIZE=100000
export HISTFILESIZE=409600
export HISTIGNORE="cd:ls:[bf]g:clear:exit:gp:gs:ll"
export HISTCONTROL=ignoredups
export EDITOR="subl -w"
export VISUAL="subl -w"
export PAGER="less"
export CLICOLOR="yes"
export JAVA_HOME='/System/Library/Frameworks/JavaVM.framework/Home'
export PROMPT_COLOR='1;1;40m';

# Support brew bash completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

# Support NPM bash completion
if npm -v >/dev/null 2>&1; then
  ###-begin-npm-completion-###
  #
  # npm command completion script
  #
  # Installation: npm completion >> ~/.bashrc  (or ~/.zshrc)
  # Or, maybe: npm completion > /usr/local/etc/bash_completion.d/npm
  #

  COMP_WORDBREAKS=${COMP_WORDBREAKS/=/}
  COMP_WORDBREAKS=${COMP_WORDBREAKS/@/}
  export COMP_WORDBREAKS

  if type complete &>/dev/null; then
    _npm_completion () {
      local si="$IFS"
      IFS=$'\n' COMPREPLY=($(COMP_CWORD="$COMP_CWORD" \
                             COMP_LINE="$COMP_LINE" \
                             COMP_POINT="$COMP_POINT" \
                             npm completion -- "${COMP_WORDS[@]}" \
                             2>/dev/null)) || return $?
      IFS="$si"
    }
    complete -F _npm_completion npm
  elif type compdef &>/dev/null; then
    _npm_completion() {
      si=$IFS
      compadd -- $(COMP_CWORD=$((CURRENT-1)) \
                   COMP_LINE=$BUFFER \
                   COMP_POINT=0 \
                   npm completion -- "${words[@]}" \
                   2>/dev/null)
      IFS=$si
    }
    compdef _npm_completion npm
  elif type compctl &>/dev/null; then
    _npm_completion () {
      local cword line point words si
      read -Ac words
      read -cn cword
      let cword-=1
      read -l line
      read -ln point
      si="$IFS"
      IFS=$'\n' reply=($(COMP_CWORD="$cword" \
                         COMP_LINE="$line" \
                         COMP_POINT="$point" \
                         npm completion -- "${words[@]}" \
                         2>/dev/null)) || return $?
      IFS="$si"
    }
    compctl -K _npm_completion npm
  fi
  ###-end-npm-completion-###
fi

# Checks that the child directory is a subdirectory of the parent
is_subdirectory() {
    local child="$1"
    local parent="$2"
    if [[ "${child##${parent}}" != "$child" ]]; then
        return 0
    else
        return 1
    fi
}

# Activates a new environment
activate_env() {
    # Check if the directory we've cd'ed into is a node environment directory
    # (i.e., it contains a node_modules folder) and that a node envrionment
    # does not already exist before creating a new one.
    if [ -d "node_modules" ] && [ -z "$_ENV_DIR" ]; then

        # Save the old PATH variable so we can revert back to it when we leave
        # the environment
        export _OLD_PATH="$PATH"

        # An environment is essentially nothing more than an environment
        # variable (_ENV_DIR) pointing the parent directory of our node
        # environment. Create the variable and point it to $PWD.
        export _ENV_DIR="$PWD"

        # Add the bin folder for all local NPM installs to the PATH
        export PATH="$(npm bin):$PATH"

        # If an activation script exists, execute it
        if [ -e ".activate" ]; then
            source .activate
        fi
    fi
}

# Deactivates the current envrionment
deactivate_env() {
    # Make sure that an envrionment does exist and that the new
    # directory is not a subdirectory of the envrionment directory
    if [ -n "$_ENV_DIR" ] && ! is_subdirectory "$PWD" "$_ENV_DIR"; then

        # Run the deactivation script if it exists
        if [[ -e "$_ENV_DIR/.deactivate" ]]; then
            source "$_ENV_DIR/.deactivate"
        fi

        # Revert back to the original PATH
        export PATH="$_OLD_PATH"

        # Destroy the environment
        unset _ENV_DIR
        unset _OLD_PATH
    fi
}

env_cd() {
    builtin cd "$@" && deactivate_env && activate_env
}

alias cd="env_cd"
