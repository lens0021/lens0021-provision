if status is-interactive
  # Commands to run in interactive sessions can go here

  abbr -a -- pbcopy 'xclip -selection clipboard'
  abbr -a -- pbpaste 'xclip -selection clipboard -o'
  abbr -a -- kc kubectl
  abbr -a -- tf terraform
  abbr -a -- cd-fzf 'cd (rg --files | fzf --preview \'ls {}\')'

  abbr -a -- gitgraph 'git log --graph --all --decorate --oneline --color'
end
