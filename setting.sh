cwd=`pwd`
cd $HOME/.config/nvim 
ln -s $cwd/config/* .


cat << 'EOF' >> $HOME/.config/ranger/rc.conf
unmap h
unmap j
unmap k
unmap l

map <C-n> move down=1
map <C-p> move up=1
map <C-h> move left=1
map <C-l> move right=1
map <C-c> quit
EOF


cat << 'EOF' >> $HOME/.config/ranger/rifle.conf
ext png|jpg|jpeg|gif, flag f = vimiv -- "$@"
ext txt|py|cpp|h, has nvr, terminal = nvr -- "$@"
EOF


# -> bash
# PROMPT_COMMAND='grep -qxF "$PWD" ~/.dir_history 2>/dev/null || echo "$PWD" >> ~/.dir_history; tail -n 1000 ~/.dir_history > ~/.dir_history.tmp && mv ~/.dir_history.tmp ~/.dir_history'
# alias zz='cd "$(tac ~/.dir_history | awk "!seen[\$0]++" | fzf --layout=reverse)"'
# export FZF_DEFAULT_OPTS='--layout=reverse --bind=ctrl-l:accept'
