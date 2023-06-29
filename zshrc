# Find and set branch name var if in git repository.
function git_branch_name()
{
  branch=$(git symbolic-ref HEAD 2> /dev/null | awk 'BEGIN{FS="/"} {print $NF}')
  if [[ $branch == "" ]];
  then
    :
  else
    echo '- ('$branch')'
  fi
}

# Enable substitution in the prompt.
setopt prompt_subst

# Enable colors and change prompt:
autoload -U colors && colors
PS1='%B%F{white}%(4~|...|) %3~%F{cyan} $(git_branch_name) > %b%f%k'

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

bindkey '^H' backward-kill-word
bindkey '^[[3~' delete-char

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' 'lfcd\n'

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Case insensitive auto completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Load aliases and shortcuts if existent.
[ -f "$HOME/.config/shortcutrc" ] && source "$HOME/.config/shortcutrc"
[ -f "$HOME/.config/aliasrc" ] && source "$HOME/.config/aliasrc"

#  Aliases
alias ls="ls --color=auto"
alias refresh="source ~/.zshrc"
alias spring="mvn spring-boot:run"

# Create new java project
javap () {
  echo -n "Select project location (\".\" to create project in the same directory): ";
  read LOCATION;
  if [ $LOCATION != "." ]; then
    cd $LOCATION;
  fi

  echo -n "Name of the project: ";
  read NAME;
  mkdir $NAME;

  mkdir $NAME/src;
  echo "module $NAME {}" >> $NAME/src/module-info.java;

  mkdir $NAME/bin;
  javac -d $NAME/bin $NAME/src/module-info.java;

  BUILD="<project default=\"compile\">\n  <target name=\"compile\">\n   <javac srcdir=\"src\" destdir=\"bin\"/>\n  </target>\n</project>";
  printf $BUILD >> $NAME/build.xml;

  echo "Project $NAME has been created.";
}

# Compile and run maven project
mvn_run () {
  FILE="$(ls ./target | grep jar)";
  mvn package && java -jar ./target/$FILE;
}

# Create new maven project
mvn_project () {
  if [ "$1" != "" ] && [ "$2" != "" ]; then
    mvn archetype:generate -DgroupId=$1 -DartifactId=$2 -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.4 -DinteractiveMode=false;
  else
    echo "Missing some of the arguments:\n1 - GroupId\n2 - ArtifactId";
  fi
}

# Commit to github
commit () {
  git add .;
  if [ "$1" != "" ]; then
    git commit -m "$1";
    if [ "$2" != ""]; then
      git push origin $2;
    else
      git push;
    fi
  else
    git reset .;
    echo "Missing commit message.";
  fi
}

# Load zsh-syntax-highlighting and suggestions; should be last.
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
