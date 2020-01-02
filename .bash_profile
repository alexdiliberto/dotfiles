# Update PATH. Add `~/bin`.
PATH="$HOME/bin:$PATH";

if [ -d "/opt/subversion" ]; then
  # Update PATH. Add SVN.
  PATH=/opt/subversion/bin:$PATH
fi

# Go (https://golang.org)
export GOPATH=$HOME/go
# Update PATH. Add Go.
PATH=$PATH:$GOPATH/bin

# Update PATH. Add coreutils.
PATH="$(brew --prefix)/opt/coreutils/libexec/gnubin:$PATH"

# Update PATH. rustup-init
PATH="$HOME/.cargo/bin:$PATH"

# Update PATH. Use rbenv to dynamically select which Ruby to use.
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Load Volta
export VOLTA_HOME="$HOME/.volta"
[ -s "$VOLTA_HOME/load.sh" ] && . "$VOLTA_HOME/load.sh"

# Update PATH. Add Volta.
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

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults;

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall;