export OS="$(uname -s)"; # Ubuntu = Linux / Darwin = macOS

# Update initial PATH
if test "$OS" = "Darwin"; then
  PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
elif test "$OS" = "Linux"; then
  PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin";
fi

# Update PATH. Add `~/bin`.
PATH="$HOME/bin:$PATH";

# Update PATH. Add SVN.
if [ -d "/opt/subversion" ]; then
  PATH=/opt/subversion/bin:$PATH
fi

# Update PATH. Add Go (https://golang.org).
export GOPATH=$HOME/go
PATH=$PATH:$GOPATH/bin

# Update PATH. Add coreutils.
if test "$OS" = "Darwin"; then
  PATH="$(brew --prefix)/opt/coreutils/libexec/gnubin:$PATH";
fi

# Update PATH. rustup-init
PATH="$HOME/.cargo/bin:$PATH"

if which rbenv &> /dev/null; then
  # Update PATH. Use rbenv to dynamically select which Ruby to use.
  eval "$(rbenv init -)"
else
  # Update PATH. Install Ruby Gems to `~/gems`.
  export GEM_HOME="$HOME/gems"
  PATH="$HOME/gems/bin:$PATH"
fi;

# Update PATH. Add and Load Volta
export VOLTA_HOME="$HOME/.volta"
[ -s "$VOLTA_HOME/load.sh" ] && . "$VOLTA_HOME/load.sh"
PATH="$VOLTA_HOME/bin:$PATH"

# Export PATH
export PATH

# https://blog.zzhou612.com/2019/02/26/automatically-sign-commits-using-gpg-suite-on-macos/
GPG_TTY=$(tty)
export GPG_TTY

# Increase ulimit to prevent error `Too many open files in system (ENFILE)``
#   http://blog.mact.me/2014/10/22/yosemite-upgrade-changes-open-file-limit`
ulimit -n 2560

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
  shopt -s "$option" 2> /dev/null;
done;

# Add tab completion for many Bash commands
if which brew &> /dev/null && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
  # Ensure existing Homebrew v1 completions continue to work
  export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d";
  source "$(brew --prefix)/etc/profile.d/bash_completion.sh";
elif [ -f /etc/bash_completion ]; then
  source /etc/bash_completion;
fi;

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null; then
  complete -o default -o nospace -F _git g;
fi;

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null; then
  complete -o default -o nospace -F _git g;
fi;

###-begin-pnpm-completion-###
if type complete &>/dev/null; then
  _pnpm_completion () {
    local words cword
    if type _get_comp_words_by_ref &>/dev/null; then
      _get_comp_words_by_ref -n = -n @ -n : -w words -i cword
    else
      cword="$COMP_CWORD"
      words=("${COMP_WORDS[@]}")
    fi

    local si="$IFS"
    IFS=$'\n' COMPREPLY=($(COMP_CWORD="$cword" \
                           COMP_LINE="$COMP_LINE" \
                           COMP_POINT="$COMP_POINT" \
                           SHELL=bash \
                           pnpm completion-server -- "${words[@]}" \
                           2>/dev/null)) || return $?
    IFS="$si"

    if [ "$COMPREPLY" = "__tabtab_complete_files__" ]; then
      COMPREPLY=($(compgen -f -- "$cword"))
    fi

    if type __ltrim_colon_completions &>/dev/null; then
      __ltrim_colon_completions "${words[cword]}"
    fi
  }
  complete -o default -F _pnpm_completion pnpm
fi
###-end-pnpm-completion-###

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults;

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall;