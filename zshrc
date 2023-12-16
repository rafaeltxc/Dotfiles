# CONFIGURATION
# Find and set branch name var if in git repository
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

# Enable colors and change prompt
autoload -U colors && colors
PS1='%B%F{white}%(4~|...|) %3~%F{cyan} $(git_branch_name) > %b%f%k'

# Enable substitution in the prompt.
setopt prompt_subst

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history
setopt share_history

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# Case insensitive auto completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
#
# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Keymap fix (Normal use of the shortcuts)
bindkey '^H' backward-kill-word
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey '^[[3~' delete-char
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

#  Aliases
# Misc
alias nv="nvim ."
alias refresh="source ~/.zshrc"
alias lg="lazygit"
alias pdf="mupdf"
alias cl="clear"

# Better listing
alias ls="ls --color=auto"
alias ll="ls -l --color=auto"
alias la="ls -a --color=auto"

# Tmux
alias tn="tmux new"
alias ta="tmux attach"
alias td="tmux detach"
alias tl="tmux ls"

# CUSTOM FUNCTIONS
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

# fzf
fuzzy () {
    VAR=$(find "$HOME" | fzf)

    if [[ -d $VAR ]]; then
        cd "$VAR"
    elif [[ -f $VAR ]]; then
      (nvim "$VAR")
    fi
}
bindkey -s "^F" "fuzzy\n"

# Create new java project
java_p () {
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

    BUILD="<project default=\"compile\">\n  <target name=\"compile\">\n   <mkdir dir=\"bin\"/>\n   <javac srcdir=\"src\" destdir=\"bin\"/>\n  </target>\n</project>";
    printf $BUILD >> $NAME/build.xml;

    mkdir $NAME/classpath;
    echo "Project \"$NAME\" has been created.";
}

# Create new maven project
mvn_project () {
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        echo "Usage: mvn_project 'group' 'name'"
        return
    fi

    if [ "$1" != "" ] && [ "$2" != "" ]; then
        mvn archetype:generate -DgroupId=$1 -DartifactId=$2 -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.4 -DinteractiveMode=false;
    else
        echo "Missing some of the arguments:\n1 - GroupId\n2 - ArtifactId";
    fi
}

# Commit to github
commit() {
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        echo "Usage: commit 'message' 'description'"
        return
    fi

    git add .;
    if [ -n "$1" ] && [ -n "$2" ]; then
        git commit -m "$1" -m "$2";
        git push;
    elif [ -n "$1" ]; then
        git commit -m "$1";
        git push;
    else
        git reset .;
        echo "Missing commit message.";
    fi
}

get() {
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        echo "Usage: get 'PORT' 'URL'"
        return
    fi

    curl http://localhost:$1/$2;
}

post() {
    if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
        echo "Usage: 'JSON' 'PORT' 'URL'"
        exit 0
    fi

    curl --header "Content-Type: application/json" \
        --request POST \
        --data "$1" \
        http://localhost:$2/$3
}

update() {
    if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
        echo "Usage: 'JSON' 'PORT' 'URL'"
        exit 0
    fi

    curl --header "Content-Type: application/json" \
        --request UPDATE \
        --data "$1" \
        http://localhost:$2/$3
}

delete() {
    if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
        echo "Usage: 'PORT' 'URL'"
        exit 0
    fi

    curl --request DELETE \
        http://localhost:$1/$2
}

# Load zsh-syntax-highlighting and suggestions; should be last.
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
