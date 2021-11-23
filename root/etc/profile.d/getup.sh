#!/bin/bash

shopt -s nullglob

source_env()
{
    # salve `set -a` state
    [ ${-//a/} != $- ] && on=true || on=false
    set -a
    source $1
    # restore `set -a` if was set before
    $on || set +a
}

# copy from /etc/profile
pathmunge () {
    case ":${PATH}:" in
        *:"$1":*)
            ;;
        *)
            if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
    export PATH
}

set_config()
{
    local _name=${1%%=*}
    local _description="$2"
    local _config_file="${3:-$config_file}"

    export "$1"

    if grep -q "^\s*${_name}=.*" $_config_file; then
        sed -i -e "s|^\s${_name}=.*|$1|" $_config_file
    else
        {
            echo "# $_description"
            echo "$1"
            echo
        } >>$_config_file
    fi
}

prompt()
{
    if [ "${1:0:6}" == COLOR_ ]; then
        local color=${!1}
        shift
    else
        local color=$COLOR_GREEN
    fi
    echo -ne "${color}$@: ${COLOR_RESET}"
}

debug()
{
  echo -e "${COLOR_RESET}$@" >&2
}

debugn()
{
  echo -ne "${COLOR_RESET}$@" >&2
}

info()
{
  echo -e "${COLOR_YELLOW}$@${COLOR_RESET}" >&2
}

infon()
{
  echo -ne "${COLOR_YELLOW}$@${COLOR_RESET}" >&2
}

warn()
{
  echo -e "${COLOR_RED}$@${COLOR_RESET}" >&2
}

warnn()
{
  echo -ne "${COLOR_RED}$@${COLOR_RESET}" >&2
}

read_config()
{
    local _name="${1}"
    if [ -v "$_name" ]; then
        local _value="${!_name}"
    else
        local _value=""
    fi
    shift
    local prompt="$@"

    if [ ! -v "$_name" ] || [ -z "$_value" ]; then
        read -p "$(prompt "$prompt")" $_name
    fi

    local _value="${!_name}"
    if [ -n "$_value" ]; then
        export $_name
    else
        return 1
    fi
}

ask()
{
  local res
  read -p "$(prompt COLOR_GREEN "$@")" res
  res="${res:-y}"

  case "${res,,}" in
    y|yes|s|sim) return 0;;
    *) return 1
  esac
}

ask_execute_command()
{
  read -p "$(prompt COLOR_GREEN "Execute \"${COLOR_BOLD}${@}${COLOR_RESET}${COLOR_GREEN}\" now? [Y/n]")" res
  res="${res:-y}"

  case "${res,,}" in
    y|yes|s|sim) "$@"
  esac
}

has_valid_config()
{
    if ! [ -r "$1" ]; then
        warn Config not found: $1
        return 1
    fi
}

git_owner()
{
    git-url "$1" owner
}

git_name()
{
    git-url "$1" repo
}

git_owner_name()
{
    echo $(git_owner $1)/$(git_name $1)
}

has_remote()
{
    local remote=$1

    GIT_DIR=${REPODIR:-.}/.git git remote get-url $remote &>/dev/null
}

repo_match()
{
    local repo1="$1"
    local repo2="$2"

    repo1_owner_name=$(git_owner_name $repo1)
    repo2_owner_name=$(git_owner_name $repo2)

    [ "$repo1_owner_name" == "$repo2_owner_name" ]
}

update_ca_certificates()
{
    if [ -e $CLUSTERDIR/cacerts.crt ]; then
        cp -f $CLUSTERDIR/cacerts.crt /usr/local/share/ca-certificates/cacerts.crt
        update-ca-certificates
    fi
}

run_as_user()
{
    if [ $CONTAINER_USER_ID -eq $(id -u) ]; then
        if [ $CONTAINER_USER_ID -ne 0 ]; then
            : warn "Already running as $CONTAINER_USER ($CONTAINER_USER_ID)"
        fi
        return 0
    fi

    info Creating user $CONTAINER_USER
    [ -d $CONTAINER_HOME ] && has_home=true || has_home=false
    #groupadd $CONTAINER_GROUP -g $CONTAINER_GROUP_ID
    useradd $CONTAINER_USER -u $CONTAINER_USER_ID -U -G wheel -m -k /etc/skel
    shopt -s dotglob
    $has_home || install -o $CONTAINER_USER -g $CONTAINER_GROUP -m 700 /etc/skel/* $CONTAINER_HOME/

    for src in .gitconfig .ssh .tsh; do
        if [ -d "/home/_host/$src" ]; then
            cp -an /home/_host/$src $CONTAINER_HOME/
        elif [ -e "/home/_host/$src" ]; then
            install -o $CONTAINER_USER -g $CONTAINER_GROUP -m 700 "/home/_host/$src" $CONTAINER_HOME/
        fi
    done
    shopt -u dotglob

    chown -R $CONTAINER_USER:$CONTAINER_GROUP $REPODIR

    # from oh-my-bash installer
    #sed -e "s|^export OSH=.*|export OSH=$OSH|" $OSH/templates/bashrc.osh-template >> /home/$CONTAINER_USER/.bashrc
    #echo DISABLE_AUTO_UPDATE=true >> /home/$CONTAINER_USER/.bashrc
    #ln -s /home/$CONTAINER_USER/.bashrc /home/$CONTAINER_USER/.bash_profile
    #chown -R $CONTAINER_USER. /home/$CONTAINER_USER

    exec setpriv --reuid=$CONTAINER_USER_ID --regid=$CONTAINER_GROUP_ID --init-groups /usr/local/bin/entrypoint "$@" || exit 2
}

if [ -v CLUSTERDIR ]; then
    if [ -r $CLUSTERDIR/cluster.conf ]; then
        source_env $CLUSTERDIR/cluster.conf
    fi

    if [ -e $CLUSTERDIR/provider.env ]; then
        source_env $CLUSTERDIR/provider.env
    fi
fi

if [ -v REPODIR ] && [ -r $REPODIR/.dockerenv ]; then
    source_env $REPODIR/.dockerenv
fi

export COLOR_BLACK="$(tput setaf 1)"
export COLOR_RED="$(tput setaf 1)"
export COLOR_GREEN="$(tput setaf 2)"
export COLOR_YELLOW="$(tput setaf 3)"
export COLOR_BLUE="$(tput setaf 4)"
export COLOR_MAGENTA="$(tput setaf 5)"
export COLOR_CYAN="$(tput setaf 6)"
export COLOR_WHITE="$(tput setaf 7)"
export COLOR_BOLD="$(tput bold)"
export COLOR_RESET="$(tput sgr0)"

if [ -t 0 ]; then
    alias l='ls -la --color'
    alias t='terraform'
    alias ti='terraform init'
    alias tv='terraform validate'
    alias tp='terraform plan'
    alias ta='terraform apply'
    alias tay='terraform apply -auto-approve'
    alias tf='terraform fmt'
    alias tva='tv && ta'
    alias tiva='ti && tv && ta'
    alias tgu='terraform get'
    alias tgu='terraform get -update'

    export GIT_PS1_SHOWCOLORHINTS=true
    export GIT_PS1_SHOWDIRTYSTATE=true
    export GIT_PS1_SHOWSTASHSTATE=true
    export GIT_PS1_SHOWUNTRACKEDFILES=true
    export GIT_PS1_SHOWUPSTREAM=auto
    export KUBE_PS1_SYMBOL_ENABLE=false
    #export KUBE_PS1_SYMBOL_USE_IMG=true
    unset KUBE_PS1_PREFIX
    unset KUBE_PS1_SUFFIX

    : ${ps1_color:=true}
    export ps1_color
    ps1_color()
    {
        case $1 in
            1|on|true|y|yes) ps1_color=true;;
            *) ps1_color=false
        esac
    }

    ps1_envelope()
    {
        [ -n "$2" ] || return
        local n="$1"
        local v="$2"
        $ps1_color &&
            echo -e "\[$COLOR_GREEN\]${n}\[$COLOR_RESET\]($v\[$COLOR_RESET\])" ||
            echo -e "${n}($v)"
    }

    ps1_cluster()
    {
        if [ -v customer ]; then
            case "$customer_$name_$type" in
                standalone_standalone_standalone)
                  ps1_envelope "\[$COLOR_BLUE\]standalone"
                ;;
                *)
                   ps1_envelope cluster "\[$COLOR_YELLOW\]$customer\[$COLOR_RESET\]|\[$COLOR_YELLOW\]$name\[$COLOR_RESET\]|\[$COLOR_YELLOW\]$type"
            esac
        else
           ps1_envelope cluster '???'
        fi
    }

    do_ps1()
    {
        local git_ps1="$(__git_ps1 %s)"
        local k8s_ps1="$(kube_ps1)"
        local ps1=""

        $ps1_color && ps1+="\[$COLOR_BOLD\]"
        ps1+="[\w "
        $ps1_color && ps1+="\[$COLOR_RESET\]"
        ps1+="$(ps1_cluster)"
        [ -n "$git_ps1" ] && ps1+=" $(ps1_envelope git $git_ps1)"
        [ -n "$k8s_ps1" ] && ps1+=" $(ps1_envelope k8s $k8s_ps1)"
        $ps1_color && ps1+="\[$COLOR_BOLD\]"
        ps1+="]\\\$ "
        $ps1_color && ps1+="\[$COLOR_RESET\]"

        PS1="$ps1"
    }
    export PROMPT_COMMAND=do_ps1
fi
