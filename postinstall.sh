#!/usr/bin/env bash
set -euo pipefail

helpmessage() { \
    echo "USAGE: "
    echo "$0 emacs (for Doom Emacs)"
    echo "$0 vim (for SpaceVim)" 
    exit 0
}

installdoomemacs() { \
    
    git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d
    ~/.emacs.d/bin/doom install
    
    # Create desktop entry with fix for pantheon DE
    cat > ~/.local/share/applications/doom-emacs.desktop << EOF
[Desktop Entry]

# The type as listed above
Type=Application

# The version of the desktop entry specification to which this file complies
Version=1.0

# The name of the application
Name=Doom Emacs

# A comment which can/will be used as a tooltip
Comment=An Emacs framework for the stubborn martian hacker

# The executable of the application, possibly with arguments.
Exec=/usr/bin/env XLIB_SKIP_ARGB_VISUALS=1 emacs %F

# The name of the icon that will be used to display this entry
Icon=emacs

# Describes whether this application needs to be run in a terminal or not
Terminal=false
EOF

    # Relative line numbers
    sed -i "s/type t/type \"relative\"/g" ~/.doom.d/config.el
    
    # Set org-directory to ~/sync/org
    sed -i "s/~\/org\//~\/sync\/org\//g" ~/.doom.d/config.el
    
    # Automatic fullscreen
    cat >> ~/.doom.d/config.el << EOF
(add-to-list 'default-frame-alist '(fullscreen . fullscreen))
EOF
    # Some packages in init.el
    sed -i "s/doom-quit/;;doom-quit/g" ~/.doom.d/init.el
    sed -i "s/;;(emoji/(emoji/g" ~/.doom.d/init.el
    sed -i "s/;;ligatures/ligatures/g" ~/.doom.d/init.el
    sed -i "s/;;treemacs/treemacs/g" ~/.doom.d/init.el
    sed -i "s/;;zen/zen/g" ~/.doom.d/init.el
    sed -i "s/;;(format/(format/g" ~/.doom.d/init.el
    sed -i "s/;;vterm/vterm/g" ~/.doom.d/init.el
    sed -i "s/;;shell/shell/g" ~/.doom.d/init.el
    sed -i "s/;;lsp/lsp/g" ~/.doom.d/init.el
    sed -i "s/;;pdf/pdf/g" ~/.doom.d/init.el
    sed -i "s/;;make/make/g" ~/.doom.d/init.el
    sed -i "s/;;data/data/g" ~/.doom.d/init.el
    sed -i "s/;;nix/nix/g" ~/.doom.d/init.el
    sed -i "s/;;web/web/g" ~/.doom.d/init.el
    sed -i "s/;;yaml/yaml/g" ~/.doom.d/init.el

    ~/.emacs.d/bin/doom sync
}

installspacevim() { \
   curl -sLf https://spacevim.org/install.sh | bash 
}

[ $# -eq 0 ] && helpmessage

case "$1" in
    emacs)  installdoomemacs ;;
    vim)    installspacevim ;;    
    *)      helpmessage ;;
esac

# Remap caps lock to escape
cat > ~/.xprofile << EOF
setxkbmap -option "caps:escape"
xset r rate 300 50
EOF

# Luke Smith's ZSH config (from https://github.com/LukeSmithxyz/voidrice)
cat > ~/.zshrc << EOF
# Luke's config for the Zoomer Shell

# Enable colors and change prompt:
autoload -U colors && colors	# Load colors
PS1="%B%{\$fg[red]%}[%{\$fg[yellow]%}%n%{\$fg[green]%}@%{\$fg[blue]%}%M %{\$fg[magenta]%}%~%{\$fg[red]%}]%{\$reset_color%}$%b "
setopt autocd		# Automatically cd into typed directory.
stty stop undef		# Disable ctrl-s to freeze terminal.
setopt interactive_comments

# History in cache directory:
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=~/.cache/zsh/history

# Load aliases and shortcuts if existent.
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc"

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
bindkey -v '^?' backward-delete-char

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="\$tmp" "$@"
    if [ -f "\$tmp" ]; then
        dir="\$(cat "\$tmp")"
        rm -f "\$tmp" >/dev/null
        [ -d "\$dir" ] && [ "\$dir" != "$(pwd)" ] && cd "\$dir"
    fi
}
bindkey -s '^o' 'lfcd\n'

bindkey -s '^a' 'bc -lq\n'

bindkey -s '^f' 'cd "\$(dirname "\$(fzf)")"\n'

bindkey '^[[P' delete-char

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

EOF

echo "Done configuring nearly everything, next step is to install needed plugins in your editor."
