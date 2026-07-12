####           ####
#### Functions ####
####           ####

# Enter and list directory
function cd() {
    builtin cd "$@" && {
        [ "$PS1" = "" ] || ls -ah --group-directories-first --color=auto ;
    };
}

# dead domains linter
function ads1() {
    "ads1.php" ;
    sort ads1.txt ads2.txt ads3.txt \
         ads4.txt ads5.txt ads6.txt \
         -u >> ads.txt ;
    diff -uNr blacklist.txt ads.txt > ads.patch ;
    cp blacklist.txt temp-ads.txt ;
    patch < ads.patch temp-ads.txt ;
    sort temp-ads.txt -u >> update.txt ;
    rm ads1.txt ads2.txt ads3.txt \
       ads4.txt ads5.txt ads6.txt \
       ads.txt temp-ads.txt
}
function ads2() {
    "ads2.php" ;
    sort filter1.txt filter2.txt filter3.txt \
         filter4.txt filter5.txt filter6.txt \
         -u >> filter.txt ;
    diff -uNr ublock.txt filter.txt > ads2.patch ;
    cp ublock.txt temp-ads2.txt ;
    patch < ads2.patch temp-ads2.txt ;
    sort temp-ads2.txt -u >> update2.txt ;
    rm filter1.txt filter2.txt filter3.txt \
       filter4.txt filter5.txt filter6.txt \
       filter.txt temp-ads2.txt
}

# Dead domain checker
function checkurl() {
    local url="check-url.sh"
    cat "$1" | decolorize | xargs -n 1 -P 6 $url
}

# Inject mods into game folder
function inject-mod() {
    local folder="$1"
    cp -r ~/joiplay/${folder} "game/"
}

# Find apk endpoint(s)
function endpointapk() {
    local app="$1"
    apktool d ${app} -o target ;
    grep -Phro "(https?://)[\w\.-/]+[\"'\`]" target/ | sed 's#"##g' | anew | grep -v "w3\|android\|github\|http://schemas.android\|google\|http://goo.gl"
}

# Update proxy source http, socks4 and socks5
function proxdl() {
    rm $HOME/.local/proxy/*.txt ;
    aria2c -d $HOME/.local/proxy -i $HOME/.local/proxy/download-links --max-concurrent-downloads 3
}

# Update firefox user.js
function betterfox() {
    rm $HOME/.local/firefox/*.js ;
    aria2c -d $HOME/.local/firefox -i $HOME/.local/firefox/betterfox.txt --max-concurrent-downloads 4
}

# Update git-filter-repo script
function upd-gfr() {
    rm $HOME/bin/git-filter-repo ;
    curl -fsSL -o $HOME/bin/git-filter-repo https://raw.githubusercontent.com/newren/git-filter-repo/main/git-filter-repo ;
    chmod +x $HOME/bin/git-filter-repo
}

# Update fastget script
function upd-fg() {
    rm $HOME/bin/fastget ;
    curl -fsSL -o $HOME/bin/fastget https://raw.githubusercontent.com/rhcp011235/fastget/refs/heads/main/fastget ;
    chmod +x $HOME/bin/fastget
}

# Countfiles in directory
function countfiles() {
    for t in files links directories ; do 
        echo "$(find . -type ${t:0:1} | wc -l)" $t ; done 2> /dev/null
}

# count the lines on a file
function countlines() {
    local file="$1"
    if [ -z "$file" ]; then
        echo "[✘] Usage: linecount <file>"
        return 1
    elif [ ! -f "$file" ]; then
        echo "[✘] File not found"
        return 1
    else
        local lines=$(wc -l < "$file")
        local words=$(wc -w < "$file")
        local chars=$(wc -m < "$file")
        printf "Lines : %s\n" "$lines"
        printf "Words : %s\n" "$words"
        printf "Chars : %s\n" "$chars"
    fi
}

# Change directory when multiple folders have the same name
function cds() {
    if [ -z "$1" ]; then
        echo "[✘] Usage: cds <folder-name>"
        return 1
    fi
    matches="($(find . -type d -name "$1"))"
    count=${#matches[@]}
    if [ $count -eq 0 ]; then
        echo "[i] No directory named '$1' found"
        return 1
    elif [ $count -eq 1 ]; then
        cd "${matches[0]}" || return
    else
        echo "[i] Multiple directories found:"
        for i in "${!matches[@]}"; do
            echo "$i: ${matches[$i]}"
        done
        read -rp "Enter number to cd into: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 0 ] && [ "$choice" -lt $count ]; then
            cd "${matches[$choice]}" || return
        else
            echo "[✘] Invalid choice"
        fi
    fi
}

# Copy and go to the directory
function cpg() {
    if [ -d "$2" ]; then
        cp "$1" "$2" && cd "$2" || return
    else
        cp "$1" "$2"
    fi
}

# Cd into dir and list contents
function cdlc() {
    cd "$1" && ls --color=auto -a --group-directories-first "$2"
}

# Move and go to the directory
function mvg() {
    if [ -d "$2" ]; then
        mv "$1" "$2" && cd "$2" || return
    else
        mv "$1" "$2"
    fi
}

# Create and go to the directory
function mkdirgo() {
    mkdir -p "$1"
    cd "$1" || return
}

# Goes up a specified number of directories  (i.e. up 4)
function dirup() {
    local d=""
    limit=$1
    for ((i=1 ; i <= limit ; i++))
        do
          d=$d/..
        done
    d=$(echo $d | sed 's/^\///')
    if [ -z "$d" ]; then
        d=..
    fi
    cd "$d" || return
}

# Lists all directories matching a name
function listdirs() {
    if [ -z "$1" ]; then
        echo "[✘] Usage: listdirs <folder-name>"
        return 1
    fi
    find . -type d -name "$1" -print;
}

# Show files which contain a term
function grep-open() {
    local editor="$EDITOR"
    rg -l "$1" | fzf --bind "enter:execute($editor + {})"
}

# Show disk usage of directories in current path
function duf() {
    local target="${1:-.}"
    echo "[i] Disk usage for: $target"
    du -h "$target"/* 2>/dev/null | sort -hr | head -20
}

# Show disk usage of directories as a whole
function cekdir() {
    local target="${1:-.}"
    echo "[i] Disk usage for: $target"
    du -sk "$target" | cut -f 1
}

# List file owned by a package with size
function ownedpkg() {
    if [ -n "$(command -v apt)" ]; then
        dpkg -S $1
    elif [ -n "$(command -v pacman)" ]; then
        pacman -Qlq $1 | grep -v '/$' | xargs -r du -h | sort -h
    fi
}

# packages browser
function browsepkg() {
    if [ -n "$(command -v apt)" ]; then
        apt-cache pkgnames | fzf --multi --cycle --layout=reverse \
        --preview "apt-cache show {}" --preview-window=:60% \
        --bind=space:toggle-preview | xargs -ro apt install
    elif [ -n "$(command -v pacman)" ]; then
        pacman -Slq | fzf --multi --cycle --layout=reverse \
        --preview 'pacman -Si {}' --preview-window=:60% \
        --bind='enter:execute(pacman -Si {} | less)'
    else
        return 1
    fi
}

# download package via aria2
function pkgdl() {
    echo "[i] Download starting..."
    local package="$1"
    local managers
    command -v apt >/dev/null 2>&1 && managers=("apt")
    command -v pacman >/dev/null 2>&1 && managers=("pacman")

    for mgr in "${managers[@]}"; do
        echo
        echo "[i] Downloading with $mgr..."

        case "$mgr" in
            apt)
                apt-get download "$package" | aria2c -i - >/dev/null 2>&1
                ;;
            pacman)
                pacman -Sp "$package" | aria2c -i - >/dev/null 2>&1
                ;;
        esac
        echo "[i] Downloaded package(s) for $mgr:"
        echo "[✔] $package"
    done
}

# Find largest file
function flf() {
    du -h -x -s -- * | sort -r -h | head -20
}

# Find large files
function findbig() {
    local size="${1:-100M}"
    local path="${2:-.}"
    echo "[i] Finding files larger than $size in $path"
    find "$path" -type f -size "+$size" -exec sh -c 'ls -lh "$@"' _ {} + 2>/dev/null | sort -k5 -hr
}

# Searches for text in all files in the current folder
function ftext() {
    # -i case-insensitive
    # -I ignore binary files
    # -H causes filename to be printed
    # -r recursive search
    # -n causes line number to be printed
    # optional: -F treat search term as a literal, not a regular expression
    # optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
    grep -iIHrn --color=always "$1" . | less -r
}

# Find and replace text in files
function freplace() {
	if [[ $# -ne 3 ]]; then
		echo "[✘] Usage: freplace <search_text> <replace_text> <file_pattern>"
		echo "[i] Example: freplace 'old_text' 'new_text' '*.txt'"
		return 1
	fi

	local search="$1"
	local replace="$2"
	local pattern="$3"

	echo "[i] Searching for '$search' in files matching '$pattern'"
	echo "[i] Will replace with '$replace'"

	# Show what will be changed first
	echo "[i] Files that will be modified:"
	# shellcheck disable=SC2086
	grep -l "$search" $pattern 2>/dev/null || {
		echo "[✘] No files found containing '$search'"
		return 1
	}

	read -p "Continue with replacement? (y/N): " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		# shellcheck disable=SC2086
		sed -i.bak "s/$search/$replace/g" $pattern
		echo "[✔] Replacement completed. Original files backed up with .bak extension"
	else
		echo "[i] Operation cancelled"
	fi
}

# fuzzy find and kill a process
function fkill() {
	local pid
	# Use a temp file to hold selected lines
	local tmpfile
	tmpfile=$(mktemp)

	ps -eo user,pid,cmd --sort=-%mem |
		sed 1d |
		fzf --multi \
			--reverse \
			--header=" Select processes to kill (Tab to mark, Enter to kill)" \
			--preview 'ps -p {2} -o pid,user,%cpu,%mem,cmd' \
			--bind 'ctrl-s:toggle-sort' >"$tmpfile"

	if [[ ! -s $tmpfile ]]; then
		echo "[✘] No processes selected." >&2
		rm -f "$tmpfile"
		return 1
	fi

	while IFS= read -r line; do
		pid=$(echo "$line" | awk '{print $2}')
		if [[ -n "$pid" ]]; then
			echo "[i] Killing PID $pid…" >&2
			if kill -TERM "$pid" 2>/dev/null; then
				echo "Sent SIGTERM to $pid" >&2
			else
				echo "[i] SIGTERM failed for $pid, sending SIGKILL…" >&2
				kill -KILL "$pid" 2>/dev/null &&
					echo "[✔] Sent SIGKILL to $pid" >&2 ||
					echo "[✘] Failed to kill $pid" >&2
			fi
		fi
	done <"$tmpfile"

	rm -f "$tmpfile"
}

# Git gud
function gg() {
    usage(){
        echo "  [i] Usage: gg [options]"
        echo "  "
        echo "  h, help                                 [i] Show this help usage"
        echo "  "
        echo "  --init                             [i] Autoconfigure git options"
        echo "  "
        echo "  a, [add] <files> [--all]                       [i] Add git files"
        echo "  "
        echo "  c, [commit] <text> [--undo]           [i] Create commit messages"
        echo "  "
        echo "  C, [cherry-pick] <number> <url> [branch]  [i] Cherry pick commit"
        echo "  "
        echo "  b, [branch] feature|hotfix|<name>          [i] Add/Change Branch"
        echo "  "
        echo "  d, [delete] <branch>                           [i] Delete Branch"
        echo "  "
        echo "  l, [log]                                         [i] Display Log"
        echo "  "
        echo "  m, [merge] feature|hotfix|<name> <commit>|<version>    [i] Merge"
        echo "  "
        echo "  p, [push] <branch>                                [i] Push files"
        echo "  "
        echo "  P, [pull] <branch> [--force]                      [i] Pull files"
        echo "  "
        echo "  r, [release]                  [i] Merge develop branch on master"
        echo "  "
        echo "  s, [submodule]               [i] Update all submodules on branch"
    return 1
    }
    case $1 in
        --init)
            local NAME=$(git config --global user.name)
            local EMAIL=$(git config --global user.email)
            local USER=$(git config --global github.user)
            local EDITOR=$(git config --global core.editor)

            [[ -z $NAME ]] && read -p "Name: " NAME
            [[ -z $EMAIL ]] && read -p "Email: " EMAIL
            [[ -z $USER ]] && read -p "Username: " USER
            [[ -z $EDITOR ]] && read -p "Editor: " EDITOR

            git config --global user.name "$NAME"
            git config --global user.email "$EMAIL"
            git config --global github.user "$USER"
            git config --global color.ui true
            git config --global color.status auto
            git config --global color.branch auto
            git config --global color.diff auto
            git config --global diff.color true
            git config --global core.filemode true
            git config --global push.default matching
            git config --global core.editor "$EDITOR"
            git config --global format.signoff true
            git config --global alias.reset 'reset --soft HEAD^'
            git config --global alias.graph 'log --graph --oneline --decorate'
            git config --global alias.compare 'difftool --dir-diff HEAD^ HEAD'
            if which meld &>/dev/null; then
                git config --global diff.guitool meld
                git config --global merge.tool meld
            elif which kdiff3 &>/dev/null; then
                git config --global diff.guitool kdiff3
                git config --global merge.tool kdiff3
            fi
            git config --global --list
            ;;
        a | add )
            if [[ $2 == --all ]]; then
                git add -A
            else
                git add $2
            fi
            ;;
        b | branch )
            check_branch=$(git branch | grep "$2")
            case $2 in
                feature)
                    check_dev_branch=$(git branch | grep dev)
                    if [[ -z $check_dev_branch ]]; then
                        echo "[i] creating develop branch..."
                        git branch dev
                        git push origin dev
                    fi
                    git checkout -b feature --track origin/dev
                    ;;
                hotfix)
                    git checkout -b hotfix master
                    ;;
                master)
                    git checkout master
                    ;;
                *)
                    check_branch=$(git branch | grep "$2")
                    if [[ -z $check_branch ]]; then
                        echo "[i] creating $2 branch..."
                        git branch $2
                        git push origin $2
                    fi
                    git checkout $2
                    ;;
            esac
            ;;
        c | commit )
            if [[ $2 == --undo ]]; then
                git reset --soft HEAD^
            else
                git commit -am "$2"
            fi
            ;;
        C | cherry-pick )
            git checkout -b patch master
            git pull $2 $3
            git checkout master
            git cherry-pick $1
            git log
            git branch -D patch
            ;;
        d | delete)
            check_branch=$(git branch | grep "$2")
            if [[ -z $check_branch ]]; then
                echo "[✘] no branch found."
            else
                git branch -D $2
                git push origin --delete $2
            fi
            ;;
        l | log )
            git log --oneline --decorate --pretty=custom -n 16
            ;;
        m | merge )
            check_branch=$(git branch | grep "$2")
            case $2 in
                --fix)
                    git mergetool --no-gui
                ;;
                feature)
                    if [[ -n $check_branch ]]; then
                        git checkout dev
                        git difftool --no-gui -d dev..feature
                        git merge --no-ff feature
                        git branch -d feature
                        git commit -am "${3}"
                    else
                        echo "[✘] no develop branch found."
                    fi
                    ;;
                hotfix)
                    if [[ -n $check_branch ]]; then
                        # get upstream branch
                        git checkout -b dev origin
                        git merge --no-ff hotfix
                        git commit -am "hotfix: v${3}"
                        # get master branch
                        git checkout -b master origin
                        git merge hotfix
                        git commit -am "hotfix: v${3}"
                        git branch -d hotfix
                        git tag -a $3 -m "release: v${3}"
                        git push --tags
                    else
                        echo "[✘] no hotfix branch found."
                    fi
                    ;;
                *)
                    if [[ -n $check_branch ]]; then
                        git checkout -b master origin
                        git difftool --no-gui -d master..$2
                        git merge --no-ff $2
                        git branch -d $2
                        git commit -am "${3}"
                    else
                        echo "[✘] no develop branch found."
                    fi
                    ;;
            esac
            ;;
        p | push )
            git push origin $2
            ;;
        P | pull )
            if [[ $2 == --force ]]; then
                git fetch --all
                git reset --hard origin/master
            else
                git pull origin $2
            fi
            ;;
        r | release )
            git checkout origin/master
            git merge --no-ff origin/dev
            git tag -a $2 -m "release: v${2}"
            git push --tags
            ;;
        s | submodule )
            git submodule foreach git pull origin master
            ;;
        * | h | help )
            usage
    esac
}

# https://spencer.wtf/2026/02/20/cleaning-up-merged-git-branches-a-one-liner-from-the-cias-leaked-dev-docs.html
function ciaclean() {
    local branch="$1"
    if [[ -z "$branch" ]]; then
        echo "[✘] Usage: input master or main branch"
        return 1
    fi
    
    echo "[i] Cleaning merged git $branch"
    git branch --merged origin/${branch} \
        | grep -vE "^\s*(\*|${branch}|dev)" \
        | xargs -n 1 git branch -d
}

# Cloning termux repository
function termux-build() {
    local repo="$1"
    if [[ -z "$repo" ]]; then
        echo "[✘] Usage: pick repo e.g termux or termux-pacman"
        return 1
    fi

    echo "[i] Start cloning $repo"
    git clone --branch master \
        --single-branch \
        --no-checkout \
        --depth=1 \
        --filter=tree:0 \
        https://github.com/${repo}/termux-packages.git \
        build
    cd build || return
    git sparse-checkout set --no-cone \
        /disabled-packages /ndk-patches \
        /packages /root-packages \
        /scripts /x11-packages \
        /build-all.sh /build-package.sh \
        /clean.sh /repo.json
    git checkout
}

# iTerm2 colorschemes
function termux-schemes() {
    if [ -n "$(command -v cloneit)" ]; then
        echo "[i] Downloading..."
        gtcl https://github.com/mbadolato/iTerm2-Color-Schemes/tree/master/termux upstream ;
        cd upstream || return
    else
        echo "[✘] Command not found. Install cloneit first"
        return 1
    fi
}

# Update last N commits date to now
function git-now() {
    if [ $# -ne 1 ]; then
        echo "[✘] Usage: git-now <number_of_commits>"
        echo "[i] Example: git-now 4"
    else
        git filter-branch -f --env-filter \
            'export GIT_AUTHOR_DATE="$(date)" GIT_COMMITTER_DATE="$(date)"' \
            HEAD~${1}..HEAD
    fi
}

# Clone repo and auto-sync submodules if present
function gcs() {
    if [ $# -ne 1 ]; then
        echo "[✘] Usage: gcs <repo-url>"
        echo "[i] Example: gcs https://github.com/user/repo.git"
    else
        git clone "$1"
        local repo_dir=$(basename "$1" .git)
        if [ -f "$repo_dir/.gitmodules" ]; then
            git -C "$repo_dir" submodule update --init --recursive
        fi
    fi
}

# review changed files on this branch
function review-changes() {
    local base_branch="${1:-}"

    if [ -z "$base_branch" ]; then
        base_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
        [ -z "$base_branch" ] && base_branch="main"
    fi

    git diff --name-only "$base_branch"...HEAD | fzf \
        --preview "git diff $base_branch...HEAD -- {} | delta --width \$FZF_PREVIEW_COLUMNS" \
        --bind "enter:execute($EDITOR {})"
}

# show staged and unstaged file changes
function changed-files() {
    git status --short | awk '{print $2}' | fzf \
        --preview "git diff --cached -- {} | delta --width \$FZF_PREVIEW_COLUMNS && git diff -- {} | \
        delta --width \$FZF_PREVIEW_COLUMNS && git diff --no-index -- /dev/null {} | delta --width \$FZF_PREVIEW_COLUMNS" \
        --bind "enter:execute($EDITOR {})"
}

# Show diff for argument PR number for current repo
function pr-diff() {
    if [ -n "$(command -v gh)" ]; then
        gh pr diff "$1" | delta
    else
        echo "[✘] Command not found. Install github-cli first"
        return 1
    fi
}

# Show PR files for argument PR number for current repo
function pr-files() {
    if [ -n "$(command -v gh)" ]; then
        gh pr diff "$1" --name-only | fzf \
            --bind "enter:execute($EDITOR {})"
    else
        echo "[✘] Command not found. Install github-cli first"
        return 1
    fi
}

# Ollama update all models
function olupd() {
    if [ -n "$(command -v ollama)" ]; then
        ollama list | awk "NR>1 {print $1}" | sort -r | xargs -I {} sh -c echo "Updating model: {}";
        ollama pull {};
        echo "---"
        echo "All models updated."
    else
        echo "[✘] Command not found. Install ollama first"
        return 1
    fi
}

# Quick file encryption with openssl
function encrypt() {
	local file="$1"
	if [[ -z "$file" ]]; then
		echo "[✘] Usage: encrypt <file>"
		return 1
	fi

	echo "[i] Encrypting $file"
	openssl enc -aes-256-cbc -salt -in "$file" -out "${file}.enc" &&
		echo "[✔] Encrypted to ${file}.enc"
}

# Quick file decryption with openssl
function decrypt() {
	local file="$1"
	if [[ -z "$file" ]]; then
		echo "[✘] Usage: decrypt <encrypted_file>"
		return 1
	fi

	local output="${file%.enc}"
	echo "[i] Decrypting $file"
	openssl enc -d -aes-256-cbc -in "$file" -out "$output" &&
		echo "[✔] Decrypted to $output"
}

# Calculate file checksums
function checksum() {
	local file="$1"
	if [[ -z "$file" ]] || [[ ! -f "$file" ]]; then
		echo "[✘] Usage: checksum <file>"
		return 1
	fi

	echo "[i] Checksums for: $file"
	echo "  MD5:    $(md5sum "$file" | cut -d' ' -f1)"
	echo "  SHA1:   $(sha1sum "$file" | cut -d' ' -f1)"
	echo "  SHA256: $(sha256sum "$file" | cut -d' ' -f1)"
}

# Convert between different bases (hex, decimal, binary, octal)
function convbase() {
    if [[ $# -ne 2 ]]; then
        echo "[✘] Usage: convbase <from_base> <number>"
        echo "[i] Bases: bin, oct, dec, hex"
        echo "[i] Example: base hex ff"
        return 1
    fi

    local from_base="$1"
    local number="$2"

    echo "[i] Converting $number from $from_base:"

    case "$from_base" in
    bin | binary)
        local decimal=$((2#$number))
        ;;
    oct | octal)
        local decimal=$((8#$number))
        ;;
    dec | decimal)
        local decimal="$number"
        ;;
    hex | hexadecimal)
        local decimal=$((16#$number))
        ;;
    *)
        echo "[✘] Unsupported base: $from_base"
        return 1
        ;;
    esac

    printf "  Decimal:     %d\n" "$decimal"
    printf "  Hexadecimal: %x\n" "$decimal"
    printf "  Octal:       %o\n" "$decimal"
    printf "  Binary:      %s\n" "$(echo "obase=2; $decimal" | bc)"
}

# Move filenames to lowercase
function lwrcase() {
    for file ; do
        filename=${file##*/}
        case "$filename" in
            */* ) dirname=${file%/*} ;;
            * ) dirname=.;;
        esac
        nf=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
        newname="${dirname}/${nf}"
        if [[ "$nf" != "$filename" ]]; then
            mv "$file" "$newname"
            echo "[i] Lowercase: $file --> $newname"
        else
            echo "[i] Lowercase: $file not changed."
            return 1
        fi
    done
}

# Remove spaces in files within directory
function remspace() {
    if [ -n "$(command -v perl-rename)" ]; then
        find . -depth -name "* *" -exec perl-rename -n 's/ //g' {} +
        echo "\n[i] Continue?"
        select strictreply in "Yes" "No"; do
            relaxedreply=${strictreply:-$REPLY}
            case $relaxedreply in
                Yes | yes | y ) find . -depth -name "* *" -exec perl-rename -v 's/ //g' {} +; echo "[i] Done"; break;;
                No  | no  | n ) return 1;;
            esac
        done
    else
        for i in *' '*; do
            mv "$i" "echo $i | sed -e 's/ //g'"
            ls -a --group-directories-first
        done
    fi
}

# Quick HTTP server in current directory
function phttp() {
    local port="${1:-8000}"
    echo "[i] Starting HTTP server on port $port"
    echo "[i] Serving files from: $(pwd)"
    echo "[i] Access at: http://localhost:$port"
    echo "[i] Press Ctrl+C to stop"

    if command -v python3 &>/dev/null; then
        python3 -m http.server "$port"
    elif command -v python &>/dev/null; then
        python -m SimpleHTTPServer "$port"
    else
        echo "[✘] Python not found. Cannot start HTTP server"
        return 1
    fi
}

# Show listening ports
function ports() {
    echo "[i] Listening ports and processes:"
    if command -v netstat &>/dev/null; then
        netstat -tuln | grep LISTEN
    elif command -v ss &>/dev/null; then
        ss -tuln | grep LISTEN
    else
        echo "[✘] Neither netstat nor ss found"
        return 1
    fi
}

# Generate random password
function genpass() {
    local length="${1:-16}"
    echo "[i] Generating password of length $length"

    if command -v openssl &>/dev/null; then
        openssl rand -base64 $((length * 3 / 4)) | head -c "$length"
    elif [[ -e /dev/urandom ]]; then
        tr -dc 'A-Za-z0-9!@#$%^&*' </dev/urandom | head -c "$length"
    else
        echo "[✘] Cannot generate password: no suitable random source found"
        return 1
    fi
    echo
}

# Lists all files matching a name
function locatef() {
    if [ -n "$(command -v locate)" ]; then
        if [ -z "$1" ]; then
            echo "[✘] Usage: locatef <file-name>"
            return 1
        fi
        locate -e "$1" | grep -o -E -e '(/[^/]+){4}$';
    else
        echo "[✘] Command not found. Install mlocate first."
        return 1
    fi
}

# Quick backup of a file or directory
function qbackup() {
	local item="$1"
	if [[ -z "$item" ]]; then
		echo "[✘] Usage: backup <file_or_directory>"
		return 1
	fi

	local backup_name
	backup_name="${item}.backup.$(date +%d%m%Y-%H%M)"
	echo "[i] Creating backup: $backup_name"

	if [[ -d "$item" ]]; then
		cp -rv "$item" "$backup_name"
	else
		cp -v "$item" "$backup_name"
	fi

	echo "[✔] Backup created: $backup_name"
}

# Execute command in directory
function execin() {
    (cd "${1}" && shift && "${@}")
}

# kill all tmux sessions
function tmux-clean() {
    tmux list-sessions | grep -E -v '\(attached\)$' | while IFS='\n' read line; do
        tmux kill-session -t "${line%%:*}"
    done
}

# edit a binary executables/symlinked scripts
function bined() {
    local bin=""
    bin=$(which "$1")
    if [ -z "$bin" ]; then
        echo "[✘] Binary not found in path"
        return 1
    fi
    $EDITOR "$bin"
}

# Runs when tab is pressed after ,
function fzf-comprun() {
    local command=$1
    shift

    case "$command" in
    cd) fzf "$@" --preview 'ls -TFl --group-directories-first --icons --git -L 2 --no-user {}' ;;
    *) fzf "$@" ;;
    esac
}

# Extract any archive(s)
function ex() {
    local archive="$1"

    # Check if the archive exists
    if [[ ! -f "$archive" ]]; then
        echo "[✘] $archive doesn't exist"
        return 1
    fi

    echo "[i] Archive: $archive"
    echo "[i] Size: $(du -h "$archive" | cut -f1)"
    echo "[i] Type: $(file -b "$archive")"
    echo

    # Get absolute paths
    local archive_dir=$(dirname "$(realpath "$archive")")
    local archive_name=$(basename "$archive")

    # Remember existing files before extraction
    local temp_before=$(mktemp)
    ls -1A "$archive_dir" 2>/dev/null | sort >"$temp_before"

    # Handle different archive formats with verbose output
    case "$archive" in
    *.tar.gz | *.tgz)
        echo "[✔] Extracting tar.gz archive: $archive"
        (cd "$archive_dir" && tar -xzvf "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.tar.xz | *.txz)
        echo "[✔] Extracting tar.xz archive: $archive"
        (cd "$archive_dir" && tar -xJvf "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.tar.bz2 | *.tbz2 | *.tbz)
        echo "[✔] Extracting tar.bz2 archive: $archive"
        (cd "$archive_dir" && tar -xjvf "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.tar.Z | *.tZ)
        echo "[✔] Extracting tar.Z archive: $archive"
        (cd "$archive_dir" && tar -xZvf "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.tar.lz | *.tlz)
        echo "[✔] Extracting tar.lz archive: $archive"
        (cd "$archive_dir" && tar --lzip -xvf "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.tar.lzma)
        echo "[✔] Extracting tar.lzma archive: $archive"
        (cd "$archive_dir" && tar --lzma -xvf "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.tar.lzo)
        echo "[✔] Extracting tar.lzo archive: $archive"
        (cd "$archive_dir" && tar --lzop -xvf "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.tar.zst | *.tzst)
        echo "[✔] Extracting tar.zst archive: $archive"
        (cd "$archive_dir" && tar --zstd -xvf "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.tar)
        echo "[✔] Extracting tar archive: $archive"
        (cd "$archive_dir" && tar -xvf "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.bz2)
        echo "[✔] Extracting bz2 file: $archive"
        (cd "$archive_dir" && bunzip2 -v "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.gz)
        echo "[✔] Extracting gz file: $archive"
        (cd "$archive_dir" && gunzip -v "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.xz)
        echo "[✔] Extracting xz file: $archive"
        (cd "$archive_dir" && unxz -v "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.lzma)
        echo "[✔] Extracting lzma file: $archive"
        (cd "$archive_dir" && unlzma -v "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.Z)
        echo "[✔] Extracting Z file: $archive"
        (cd "$archive_dir" && uncompress -v "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.lz)
        echo "[✔] Extracting lz file: $archive"
        (cd "$archive_dir" && lzip -dv "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.lzo)
        echo "[✔] Extracting lzo file: $archive"
        (cd "$archive_dir" && lzop -dv "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.zst)
        echo "[✔] Extracting zstd file: $archive"
        (cd "$archive_dir" && zstd -dv "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.7z)
        echo "[✔] Extracting 7z archive: $archive"
        (cd "$archive_dir" && 7z x "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.zip | *.jar | *.war | *.ear | *.apk)
        echo "[✔] Extracting zip-based archive: $archive"
        (cd "$archive_dir" && unzip "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.rar)
        echo "[✔] Extracting rar archive: $archive"
        (cd "$archive_dir" && unrar x "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.ace)
        echo "[✔] Extracting ace archive: $archive"
        (cd "$archive_dir" && unace x "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.arj)
        echo "[✔] Extracting arj archive: $archive"
        (cd "$archive_dir" && arj e "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.cab)
        echo "[✔] Extracting cab archive: $archive"
        (cd "$archive_dir" && cabextract "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.lha | *.lzh)
        echo "[✔] Extracting lha/lzh archive: $archive"
        (cd "$archive_dir" && lha x "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.rpm)
        echo "[✔] Extracting rpm package: $archive"
        (cd "$archive_dir" && rpm2cpio "$archive_name" | cpio -idmv) || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.deb)
        echo "[✔] Extracting deb package: $archive"
        (cd "$archive_dir" && ar x "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.iso)
        echo "[✔] Mounting/extracting iso image: $archive"
        local extract_dir="${archive_dir}/${archive_name%.iso}_extracted"
        mkdir -p "$extract_dir"
        if command -v 7z &>/dev/null; then
            7z x "$archive" -o"$extract_dir" || {
                echo "[✘] Failed to extract $archive"
                return 1
            }
        else
            echo "[i] Creating loop mount for ISO extraction"
            sudo mkdir -p "/mnt/${archive_name%.iso}"
            sudo mount -o loop "$archive" "/mnt/${archive_name%.iso}"
            cp -rv "/mnt/${archive_name%.iso}"/* "$extract_dir/"
            sudo umount "/mnt/${archive_name%.iso}"
            sudo rmdir "/mnt/${archive_name%.iso}"
        fi
        ;;
    *.cpio)
        echo "[✔] Extracting cpio archive: $archive"
        (cd "$archive_dir" && cpio -idmv <"$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.shar)
        echo "[✔] Extracting shell archive: $archive"
        (cd "$archive_dir" && sh "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.a)
        echo "[✔] Extracting ar archive: $archive"
        (cd "$archive_dir" && ar x "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *.rpa)
        echo "[✔] Extracting rpa archive: $archive"
        (cd "$archive_dir" && unrpa "$archive_name" && rm "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            return 1
        }
        ;;
    *)
        (cd "$archive_dir" && 7z x "$archive_name") || {
            echo "[✘] Failed to extract $archive"
            echo "[i] Supported formats:"
            echo "    Tar: .tar, .tar.gz/.tgz, .tar.xz/.txz, .tar.bz2/.tbz2/.tbz"
            echo "    Tar: .tar.Z/.tZ, .tar.lz/.tlz, .tar.lzma, .tar.lzo, .tar.zst/.tzst"
            echo "    Compressed: .gz, .bz2, .xz, .lzma, .Z, .lz, .lzo, .zst"
            echo "    Archives: .zip, .7z, .rar, .ace, .arj, .cab, .lha/.lzh, .rpa"
            echo "    Packages: .rpm, .deb, .jar, .war, .ear, .apk"
            echo "    Other: .iso, .cpio, .shar, .a"
            return 1
        }
        ;;
    esac

    echo
    echo "[✔] Successfully extracted $archive"

    # Get current files after extraction
    local temp_after=$(mktemp)
    ls -1A "$archive_dir" 2>/dev/null | sort >"$temp_after"

    # Find newly added files
    local newly_added=$(comm -13 "$temp_before" "$temp_after")

    if [[ -n "$newly_added" ]]; then
        echo "[i] Extracted files:"
        while IFS= read -r file; do
            if [[ -n "$file" ]]; then
                echo "    $file"
            fi
        done <<<"$newly_added"
    else
        echo "[i] No new files found (files may have been extracted to subdirectories)"
    fi

    # Clean up temporary files
    rm -f "$temp_before" "$temp_after" 2>/dev/null

    # Change to the archive directory if not already there
    local current_dir=$(pwd)
    if [[ "$current_dir" != "$archive_dir" ]]; then
        cd "$archive_dir"
        echo "[i] Changed to directory: $archive_dir"
    fi
}

# file(s) compressor
function compact() {
    if [ "$#" -ge "1" ]; then
        case "$1" in
            *.[tT][aA][rR].[bB][zZ]|*.[tT][bB][zZ])
                local file="$1"; shift; tar jcvf "$file" "$@" ;;
            *.[tT][aA][rR].[bB][zZ]2|*.[tT][bB][zZ]2)
                local file="$1"; shift; tar jcvf "$file" "$@" ;;
            *.[tT][aA][rR].[gG][zZ]|*.[tT][gG][zZ])
                local file="$1"; shift; tar czvf "$file" "$@" ;;
            *.[tT][aA][rR].[xX][zZ]|*.[tT][xX][zZ])
                local file="$1"; shift; tar czvf "$file" "$@" ;;
            *.[gG][tT][gG][zZ])
                local file="$1"; shift; tar zcvf "$file" "$@" ;;
            *[bB][zZ]2)
                shift; bzip2 -z -k "$@"  ;;
            *.[rR][aA][rR])
                local file="$1"; shift; rar a -r "$file"  "$@" ;;
            *[gG][zZ])
                shift; gzip -r "$@"  ;;
            *.[tT][aA][rR])
                local file="$1"; shift; tar czvf "$file" "$@" ;;
            *.[zZ][iI][pP])
                local file="$1"; shift; zip -r "$file" "$@" ;;
            *.7[zZ])
                local file="$1"; shift; 7z a -r "$file" "$@" ;;
            *.[xX][zZ])
                local file="$1"; shift; tar czvf "$file" "$@" ;;
            *)    echo "[✘] don't know how to compress '$i' ..." ;;
        esac
    else
        echo "[i] Usage: compact <filename.extension> ./dir(s) ./file(s)"
    fi
}

# Quick compress into 7z
function c7z() {
    for i in * ; do
        7z a -t7z "${i%.*}.7z" -m0=lzma2 -mx=9 -aoa "$i" ; done
}
function sav7z() {
    7z a -t7z "saves.7z" -m0=lzma2 -mx=9 -aoa "saves"
}

# updates all package managers installed, lists updated packages, counts, and disk usage
function uall() {
    echo "[i] Starting update-all..."
    # Record initial disk usage
    initial_usage=$(df -h ~ | awk 'NR==2 {print $3}')
    echo "[i] Initial storage used: $initial_usage"
    grand_total=0
    # Define package managers installed (check if commands exist)
    managers=()
    command -v apt >/dev/null 2>&1 && managers+=("apt")
    command -v pacman >/dev/null 2>&1 && managers+=("pacman")
    command -v pip >/dev/null 2>&1 && managers+=("pip")

    for mgr in "${managers[@]}"; do
        echo
        echo "[i] Updating with $mgr..."
        updated_list=""
        count=0

        case "$mgr" in
            apt)
                apt update -y >/dev/null 2>&1
                updated_list=$(apt list --upgradable 2>/dev/null | grep -v "Listing...")
                apt upgrade -y >/dev/null 2>&1
                count=$(echo "$updated_list" | wc -l)
                ;;
            pacman)
                pacman -Sy >/dev/null 2>&1
                updated_list=$(pacman -Qu 2>/dev/null | wc -l)
                pacman -Syu >/dev/null 2>&1
                count=$(echo "$updated_list" | wc -l)
                ;;
            pip)
                for pkgname in $(pip list --outdated | cut -d '=' -f1); do
                    pip install --upgrade "$pkgname" >/dev/null 2>&1
                    updated_list+="$pkgname"$'\n'
                    ((count++))
                done
                ;;
        esac
        echo "[i] Updated packages for $mgr:"
        echo "[i] $updated_list"
        echo "[i] Total updates for $mgr: $count"
        grand_total=$((grand_total + count))
    done
    # Record final disk usage
    final_usage=$(df -h ~ | awk 'NR==2 {print $3}')
    echo
    echo "[i] Grand total of updated packages: $grand_total"
    echo "[i] Storage used before: $initial_usage"
    echo "[i] Storage used after : $final_usage"
}

# Quick note taking
function note() {
    local note_file="$HOME/doc/notes/note.md"
    if [[ $# -eq 0 ]]; then
        echo "[i] Current notes:"
        cat "$note_file" 2>/dev/null || echo "[i] No notes found"
    else
        echo "$(date '+%d-%m-%Y %H:%M:%S'): $*" >>"$note_file"
        echo "[✔] Note added"
    fi
}

# Converts jpg files and resize by 20%
function convimg() {
    for img in *.jpg ; do
        magick convert -regard-warnings -resize 20% "$img" "output-$img" ; done
}

# Transcode any image to compressed-but-lossless PNG
function convert-to-png() {
    magick "$1" -strip -define png:compression-filter=5 \
        -define png:compression-level=9 \
        -define png:compression-strategy=1 \
        -define png:exclude-chunk=all \
        "${1%.*}.png"
}

# Converts the input folder to webp, moves over the prompt and then removes the original
function convert-png-to-webp() {
    local DIR=$1
    find "$DIR" -type f -name "*.png" | parallel '
        img={}
        outputWebp="${img%.png}.webp"
        cwebp -q 80 "$img" -o "$outputWebp"
        exiftool -TagsFromFile "$img" "-UserComment<Parameters" -comment= -overwrite_original "$outputWebp"
        rm "$img" 
    '
}

# Converts all audio files in the target dir (first arg) to opus with metadata at a rate of 64kbps.
function convert-audio() {
    local DIR=$1
    if [ -z "$1" ]; then
        echo "[✘] Please provide a folder as an argument"
        return 1
    fi

    echo "[i] Converting $DIR"
    find "$DIR" -type f -name \
        "*.mp3" -o -name "*.m4a" -o -name \
        "*.wav" -o -name "*.flac" -o -name \
        "*.aac" -o -name "*.mp4" -o -name "*.wma" \
        | parallel ffmpeg -i {} -c:a libopus -b:a 64k -map_metadata 0 -id3v2_version 3 {.}.opus &&
        echo "[✔] ${DIR} Converted" ;
    find "$DIR" -type f -name \
        "*.mp3" -o -name "*.m4a" -o -name \
        "*.wav" -o -name "*.flac" -o -name \
        "*.aac" -o -name "*.mp4" -o -name "*.wma" \
        | parallel rm {}
}

# Remuxes all video files in the target folder to MKV
function convert-mkv() {
    local folder="$1"
    if [ -z "$1" ]; then
        echo "[✘] Please provide a folder as an argument"
        return 1
    fi

    echo "[i] Converting $folder"
    find "$folder" -type f -iname "*.mp4" -o -iname "*.mov" -o -iname "*.avi" -o -iname "*.mkv" | parallel ffmpeg -i {} -c:v copy -c:a copy -map_metadata -1 {.}.mkv &&
    echo "[✔] $folder converted"
}
