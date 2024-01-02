if status is-interactive
# Commands to run in interactive sessions can go here
  abbr -a -- pbcopy 'xclip -selection clipboard'
  abbr -a -- pbpaste 'xclip -selection clipboard -o'
  abbr -a -- kc kubectl
end
