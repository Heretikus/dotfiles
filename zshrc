# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

### Do we run interactively?
[[ $- != *i* ]] && return

# custom completion scripts
fpath=($HOME/dotfiles/completions $fpath)

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment this to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
# DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment following line if you want to  shown in the command execution time stamp
# in the history command output. The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|
# yyyy-mm-dd
# HIST_STAMPS="mm/dd/yyyy"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(docker docker-compose)

source $ZSH/oh-my-zsh.sh

# User configuration

export PATH=$HOME/bin:/usr/local/bin:$PATH

# DETECT CHRUBY support

if [[ -d /usr/local/share/chruby/ ]]; then
	# Linux installation of chruby
	chruby_path=/usr/local/share/chruby/
elif [[ -d /usr/local/opt/chruby/share/chruby/ ]]; then
	# Homebrew installation of chruby
	chruby_path=/usr/local/opt/chruby/share/chruby/
fi

if [[ -d $chruby_path ]]; then
	source $chruby_path/chruby.sh
	source $chruby_path/auto.sh
fi

# # Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='nano'
 else
   export EDITOR='nano'
 fi

if [[ -f /usr/bin/direnv ]]; then
# direnv
eval "$(direnv hook zsh)"
fi

# ssh - add's github public ssh keys to authorized_keys of the current host
alias authorize_me='curl -L http://bit.ly/lexxkeys | bash -s'
alias mykey='xclip -selection c -i ~/.ssh/id_rsa.pub'

# sharing
alias sessionshare='screen -d -m -S shared'
alias sessionjoin='screen -x shared'

alias wanip='getent hosts `dig +short myip.opendns.com @resolver1.opendns.com`'

# source management
alias reset_rights_here='find -type f -exec chmod --changes 644 {} + -o -type d -exec chmod --changes 755 {} +'

if [[ -f ~/.nvm/nvm.sh ]]; then

source ~/.nvm/nvm.sh

# place this after nvm initialization!
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

fi

# Python development

if [[ -f /usr/local/bin/virtualenvwrapper.sh ]]; then

mkdir -p ~/.virtualenvs
export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh

fi

# Autoload ssh agent
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
#    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add > /dev/null;
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

if [[ -n $SSH_CONNECTION ]]; then
echo " .... remote session `echo $USER`@`hostname` .... "
#PROMPT="%{$fg_bold[yellow]%}⇕ ${ret_status} %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)"
PROMPT=$'%{$fg[yellow]%}┌%{$fg_bold[yellow]%}[⇕]%{$reset_color%}$fg[yellow]%}[%{$fg[cyan]%}%c%{$reset_color%}%{$fg[yellow]%}]> %{$(git_prompt_info)%}%(?,,%{$fg[yellow]%}[%{$fg_bold[white]%}%?%{$reset_color%}%{$fg[yellow]%}])
%{$fg[yellow]%}└──${ret_status}%{$reset_color%}'
PS2=$' %{$fg[green]%}|>%{$reset_color%} '

else
PROMPT=$'%{$fg[yellow]%}┌[%{$fg[cyan]%}%c%{$reset_color%}%{$fg[yellow]%}]> %{$(git_prompt_info)%}%(?,,%{$fg[yellow]%}[%{$fg_bold[white]%}%?%{$reset_color%}%{$fg[yellow]%}])
%{$fg[yellow]%}└──${ret_status}%{$reset_color%}'
PS2=$' %{$fg[green]%}|>%{$reset_color%} '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}[%{$fg_bold[white]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}%{$fg[yellow]%}] "
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[yellow]%}⚡%{$reset_color%}"
fi

# Anything locally specific?
if [[ -f ${HOME}/.zshrc.local ]]; then source ${HOME}/.zshrc.local; fi
