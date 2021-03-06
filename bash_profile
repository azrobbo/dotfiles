# ~/.bash_profile

# simple prompt
# export PS1="\[\e[00;33m\]\u\[\e[0m\]\[\e[00;37m\] at \[\e[0m\]\[\e[00;32m\]\h\[\e[0m\]\[\e[00;37m\] in \[\e[0m\]\[\e[00;34m\]\w\[\e[0m\]\[\e[00;37m\] \\$\[\e[0m\] "

# aliases
if [ -e "$HOME/.aliases" ]; then
  source "$HOME/.aliases"
fi

# load private environment variables
if [ -e "$HOME/.private.sh" ]; then
  source "$HOME/.private.sh"
fi


#
# PROMPT
#

# Cygwin is special
if [ ! -z ${OSTYPE} ]; then
 case $(uname) in
 	"CYGWIN*")
		export OSTYPE='CYGWIN'
		;;
	'Darwin')
		export OSTYPE='Darwin'
		;;
	'Linux')
		export OSTYPE='Linux'
		;;
	esac
fi

# Just calculate these once, to save a few cycles when displaying the prompt

if [ "$OSTYPE" = "CYGWIN" ]; then
	export __bash_prompt_hostname=$(/bin/hostname)
else
	export __bash_prompt_hostname=$(hostname -s)
fi


# Reference (https://wiki.archlinux.org/index.php/Color_Bash_Prompt)
# Reset
# Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# # Bold
# BBlack='\e[1;30m'       # Black
# BRed='\e[1;31m'         # Red
# BGreen='\e[1;32m'       # Green
# BYellow='\e[1;33m'      # Yellow
# BBlue='\e[1;34m'        # Blue
# BPurple='\e[1;35m'      # Purple
# BCyan='\e[1;36m'        # Cyan
# BWhite='\e[1;37m'       # White

# # Underline
# UBlack='\e[4;30m'       # Black
# URed='\e[4;31m'         # Red
# UGreen='\e[4;32m'       # Green
# UYellow='\e[4;33m'      # Yellow
# UBlue='\e[4;34m'        # Blue
# UPurple='\e[4;35m'      # Purple
# UCyan='\e[4;36m'        # Cyan
# UWhite='\e[4;37m'       # White

# # Background
# On_Black='\e[40m'       # Black
# On_Red='\e[41m'         # Red
# On_Green='\e[42m'       # Green
# On_Yellow='\e[43m'      # Yellow
# On_Blue='\e[44m'        # Blue
# On_Purple='\e[45m'      # Purple
# On_Cyan='\e[46m'        # Cyan
# On_White='\e[47m'       # White

# # High Intensity
# IBlack='\e[0;90m'       # Black
# IRed='\e[0;91m'         # Red
# IGreen='\e[0;92m'       # Green
# IYellow='\e[0;93m'      # Yellow
# IBlue='\e[0;94m'        # Blue
# IPurple='\e[0;95m'      # Purple
# ICyan='\e[0;96m'        # Cyan
# IWhite='\e[0;97m'       # White

# # Bold High Intensity
# BIBlack='\e[1;90m'      # Black
# BIRed='\e[1;91m'        # Red
# BIGreen='\e[1;92m'      # Green
# BIYellow='\e[1;93m'     # Yellow
# BIBlue='\e[1;94m'       # Blue
# BIPurple='\e[1;95m'     # Purple
# BICyan='\e[1;96m'       # Cyan
# BIWhite='\e[1;97m'      # White

# # High Intensity backgrounds
# On_IBlack='\e[0;100m'   # Black
# On_IRed='\e[0;101m'     # Red
# On_IGreen='\e[0;102m'   # Green
# On_IYellow='\e[0;103m'  # Yellow
# On_IBlue='\e[0;104m'    # Blue
# On_IPurple='\e[0;105m'  # Purple
# On_ICyan='\e[0;106m'    # Cyan
# On_IWhite='\e[0;107m'   # White

# Non Standard Colors
Gray='\e[38;5;241m'
ce='\e[48;5;165m\e[38;5;007m'

normal='\e[0m'



function bash_prompt {
	last_status=$?
  # Print last command status if nonzero
  if [ "$last_status" -ne 0 ]; then
    echo -e -n "$ce$last_status "
  fi

	if [ -n "$SSH_CLIENT" ]; then
		echo -e -n "$Yellow$USER$Gray at $Green$__bash_prompt_hostname$Gray in "
	fi

	# Directory
  # 1st expression replaces home dir with '~'
  # 2nd expression colorizes forward slashes
  # 3rd expression colorizes the deepest path (the 'm' is the last char in the
  # ANSI color code that needs to be stripped)
  echo -e -n $Cyan$(pwd | sed -e "s:^${HOME}:~:" -e "s,/,/,g")

	if git rev-parse --is-inside-work-tree 2>/dev/null >/dev/null; then
		# branch name
		git_branch=$(git symbolic-ref HEAD 2>/dev/null | sed 's|^refs/heads/||')
		echo -e -n "$Gray git $Purple$git_branch"
		dirty=$(git status --porcelain --ignore-submodules 2>/dev/null)
		if [ -n "$dirty" ]; then
      # repo is dirty
      echo -e -n "*"
   	fi
  fi

  # Python / virtualenv
  if [ -n "$VIRTUAL_ENV" ]; then
    echo -e -n "$Gray venv $Blue" $(basename $VIRTUAL_ENV)
  fi

  # Display job count if nonzero
  job_count=$(jobs | wc -l | awk '{ print $1; }')
  job_count=$((job_count-1))
  if [ $job_count -gt 0 ]; then
    echo -e -n " $Blue$job_count ${Gray}job"
    if [ $job_count -gt 1 ]; then
      # make jobs plural
      echo -e -n "s"
    fi
  fi

  # Display tmux session count if not in tmux already
  if [ -z "$TMUX" ]; then
    session_count=$(tmux ls 2>/dev/null | wc -l | awk '{ print $1; }')
    if [ $session_count -gt 0 ]; then
      echo -e -n " $Cyan$session_count ${Gray}tmux"
      if [ $session_count -gt 1 ]; then
        # make sessions plural
        echo -e -n "es"
      fi
    fi
  fi

  # The Cygwin/mintty/fish combination doesn't handle multi-line prompts well
  # if [ "$OSTYPE" != 'CYGWIN' ]; then
    echo -e -n '\n'
  # fi

  echo -e -n "$normal"
}

# Prompt delimiter
export PS1="\$ "

export PROMPT_COMMAND='bash_prompt'