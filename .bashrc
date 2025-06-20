# ~/.bashrc: executed by bash(1) for non-login shells. see /usr/share/doc/bash/examples/startup-files (in the package bash-doc) for examples

# Если запущено не интерактивно, то выход
[ -z "$PS1" ] && return

##########################################################################################
### Разукрашиваем консоль 
##########################################################################################

alias ip='ip --color=auto'
alias diff='diff --color=auto'

export TERM=xterm-color
export GREP_OPTIONS='--color=auto'
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

export LESS='-R --use-color -Dd+r$Du+b'
export MANPAGER='less -R --use-color -Dd+r -Du+b'
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33'

# Если установлен grc, то сгенерировать алиасы для разукрашивания вывода команд
GRC="$(which grc)"
# Список встроенных команд, которые не нужно оборачивать
GRC_BUILTINS="jobs ulimit"
if tty -s && [ -n "$TERM" ] && [ "$TERM" != dumb ] && [ -n "$GRC" ]; then
    for cmd in g++ gas head make ld ping6 tail traceroute6 $(ls /usr/share/grc/); do
        cmd="${cmd##*conf.}"
        # Пропускаем встроенные команды
        if [[ " $GRC_BUILTINS " =~ " $cmd " ]]; then
            continue
        fi
        # Пропускаем php, systemctl, curl, если не нужно
        # if [[ "$cmd" == "php" || "$cmd" == "systemctl" || "$cmd" == "curl" ]]; then
        #     continue
        # fi
        type "${cmd}" >/dev/null 2>&1 && alias "${cmd}"="$GRC --colour=auto ${cmd}"
    done
fi

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias tree='tree -C'
alias bat='batcat -p'

##########################################################################################
### Настраиваем параметры истории
##########################################################################################

# Не помещать в историю дубликаты команд и команды начинающиеся с пробела
HISTCONTROL=ignorespace:ignoredups
# Добавлять в файл истории, а не перезаписывать
shopt -s histappend
# Сохранять многострочные команды одной строкой
shopt -s cmdhist
# Опция histverify позволяет сначала посмотреть, как Bash интерпретирует команду !! или !$ до того, как он на самом деле запустится.
shopt -s histverify
# сохранять историю в файл истории после каждой команды (а не только при логауте)
# PROMPT_COMMAND="history -a; ${PROMPT_COMMAND}"
# Максимальное количество записей, которые может содержать список истории
HISTSIZE=10000
# Максимальное количество строк, которые может содержать файл истории
HISTFILESIZE=20000
# Формат метки времени в файле истории
export HISTTIMEFORMAT="%m.%d-%H:%M  "
# Не сохранять в истории следующие команды
export HISTIGNORE="man *:whoami:id:free:free *:du:du *:mount:df:df *:ls:history:history *:* --help:htop:pwd:* --version:cd *:mc"



##########################################################################################
### Настраиваем параметры интерактивной оболочки
##########################################################################################

# Если имя вводимой команды является именем каталога, то осуществляется переход в этот каталог, как будто была введена команда cd имя_каталога.
shopt -s autocd
# Незначительные ошибки в написании каталога команды cd будут исправляться. Работает только в интерактивном режиме.
shopt -s cdspell
# Перед выходом проверить наличие фоновых задач. Для выхода повторить команду exit.
shopt -s checkjobs
# Проверять размер окна после каждой команды и при необходимости корректировать значение LINES и COLUMNS.
shopt -s checkwinsize
# dirspell — исправление небольших ошибок в написании имени директории при автодополнении;
shopt -s dirspell
# Если включено, bash подставляет имена директорий из переменной во время автодополнения.
shopt -u direxpand
# globstar — позволит использовать конструкцию вида **, обозначающую «все файлы, начиная с текущего каталога, рекурсивно»;
# Очень удобный новый wildchar — например, данная конструкция отобразит все mp3 в текущем и вложенных каталогах: ls **/*.mp3
shopt -s globstar




##########################################################################################
### Подключаем файлы
##########################################################################################

# Включаем алиасы
if [ -f "$HOME/.bash_aliases" ]; then
   source "$HOME/.bash_aliases"
fi

# Включаем автодополнение команд (если доступно)
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


##########################################################################################
### Исправление ошибок
##########################################################################################


# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# this is for delete words by ^W
tty -s && stty werase ^- 2>/dev/null


##########################################################################################
### Настройка строки приглашения (PS1)
##########################################################################################
# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

######################################################

###
export DIRENV_LOG_FORMAT=
PROMPT_COMMAND="history -a"

eval "$(direnv hook bash)"   # или для zsh/fish аналогично
eval "$(starship init bash)"

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# Запуск tmux автоматически при входе в терминал, если не в tmux
# if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
#   tmux attach -t default || tmux new -s default
# fi