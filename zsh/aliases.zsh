####         ####
#### Aliases ####
####         ####

# Enable color support of ls, diff, grep, dir and bat
if [[ -x $PREFIX/bin/dircolors ]]; then
    test -r "$HOME"/.dircolors && eval "$(dircolors -b "$HOME"/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias diff='diff --color=auto'
    alias egrep='grep -E --color=auto'
    alias fgrep='fgrep --color=auto'
    alias grep='grep --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto -h'
    alias bat='bat --color=always --paging=never'
fi

# Use 'neovim' (if installed)
if [[ -x $PREFIX/bin/nvim ]]; then
    alias vi='nvim'
    alias vim='nvim'
fi

# Replace 'ncdu' with 'ncdu2' (if available)
if [[ -x $PREFIX/bin/ncdu2 ]]; then
    alias ncdu='ncdu2 -e --color=dark-bg --show-itemcount --show-mtime'
else
    alias ncdu='ncdu'
fi

# Replace 'cat' with 'bat' (if available)
if [[ -x $PREFIX/bin/bat ]]; then
    alias cat='bat --color=always --decorations=never --paging=never'
else
    alias cat='cat'
fi

# Replace 'ls' with 'eza' (if available) + some aliases
if [[ -x $PREFIX/bin/eza ]]; then
    alias l='eza --color=auto --icons=auto'
    alias ls='eza --color=always --group-directories-first --icons=auto'
    alias l.='eza -d --color=auto --icons=auto .*'
    alias la='eza -a --group-directories-first --color=auto --icons=auto'
    alias ll='eza -hl --group-directories-first --classify=always --color=auto --icons=auto'
    alias ll.='eza -hl -d --group-directories-first --classify=always --color=auto --icons=auto .*'
    alias lm='eza --color=auto --icons=auto | less'
    alias l1='eza -1 --group-directories-first --classify=auto --color=auto --icons=auto'
    alias l1m='eza -1 --group-directories-first --classify=auto --color=auto --icons=auto | less'
    alias lh='eza -ld --color=auto --icons=auto .??*'
    alias lsn='eza --color=auto --icons=auto | cat -n'
else
    alias l='ls --color=auto'
    alias ls='ls --color=auto'
    alias l.='ls --color=auto -d .*'
    alias la='ls --color=auto -a --group-directories-first'
    alias ll='ls --color=auto -Fhl --classify=always'
    alias ll.='ls --color=auto -Fhl -d .*'
    alias lm='ls --color=auto | less'
    alias l1='ls -1F --color=auto --group-directories-first'
    alias l1m='ls -1F --color=auto --group-directories-first | less'
    alias lh='ls -ld --color=auto .??*'
    alias lsn='ls --color=auto | cat -n'
fi

# List all possible commands
alias allcmd='compgen -c | less'

# Common commands
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
alias .6='cd ../../../../../../'
alias .7='cd ../../../../../../../'
alias .8='cd ../../../../../../../../'
alias cdusr='cd $PREFIX'
alias mkdir='mkdir -p -v'
alias rmd='rm -rfv'
alias cpv='cp --preserve=all -v'
alias cpr='cp --preserve=all -R'
alias rsync='rsync -ahW --info=progress2'
alias cs='printf "\033c"'
alias lincol='echo -e "lines\ncols" | tput -S'
alias preview="fzf --preview='bat --squeeze-blank --color=always --style=full {}' --preview-window=down"
alias q='clear && exit'
alias logout='pkill termux'
alias c='clear'

# Memory
alias df='df -h'
alias free='free -mt'
alias ps='ps -e'
alias ht='htop'

# Backup stuff
alias tbkp='tar -czvf /storage/emulated/0/AppManager/bootstrap/home-backup.tar.xz -C /data/data/com.termux/files ./home'
alias trstr='tar -xzvf /storage/emulated/0/AppManager/bootstrap/home-backup.tar.xz -C /data/data/com.termux/files --recursive-unlink --preserve-permissions'
alias etcb='cd $PREFIX/etc && tar czvf etcb.tar.xz motd termux-login.sh && mv etcb.tar.xz $HOME/bootstrap && cd $HOME'

# Calender
alias jan='cal -m January'
alias feb='cal -m February'
alias mar='cal -m March'
alias apr='cal -m April'
alias mei='cal -m May'
alias jun='cal -m June'
alias jul='cal -m July'
alias agu='cal -m August'
alias sep='cal -m September'
alias oct='cal -m October'
alias nov='cal -m November'
alias des='cal -m December'

# Package manager
alias pkguc='pkg update'
alias pkgup='pkg upgrade'
alias pkgli='pkg list-installed'
alias pkgla='pkg list-all'
alias pkgf='pkg info'
alias pkgs='pkg search'
alias pkgsw='pkg show'
alias papc='pkg autoclean && pkg clean'

# Package manager specific
if [ -n "$(command -v apt)" ]; then
    alias pkguc='pkg update && apt list --upgradable -a'
    alias pupg='pkg update && pkg upgrade'
    alias create-pack='termux-create-package'
    alias crepo='termux-change-repo'
    alias listpkgbysize="dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n"
elif [ -n "$(command -v pacman)" ]; then
    alias create-pack='makepkg -fcsi' # Make package from PKGBUILD file in current directory.
    alias paconf="$editor '$PREFIX/etc/pacman.conf'"
    alias crepo="$editor '$PREFIX/etc/pacman.d/mirrorlist'"
    alias pacupg='pacman -Syu' # Synchronize with repositories and then upgrade packages that are out of date on the local system.
    alias pacupd='pacman -Sy' # Refresh of all package lists after updating /etc/pacman.d/mirrorlist.
    alias pacupdb='pacman -Sy && pacman -Fy' # Refresh all package(s) record on local database.
    alias pacin='pacman -S' # Install specific package(s) from the repositories.
    alias pacdl='pacman -Sw' # Download package(s) without installing.
    alias pacis='pacman -Fy' # Sync the files database to local.
    alias pacinu='pacman -U' # Install specific local package(s).
    alias pacre='pacman -R' # Remove the specified package(s), retaining its configuration(s) and required dependencies.
    alias pacun='pacman -Rcsn' # Remove the specified package(s), its configuration(s) and unneeded dependencies.
    alias pacinfo='pacman -Qi' # Display information about a given package in the database.
    alias pacview='pacman -Si' # Display information about a given package in the repositories.
    alias pacse='pacman -Ss' # Search for package(s) in the repositories.
    alias pacinde='pacman -S --asdeps' # Install given package(s) as dependencies of another package.
    alias pacclean='pacman -Sc' # Delete all not currently installed package files.
    alias pacpurge='pacman -Scc' # Delete all cache package files and clean up database repository.
    alias listpkgdepend="expac -S '%D'"
    alias listpkgopti="expac -S '%o'"
    alias listpkgbysize="expac -H M '%m\t%n' | sort -h"
    alias listpkgbydate="expac --timefmt='%d-%m-%Y %T' '%l\t%n' | sort -h"
    alias listpkgupdate="expac -S -H M '%k\t%n' $(pacman -Qqu) | sort -sh"
    alias ceklastupd="expac --timefmt='%d-%m-%Y %T' '%l\t%n' | sort | tail -n 20"
    alias listpkgother="comm -23 <(pacman -Qq | sort) <(pacman -Sql main | sort)"
fi

# Custom scripts
alias tcenv='termux-switchenv'
alias tvi='termux-verify-integrity'
alias cek-dep='termux-autodep'
alias reload='termux-reload-settings'
alias perm='termux-setup-storage'
alias tec='termux-elf-cleaner'
alias open='termux-open-url'
alias lock='termux-wake-lock'
alias unlock='termux-wake-unlock'
alias cleaner='termux-junk-cleaner'
alias createc='create-conventional-changelog'
alias ddl='dead-domains-linter'

# Applications shortcuts
alias tprop="$editor '$HOME/.termux/termux.properties'"
alias cclean="rm -rf $HOME/.cache"
alias bclean="rm -rf $HOME/build && mkdir build"
alias pclean='killall -9 com.termux.api gpg-agent pulseaudio ssh-agent termux-wake-lock'
alias ebashrc="$editor '$HOME/.config/bash/bashrc'"
alias ebashal="$editor '$HOME/.config/bash/aliases.bash'"
alias ebashfu="$editor '$HOME/.config/bash/functions.bash'"
alias ezshrc="$editor '$HOME/.config/zsh/zshrc'"
alias ezshal="$editor '$HOME/.config/zsh/aliases.zsh'"
alias ezshfu="$editor '$HOME/.config/zsh/functions.zsh'"
alias timenow='date +"%R"'
alias datenow='date +"%A, %d %b %m %Y"'
alias untar='tar xzvf'
alias ctar='tar czvf'
alias wget='wget -c'
alias e="$editor"
alias sddb='updatedb --database-root /storage/emulated/0/ --output $HOME/.local/state/mlocate/sdcard.db'
alias shck='shellcheck'
alias py2='python2'
alias py='python3'
alias olser='ollama serve &'
alias olst='pkill ollama'
alias onefetch="onefetch --no-color-palette --no-art --nerd-fonts"
alias patch-aapt="find ~/.local/gradle -name 'aapt2-*-linux.jar' -type f | xargs -I{} jar -uvf {} -C $HOME/.local/bin aapt2"
alias apksigner='apksigner sign --ks $HOME/.keystore/sign.keystore'
alias zipalcv='zipalign -c -v 4'
alias qalc='qalc -color'
alias localb='git -C $HOME/build pull'
alias decolorize='sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,3})*)?[mGK]//g"'
alias wifikey='sudo grep -r "string name=" /data/misc/wifi/WifiConfigStore.xml' # Each phone different.

# Git
alias gite="$editor '$HOME/.config/git/gitconfig'"
alias gitel="$editor '$HOME/.config/git/gitconfig.local'"
alias gitei="$editor '$HOME/.config/git/gitignore'"
alias gitab="$editor '$HOME/.config/git/gitattributes'"
alias gital="$editor '$HOME/.config/git/gitconfig.alias'"
alias githem="$editor '$HOME/.config/git/gitconfig.themes'"
alias me="$editor 'README.md'"
alias rdm='cat README.md'
alias cglg='cat CHANGELOG.md'
alias lg='lazygit'
alias gfr='git-filter-repo'
alias commit-date="git log -1 --format=%cs | sed 's/-/./g'"
alias commit-sha="find . -type f ! -path '*/.git/*' -print0 | xargs -0 sha256sum | LC_ALL=C sort | sha256sum"
alias ga="git add"
alias gc="git commit -m"
alias gca="git commit --all -m"
alias gl="git pull --rebase --autostash"
alias gp="git push"
alias gpf="git push --force"
alias gss="git status -s"
alias gsd="git status -s && git diff HEAD"
alias gbrr="git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format='%(refname:short)'"
alias gcm='git checkout $(git_main_branch)'
alias gcma="git commit --amend -m"
alias gcman="git commit --amend --no-edit"
alias gcmn="git add . && git commit --amend --no-edit"
alias gdh="git diff HEAD"
alias ghkey='gh ssh-key add $HOME/.ssh/id_ed25519.pub --title "$(hostname)" --type signing'
alias ghpr="gh pr create"
alias ghpd="pr-diff"
alias ghpf="pr-files"
alias ghrc="gh repo clone"
alias ghrd="gh repo edit -d"
alias ghrh="gh repo edit -h"
alias ghro="gh repo view --web"
alias ghrr="gh repo rename"
alias ghrs="gh release create"
alias ghrt="gh repo edit --add-topic "
alias ghrv="gh repo edit --accept-visibility-change-consequences --visibility "
alias gmv="git mv"
alias gmx="git merge -X ours"
alias greb="git rebase --interactive --autostash --keep-empty --no-autosquash --rebase-merges main"
alias gsv="git status -v"
alias gtop='cd "$(git rev-parse --show-toplevel)"'
