#!/bin/zsh
# Preview the site locally: serves it with live reload and opens it in the browser.
# Posts, pages, layouts and CSS update live. Jekyll only reads _config.yml (and the
# Gemfile) at startup, so when either changes the server is restarted for a full
# rebuild. Run it from anywhere with the `preview` alias (see ~/.zshrc). Ctrl-C stops it.
# Extra options go to Jekyll, e.g. `preview --drafts` also shows the posts in _drafts/.
cd "${0:A:h}"
export PATH="/opt/homebrew/opt/ruby@3.4/bin:$PATH"
port=4000
jekyll_args=("$@")
watched=(_config.yml Gemfile)

if lsof -ti tcp:$port -sTCP:LISTEN >/dev/null 2>&1; then   # a server, not just an open browser tab
  echo "The preview is already running; opening http://localhost:$port"
  open "http://localhost:$port"
  exit 0
fi

server=0
start() {
  bundle check >/dev/null 2>&1 || bundle install
  bundle exec jekyll serve --livereload --port $port $jekyll_args &
  server=$!
}
stop() {
  if (( server )); then kill $server 2>/dev/null; wait $server 2>/dev/null; fi
  server=0
}
stamp() { stat -f '%m' $watched 2>/dev/null | tr '\n' ' '; }
trap 'stop; exit 0' INT TERM

start
# open the browser as soon as the server answers
( until curl -s -o /dev/null "http://localhost:$port"; do sleep 0.5; done; open "http://localhost:$port" ) &

last=$(stamp)
while sleep 1; do
  now=$(stamp)
  if [[ $now != $last ]]; then
    last=$now
    print "\n==> ${watched[*]} changed, restarting for a full rebuild...\n"
    stop
    start
  elif (( server )) && ! kill -0 $server 2>/dev/null; then
    print "\n==> Jekyll stopped (see the error above). Fix it and save; it will rebuild.\n"
    server=0
  fi
done
