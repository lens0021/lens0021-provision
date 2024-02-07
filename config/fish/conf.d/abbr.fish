if status is-interactive
  # Commands to run in interactive sessions can go here

  abbr -a -- pbcopy 'xclip -selection clipboard'
  abbr -a -- pbpaste 'xclip -selection clipboard -o'
  abbr -a -- kc kubectl
  abbr -a -- tf terraform

  abbr -a -- gco 'git checkout'
  abbr -a -- gitdelta 'git -c \'core.pager=delta --light -s\''
  abbr -a -- gitgraph 'git log --graph --all --decorate --oneline --color'
  abbr -a -- gitgraphfzf "git log --graph --all --decorate --oneline --color | fzf --multi --tiebreak=index --layout reverse --ansi --no-sort --preview 'echo {} | rg --only-matching --max-count 1 '[0-9a-f]\\\\{7\\\\}' | xargs -I % sh -c \'git show --color=always \\%\'' | rg '[0-9a-f]{7}' --only-matching --max-count 1"
end
