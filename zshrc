# original https://vermaden.wordpress.com/2021/09/19/ghost-in-the-shell-part-7-zsh-setup/
# thank vermaden for the always awesome work 
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=2000
SAVEHIST=2000
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/victorio/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# imitate sockstat on linux
case $( uname ) in 
  (Linux) alias sockstat="netstat -lnptu --protocol=inet,unix" ;;
esac

# ZSH HISTORY SEARCH
  bindkey -M vicmd '/' history-incremental-pattern-search-backward
  bindkey -M vicmd '?' history-incremental-pattern-search-forward

# ZSH HISTORY SEARCH FOR vi(1) INSERT MODE
  bindkey -M viins '^R' history-incremental-pattern-search-backward
  bindkey -M viins '^F' history-incremental-pattern-search-forward

# ZSH HISTORY MAPPINGS
  bindkey '^[[A' up-line-or-search
  bindkey '^[[B' down-line-or-search
  bindkey "^R" history-incremental-search-backward

# ZSH USE SHIFT-TAB FOR REVERSE COMPLETION
  bindkey '^[[Z' reverse-menu-complete

# ZSH LAST ARG FROM EARLIER COMMAND WITH [ALT]-[.]
  bindkey '\e.' insert-last-word

# ZSH BEGIN/END OF LINE
  bindkey "^A" beginning-of-line
  bindkey "^E" end-of-line

# KEY BINDINGS
  case "${TERM}" in
    (cons25*|linux)
      # PLAIN BSD/LINUX CONSOLE
      bindkey '\e[H'    beginning-of-line   # HOME
      bindkey '\e[F'    end-of-line         # END
      bindkey '\e[5~'   delete-char         # DELETE
      bindkey '[D'      emacs-backward-word # ESC+LEFT
      bindkey '[C'      emacs-forward-word  # ESC+RIGHT
      ;;
    (*rxvt*)
      # RXVT DERIVATIVES
      bindkey '\e[3~'   delete-char         # DELETE
      bindkey '\eOc'    forward-word        # CTRL+RIGHT
      bindkey '\eOd'    backward-word       # CTRL+LEFT
      # RXVT WORKAROUND FOR screen(1) UNDER urxvt(1)
      bindkey '\e[7~'   beginning-of-line   # HOME
      bindkey '\e[8~'   end-of-line         # END
      bindkey '^[[1~'   beginning-of-line   # HOME
      bindkey '^[[4~'   end-of-line         # END
      ;;
    (*xterm*)
      # XTERM DERIVATIVES
      bindkey '\e[H'    beginning-of-line   # HOME
      bindkey '\e[F'    end-of-line         # END
      bindkey '\e[3~'   delete-char         # DELETE
      bindkey '\e[1;5C' forward-word        # CTRL+RIGHT
      bindkey '\e[1;5D' backward-word       # CTRL+LEFT
      # XTERM WORKAROUND FOR screen(1) UNDER xterm(1)
      bindkey '\e[1~'   beginning-of-line   # HOME
      bindkey '\e[4~'   end-of-line         # END
      ;;
    (screen)
      # GNU SCREEN
      bindkey '^[[1~'   beginning-of-line   # HOME
      bindkey '^[[4~'   end-of-line         # END
      bindkey '\e[3~'   delete-char         # DELETE
      bindkey '\eOc'    forward-word        # CTRL+RIGHT
      bindkey '\eOd'    backward-word       # CTRL+LEFT
      bindkey '^[[1;5C' forward-word        # CTRL+RIGHT
      bindkey '^[[1;5D' backward-word       # CTRL+LEFT
      ;;
  esac

# ZSH DISABLE USER COMPLETION FOR THESE NAMES
  zstyle ':completion:*:*:*:users' ignored-patterns \
    dladm dbus distcache dovecot list ftp games gdm gkrellmd gopher gnats \
    adm amanda apache avahi backup beaglidx bin cacti canna clamav daemon \
    sshd sync sys syslog uucp vcsa smmsp svctag upnp unknown webservd xfs \
    listen mdns fax mailman mailnull mldonkey mysql man messagebus netadm \
    hacluster haldaemon halt hsqldb mail junkbust ldap lp irc xvm libuuid \
    nscd ntp nut nx ident openldap operator pcap pkg5srv postfix postgres \
    netcfg nagios noaccess nobody4 openvpn named netdump nfsnobody nobody \
    proxy privoxy pulse pvm quagga radvd rpc rpcuser shutdown statd squid \
    www-data news nuucp zfssnap rpm '_*'


# ZSH OTHER FEATURES
  unsetopt beep
  setopt no_beep
  setopt nohashdirs
  setopt extended_glob
  setopt auto_cd
  setopt auto_menu
  setopt list_rows_first
  setopt multios
  setopt hist_ignore_all_dups
  setopt append_history
  setopt inc_append_history
  setopt hist_reduce_blanks
  setopt always_to_end
  setopt no_hup
  setopt complete_in_word
  limit coredumpsize 0

# COLOR grep(1)
  export GREP_COLOR='1;32'
  export GREP_COLORS='1;32'
  export GREP_OPTIONS='--color=auto'
  alias grep='grep --color'
  alias egrep='egrep --color'

# FreeBSD ifconfig(8) CIDR NOTATION
  export IFCONFIG_FORMAT=inet:cidr

# SET ls(1) COLORS
  export LSCOLORS='exExcxdxcxexhxhxhxbxhx'
  export LS_COLORS='no=00:fi=00:di=00;34:ln=00;36:pi=40;33:so=00;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:ex=00;32'

# DISABLE XON/XOFF FLOW CONTROL (^S/^Q)
  stty -ixon

# COLOR LIST
# 30 - black     # 34 - blue
# 31 - red       # 35 - magenta
# 32 - green     # 36 - cyan
# 33 - yellow    # 37 - white

# COLOR PROMPT
  cSRV="%F{magenta}"
  case $( whoami ) in
    (root)
      cUSR="%F{red}"
      cPMT="%F{red}"
      ;;
    (*)
      cUSR="%F{green}%B"
      cPMT=""
      ;;
  esac
  cTIM="%F{cyan}%B"
  cPWD="%F{magenta}%B"
  cSTD="%b%f"
  export PS1="$cTIM%T$cSTD $cSRV%m$cSTD $cUSR%n$cSTD $cPWD%~$cSTD $cPMT%#$cSTD "
  export PS2="$cTIM%T$cSTD $cUSR>$cSTD $cPWD"

# LS/GLS/EXA
  case $( uname ) in
    (FreeBSD)
      if /usr/bin/env which exa 1> /dev/null 2> /dev/null
      then
        alias bls='/bin/ls -p -G -D "%Y.%m.%d %H:%M"'
        alias gls='gls -p --color=always --time-style=long-iso --group-directories-first --quoting-style=literal'
        alias ls='exa --time-style=long-iso --group-directories-first'
      elif /usr/bin/env which gls 1> /dev/null 2> /dev/null
      then
        alias bls='/bin/ls -p -G -D "%Y.%m.%d %H:%M"'
        alias ls=' gls -p --color=always --time-style=long-iso --group-directories-first --quoting-style=literal'
      else
        alias ls=' /bin/ls -p -G -D "%Y.%m.%d %H:%M"'
      fi
      ;;
    (OpenBSD)
      export PKG_PATH=http://ftp.openbsd.org/pub/OpenBSD/$( uname -r )/packages/$( uname -m )/
      [ -e /usr/local/bin/colorls ] && alias ls='/usr/local/bin/colorls -G'
      ;;
    (Linux)
      if /usr/bin/env which exa 1> /dev/null 2> /dev/null
      then
        alias gls='ls --color=always --time-style=long-iso --group-directories-first --quoting-style=literal'
        alias ls='exa --time-style=long-iso --group-directories-first'
      else
        alias ls='ls -p --color=always --time-style=long-iso --group-directories-first --quoting-style=literal'
      fi
      ;;
  esac
  #alias la='ls -A'
  alias ll='ls -l'
  alias exa='exa --time-style=long-iso --group-directories-first'

