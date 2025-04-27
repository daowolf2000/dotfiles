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
if tty -s && [ -n "$TERM" ] && [ "$TERM" != dumb ] && [ -n "$GRC" ]; then
	for cmd in g++ gas head make ld ping6 tail traceroute6 $( ls /usr/share/grc/ ); do
		cmd="${cmd##*conf.}"
		type "${cmd}" >/dev/null 2>&1 && alias "${cmd}"="$( which grc ) --colour=auto ${cmd}"
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

# Включаем автодополнение команд (если доступно)
if [ -f "/etc/bash_completion" ]; then
   source "/etc/bash_completion"
fi

# Включаем автодополнение команд (если доступно)
if [ -f "$HOME/.bash_aliases" ]; then
   source "$HOME/.bash_aliases"
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
# setup color variables
color_is_on=
color_red=
color_green=
color_yellow=
color_blue=
color_white=
color_gray=
color_bg_red=
color_off=
color_user=
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_is_on=true
	color_black="\[$(/usr/bin/tput setaf 0)\]"
	color_red="\[$(/usr/bin/tput setaf 1)\]"
	color_green="\[$(/usr/bin/tput setaf 2)\]"
	color_yellow="\[$(/usr/bin/tput setaf 3)\]"
	color_blue="\[$(/usr/bin/tput setaf 6)\]"
	color_white="\[$(/usr/bin/tput setaf 7)\]"
	color_gray="\[$(/usr/bin/tput setaf 8)\]"
	color_off="\[$(/usr/bin/tput sgr0)\]"

	color_error="$(/usr/bin/tput setab 1)$(/usr/bin/tput setaf 7)"
	color_error_off="$(/usr/bin/tput sgr0)"

	# set user color
	case `id -u` in
		0) color_user=$color_red ;;
		*) color_user=$color_green ;;
	esac
fi

# some kind of optimization - check if git installed only on config load
PS1_GIT_BIN=$(which git 2>/dev/null)
LOCAL_HOSTNAME=$HOSTNAME

function prompt_command {
	local PS1_GIT=
	local PS1_VENV=
	local GIT_BRANCH=
	local GIT_DIRTY=
	local PWDNAME=$PWD

	# beautify working directory name
	if [[ "${HOME}" == "${PWD}" ]]; then
		PWDNAME="~"
	elif [[ "${HOME}" == "${PWD:0:${#HOME}}" ]]; then
		PWDNAME="~${PWD:${#HOME}}"
	fi

	# parse git status and get git variables
	if [[ ! -z $PS1_GIT_BIN ]]; then
		# check we are in git repo
		local CUR_DIR=$PWD
		while [[ ! -d "${CUR_DIR}/.git" ]] && [[ ! "${CUR_DIR}" == "/" ]] && [[ ! "${CUR_DIR}" == "~" ]] && [[ ! "${CUR_DIR}" == "" ]]; do CUR_DIR=${CUR_DIR%/*}; done
		if [[ -d "${CUR_DIR}/.git" ]]; then
			# 'git repo for dotfiles' fix: show git status only in home dir and other git repos
			if [[ "${CUR_DIR}" != "${HOME}" ]] || [[ "${PWD}" == "${HOME}" ]]; then
				# get git branch
				GIT_BRANCH=$($PS1_GIT_BIN symbolic-ref HEAD 2>/dev/null)
				if [[ ! -z $GIT_BRANCH ]]; then
					GIT_BRANCH=${GIT_BRANCH#refs/heads/}

					# get git status
					local GIT_STATUS=$($PS1_GIT_BIN status --porcelain 2>/dev/null)
					[[ -n $GIT_STATUS ]] && GIT_DIRTY=1
				fi
			fi
		fi
	fi

	# build b/w prompt for git and virtual env
	[[ ! -z $GIT_BRANCH ]] && PS1_GIT=" (git: ${GIT_BRANCH})"
	[[ ! -z $VIRTUAL_ENV ]] && PS1_VENV=" (venv: ${VIRTUAL_ENV#$HOME\/})"

	# calculate prompt length
	local PS1_length=$((${#USER}+${#LOCAL_HOSTNAME}+${#PWDNAME}+${#PS1_GIT}+${#PS1_VENV}+3))
	local FILL=

	# if length is greater, than terminal width
	if [[ $PS1_length -gt $COLUMNS ]]; then
		# strip working directory name
		PWDNAME="...${PWDNAME:$(($PS1_length-$COLUMNS+3))}"
	else
		# else calculate fillsize
		local fillsize=$(($COLUMNS-$PS1_length))
		FILL=$color_white
		while [[ $fillsize -gt 0 ]]; do FILL="${FILL}-"; fillsize=$(($fillsize-1)); done
		FILL="${FILL}${color_off}"
	fi

	if $color_is_on; then
		# build git status for prompt
		if [[ ! -z $GIT_BRANCH ]]; then
			if [[ -z $GIT_DIRTY ]]; then
				PS1_GIT=" (git: ${color_green}${GIT_BRANCH}${color_off})"
			else
				PS1_GIT=" (git: ${color_red}${GIT_BRANCH}${color_off})"
			fi
		fi

		# build python venv status for prompt
		[[ ! -z $VIRTUAL_ENV ]] && PS1_VENV=" (venv: ${color_blue}${VIRTUAL_ENV#$HOME\/}${color_off})"
	fi

	# set new color prompt
	PS1="\n${color_user}${USER}${color_off}@${color_yellow}${LOCAL_HOSTNAME}${color_off}:${color_blue}${PWDNAME}${color_off}${PS1_GIT}${PS1_VENV} ${FILL}\n🔹"

	# get cursor position and add new line if we're not in first column
	# cool'n'dirty trick (http://stackoverflow.com/a/2575525/1164595)
	# XXX FIXME: this hack broke ssh =(
#	exec < /dev/tty
#	local OLDSTTY=$(stty -g)
#	stty raw -echo min 0
#	echo -en "\033[6n" > /dev/tty && read -sdR CURPOS
#	stty $OLDSTTY
	echo -en "\033[6n" && read -sdR CURPOS
	[[ ${CURPOS##*;} -gt 1 ]] && echo "${color_error}↵${color_error_off}"

	# set title
	echo -ne "\033]0;${USER}@${LOCAL_HOSTNAME}:${PWDNAME}"; echo -ne "\007"
}

# set prompt command (title update and color prompt)
PROMPT_COMMAND="history -a; prompt_command"
# set new b/w prompt (will be overwritten in 'prompt_command' later for color prompt)
PS1='\u@${LOCAL_HOSTNAME}:\w\$ '

#export PATH=$PATH:$HOME/.local/bin


complete -C /usr/local/bin/terraform terraform

###
export DIRENV_LOG_FORMAT=
eval "$(direnv hook bash)"   # или для zsh/fish аналогично
