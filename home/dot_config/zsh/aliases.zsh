alias myip="curl -s https://ipinfo.io/json"
alias serve='python3 -m http.server 8000'

alias rc="bin/rails c"
alias rs="bin/rails s"
alias rdbm="bin/rails db:migrate"
alias rdbr="bin/rails db:rollback"
alias rdbs="bin/rails db:seed"
alias rdb="bin/rails db:drop db:create db:migrate db:seed"

app() { open -a "$1"; }
web() { open "https://www.$1"; }
c() { open "${1:-.}" -a Cursor; }
v() { open "${1:-.}" -a "Visual Studio Code"; }
goto() { cd ~/src/$1; }
killserver() { kill -9 $(lsof -ti:$1); }

repo() {
  case $# in
    1|2) open "https://github.com/${(j:/:)@}" ;;
    *) echo "Usage: repo <owner> [repo]" ;;
  esac
}
cs() {
  case $# in
    1|2) open "https://cs.github.com/${(j:/:)@}" ;;
    *) echo "Usage: cs <owner> [repo]" ;;
  esac
}
pr() {
  case $# in
    2) open "https://github.com/$1/$2/pulls" ;;
    3) open "https://github.com/$1/$2/pull/$3" ;;
    *) echo "Usage: pr <owner> <repo> [number]" ;;
  esac
}
issues() { open "https://github.com/$1/$2/issues"; }
