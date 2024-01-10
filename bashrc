user:
HISTFILESIZE=8000
alias ls='ls -G'
alias grep='grep --color=auto'
PATH=/sbin:/bin:/usr/local/sbin:/usr/local/bin:/root/bin:/usr/sbin:/usr/bin:/usr/games

#export PS1='\[\033[01;31m\]\u@\h\[\033[00m\]:\w\$ '
export PS1='\[\033[01;36m\]\u@\h\[\033[34m\]:\w\$\[\033[00m\] '

root:
export PS1='\[\033[01;31m\]\u@\h\[\033[34m\]:\w\$\[\033[00m\] '