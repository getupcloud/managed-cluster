#!/usr/bin/env bash

shopt -s nullglob
shopt -s checkwinsize

export INSIDE_CONTAINER=${INSIDE_CONTAINER:-false}

export COLOR_BLACK="$(tput setaf 1)"
export COLOR_RED="$(tput setaf 1)"
export COLOR_GREEN="$(tput setaf 2)"
export COLOR_YELLOW="$(tput setaf 3)"
export COLOR_BLUE="$(tput setaf 4)"
export COLOR_MAGENTA="$(tput setaf 5)"
export COLOR_CYAN="$(tput setaf 6)"
export COLOR_WHITE="$(tput setaf 7)"
export COLOR_GRAY="$(tput setaf 8)"
export COLOR_BOLD="$(tput bold)"
export COLOR_RESET="$(tput sgr0)"

save_opt()
{
    for i; do
        [ ${-//$i/} != $- ] && state="-$i" || state="+$i"
        export _SAVE_OPT_$i="$state"
    done
}

load_opt()
{
    for i; do
        local state=_SAVE_OPT_$i
        set ${!state}
    done
}

source_env()
{
    if ! [ -e "$1" ]; then
        verb "Reading $1: not found"
        return
    fi
    verb "Reading $1"
    save_opt a
    set -a
    source $1
    load_opt a
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
    local _config_file="${3}"

    export "$1"

    if grep -q "^\s*${_name}=.*" $_config_file 2>/dev/null; then
        sed -i -e "s|^\s*${_name}=.*|$1|" $_config_file
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
    echo -e "${COLOR_RESET}DEBUG[${BASH_LINENO[0]}]: $@" >&2
}

debugn()
{
    echo -ne "${COLOR_RESET}DEBUG[${BASH_LINENO[0]}]: $@" >&2
}

verb()
{
    if ! ${verbose:-false}; then
        return
    fi
    echo -e "${COLOR_GRAY}$@${COLOR_RESET}" >&2
}

verbn()
{
    if ! ${verbose:-false}; then
        return
    fi
    echo -ne "${COLOR_GRAY}$@${COLOR_RESET}" >&2
}

info()
{
    echo -e "${COLOR_YELLOW}$@${COLOR_RESET}" >&2
}

infon()
{
    echo -ne "${COLOR_YELLOW}$@${COLOR_RESET}" >&2
}

note()
{
    echo -e "${COLOR_CYAN}NOTICE: $@${COLOR_RESET}" >&2
}

noten()
{
    echo -ne "${COLOR_CYAN}NOTICE: $@${COLOR_RESET}" >&2
}

warn()
{
    echo -e "${COLOR_RED}${COLOR_BOLD}WARNING[${BASH_LINENO[0]}]: $@${COLOR_RESET}" >&2
}

warnn()
{
    echo -ne "${COLOR_RED}${COLOR_BOLD}WARNING[${BASH_LINENO[0]}]: $@${COLOR_RESET}" >&2
}

line()
{
    if [ -n "$COLUMNS" ]; then ## requires interactive shell (-i)
        local COLUMNS=20
    fi

    printf "%-${COLUMNS}s" ${1:--} | tr ' ' ${1:--}
    echo
}

read_config()
{
    local _name="${1}"
    local _opt_name="opt_$_name"
    local _opt_value="${!_opt_name}"
    local _default="${!_name}"
    shift
    local prompt="$@"

    if [ -n "$_default" ]; then
        prompt+=" [$_default]"
    fi
    if [ -n "$_opt_value" ]; then
        #prompt "$prompt <- Using command line parameter."
        #echo
        export "$_name=$_opt_value"
        return
    fi

    line
    read -e -p "$(prompt "$prompt")" $_name

    local _value="${!_name}"
    if [ -z "$_value" ]; then
        export $_name="$_default"
    else
        export $_name
    fi
}

ask()
{
  unset ask_response
  read -e -p "$(prompt COLOR_GREEN "$@")" ask_response
  export ask_response="${ask_response:-y}"

  case "${ask_response,,}" in
    y|yes|s|sim) return 0;;
    *) return 1
  esac
}

ask_any()
{
  unset ask_response
  read -e -p "$(prompt COLOR_GREEN "$@")" ask_response
  export ask_response="${ask_response}"
}

#input()
#{
#  local _name="$1"
#  local _prompt="$2"
#  local _default="$3"
#  local _value
#
#  if [ -v _default ]; then
#    read -e -p "$(prompt COLOR_GREEN "$_prompt [$_default]")" _value
#    if [ -z "$_value" ]; then
#      _value="$_default"
#    fi
#  else
#    read -e -p "$(prompt COLOR_GREEN "$_prompt")" _value
#  fi
#
#  export "$_name=$_value"
#}
#
#input_no_empty()
#{
#    local _name="$1"
#    unset $_name
#    while [ -z "${!_name}" ]; do
#        input "$@"
#    done
#}

ask_execute_command()
{
  if [ $BASH_VERSINFO -lt 5 ];
    read -e -p "$(prompt COLOR_GREEN "Execute [${COLOR_BOLD}${@}${COLOR_RESET}${COLOR_GREEN}] now? [Y/n]")" res
  else
    read -e -p "$(prompt COLOR_GREEN "Execute [${COLOR_BOLD}${@@Q}${COLOR_RESET}${COLOR_GREEN}] now? [Y/n]")" res
  fi

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

git_remote()
{
    local GIT_VERSION=$(git version | awk '{print $3}')
    case $GIT_VERSION in
        1.*)
            GIT_DIR=${REPO_DIR:-.}/.git git remote -v 2>/dev/null | grep -m1 "^$1" | awk '{print $2}' || true
            ;;
        2.*)
            GIT_DIR=${REPO_DIR:-.}/.git git remote get-url "$1" 2>/dev/null || true
    esac
}

has_remote()
{
    [ -n "$(git_remote $1)" ]
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
    if [ -e $CLUSTER_DIR/cacerts.crt ]; then
        cp -f $CLUSTER_DIR/cacerts.crt /usr/local/share/ca-certificates/cacerts.crt
        update-ca-certificates
    fi
}

run_as_user()
{
    if [ $CONTAINER_USER_ID -eq $(id -u) ]; then
        if [ $CONTAINER_USER_ID -ne 0 ]; then
            CONTAINER_USER=$(id -nu $CONTAINER_USER_ID)
            #info "Running as user $CONTAINER_USER ($CONTAINER_USER_ID)"
        fi
        return 0
    fi

    CONTAINER_GROUP=$(getent group $CONTAINER_GROUP_ID 2>/dev/null | cut -f1 -d:)
    if [ -z "$CONTAINER_GROUP" ]; then
        CONTAINER_GROUP=getup
        #info "Creating group $CONTAINER_GROUP ($CONTAINER_GROUP_ID)"
        groupadd $CONTAINER_GROUP -g $CONTAINER_GROUP_ID
    fi
    export CONTAINER_GROUP

    if ! CONTAINER_USER=$(id -nu $CONTAINER_USER_ID 2>/dev/null); then
        CONTAINER_USER=getup
        #info "Creating user $CONTAINER_USER ($CONTAINER_USER_ID)"
        useradd $CONTAINER_USER -u $CONTAINER_USER_ID -g $CONTAINER_GROUP_ID -G wheel -m -k /etc/skel
    fi
    export CONTAINER_USER
    export HOME=/home/$CONTAINER_USER

    shopt -s dotglob
    if [ -d $HOME ]; then
        install -o $CONTAINER_USER_ID -g $CONTAINER_GROUP_ID -m 700 /etc/skel/* $HOME/
    fi

    for src in .gitconfig .ssh .tsh .vimrc; do
        if [ -d "/home/_host/$src" ]; then
            cp -an /home/_host/$src $HOME/
        elif [ -e "/home/_host/$src" ]; then
            install -o $CONTAINER_USER_ID -g $CONTAINER_GROUP_ID -m 700 "/home/_host/$src" $HOME/
        fi
    done
    shopt -u dotglob

    # copy generated identity file if host's user has no private key
    if [ -d $HOME/.ssh ] && [ -e $CLUSTER_DIR/identity ]; then
        local key_type=$(ssh-keygen -yf $CLUSTER_DIR/identity | cut -f 1 -d' ')

        case "$key_type" in
            ecdsa*) private_key_path=$HOME/.ssh/id_ecdsa;;
            ssh-rsa) private_key_path=$HOME/.ssh/id_rsa;;
            ssh-dss) private_key_path=$HOME/.ssh/id_dsa
        esac

        if ! [ -e "$private_key_path" ]; then
            cp $CLUSTER_DIR/identity $private_key_path
            ssh-keygen -yf $CLUSTER_DIR/identity > ${private_key_path}.pub
            chmod 400 $private_key_path
        fi
    fi

    if [ -d $HOME/.kube ]; then
        rm -rf $HOME/.kube
    fi
    ln -fs ${KUBECONFIG%/*} $HOME/.kube
    ln -fs $CLUSTER_DIR/.local $HOME/.local
    mkdir -p $CLUSTER_DIR/.local

    chown -R $CONTAINER_USER_ID:$CONTAINER_GROUP_ID $REPO_DIR $HOME/

    # from oh-my-bash installer
    #sed -e "s|^export OSH=.*|export OSH=$OSH|" $OSH/templates/bashrc.osh-template >> /home/$CONTAINER_USER/.bashrc
    #echo DISABLE_AUTO_UPDATE=true >> /home/$CONTAINER_USER/.bashrc
    #ln -s /home/$CONTAINER_USER/.bashrc /home/$CONTAINER_USER/.bash_profile
    #chown -R $CONTAINER_USER. /home/$CONTAINER_USER

    exec setpriv --reuid=$CONTAINER_USER_ID --regid=$CONTAINER_GROUP_ID --init-groups /usr/local/bin/entrypoint "$@" || exit 2
}

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

function update_globals()
{
    if [ -d $CLUSTER_DIR ]; then
        export CLUSTER_CONF="$CLUSTER_DIR/cluster.conf"
        source_env "$CLUSTER_CONF"
    fi

    if [ -v type ]; then
        export TEMPLATE_DIR=$TEMPLATES_DIR/$type
    fi
    if ! [ -v TELEPORT_PROXY ]; then
        export TELEPORT_PROXY=getup.teleport.sh
    fi
}

if ! [ -v ROOT_DIR ]; then
    export ROOT_DIR=$(readlink -ne $(dirname $0))
fi

if $INSIDE_CONTAINER; then
    pathmunge $REPO_DIR after
    export PROVIDER_ENV="$CLUSTER_DIR/provider.env"
    source_env "$PROVIDER_ENV"
    source_env $ROOT_DIR/.dockerenv
else
    export REPO_DIR=$ROOT_DIR
fi

export TEMPLATES_DIR=$REPO_DIR/templates
export REPO_CONF=$REPO_DIR/repo.conf

source_env "$REPO_CONF"
update_globals
