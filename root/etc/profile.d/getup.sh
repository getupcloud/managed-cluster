#!/usr/bin/env bash


shopt -s checkwinsize
shopt -s nullglob

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

source_env_tf()
{
    if ! [ -e "$1" ]; then
        verb "Reading $1: not found"
        return
    fi
    source_env "$1"
    save_opt a
    set -a
    eval $(awk -F= '/^[^#]/{printf("TF_VAR_%s=\"$%s\"\n", $1, $1)}' "$1")
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
        if [ -e "$_config_file" ]; then
            local last_byte=$(tac $_config_file | hexdump -n1 -e '"" 1/1 "%02x"')
            [ "$last_byte" == '0a' ] || echo
        fi
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
    local prompt="${2}"
    local _opt_name="opt_$_name"
    local _secret=${_secret:-false}
    local read_opts='-e'

    if $_secret; then
        read_opts+=' -s'
    fi

    if [ -v "$_opt_name" ]; then
        local _opt_value="${!_opt_name}"
    else
        local _opt_value=""
    fi

    if [ $# -gt 2 ]; then
        local _default="$3"
    elif [ -v "$_name" ]; then
        local _default="${!_name}"
    else
        local _default=""
    fi

    if [ -n "$_default" ]; then
        if $_secret; then
            prompt+=" [${_default//[^*]/*}]"
        else
            prompt+=" [$_default]"
        fi
    fi

    if [ -n "$_opt_value" ]; then
        #prompt "$prompt <- Using command line parameter."
        #echo
        export "$_name=$_opt_value"
        return
    fi

    line
    read $read_opts -p "$(prompt "$prompt")" $_name

    local _value="${!_name}"
    if [ -z "$_value" ]; then
        export $_name="$_default"
    else
        export $_name
    fi
}

function isset_tf_config()
{
    local tf_var_name="$1"

    grep -q '^[[:space:]]*'$tf_var_name'[[:space:]]*=.*' "$TF_VARS_FILE"
}

function exists_tf_config()
{
    local tf_var_name="$1"

    grep -q '^[[:space:]#]*'$tf_var_name'[[:space:]]*=.*' "$TF_VARS_FILE"
}

function unset_tf_config()
{
    local tf_var_name="$1"

    sed -i -e 's|^[[:space:]]*'$tf_var_name'[[:space:]]=.*|#\0|' "$TF_VARS_FILE"
}

function set_tf_config()
{
    set_tf_config_raw "$1" "\"$2\""
}

function set_tf_config_raw()
{
    local tf_var_name="$1"
    local tf_var_value="$2"

    if exists_tf_config "$tf_var_name"; then
        sed -i -e 's|^[[:space:]#]*'$tf_var_name'[[:space:]]*=.*|'$tf_var_name' = '$tf_var_value'|' "$TF_VARS_FILE"
    else
        echo "$tf_var_name = $tf_var_value" >> "$TF_VARS_FILE"
    fi
}

function get_tf_config()
{
    local sh_var_name=$1
    local tf_var_name=$2
    local default=$3

    if [ -v $sh_var_name ]; then
        echo ${!sh_var_name}
        return
    elif [ -v TF_VAR_$tf_var_name ]; then
        local v=TF_VAR_$tf_var_name
        echo ${!v}
        return
    elif [ -e "$TF_VARS_FILE" ]; then
      case "$(hcl2json "$TF_VARS_FILE" | jq -Mrc ".${tf_var_name}|type")" in
          string|number|object|boolean)
              hcl2json "$TF_VARS_FILE" | jq -Mrc ".${tf_var_name}"
              return
          ;;
          array)
              hcl2json "$TF_VARS_FILE" | jq -Mrc ".${tf_var_name}|join(\"\n\")"
              return
      esac
    fi

    echo $default
}

ask()
{
  unset ask_response
  read -e -p "$(prompt COLOR_GREEN "$@")" ask_response
  export ask_response="${ask_response:-${_default:-y}}"

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

function fill_line()
{
  local cmd="$@"
  local cmd_len=${#cmd}
  local line_start_fmt="------- [%s] "
  local line_start=$(printf -- "$line_pre_fmt" '')
  local line_len=$[$(tput cols) - cmd_len - ${#line_start}]

  if [ $line_len -eq 0 ]; then
    local line_end=''
  elif $line_len -lt 0 ]; then
    line_len=$[$(tput cols) + line_len]
    local line_end=$(printf -- '%*s' $line_len|tr ' ' -)
  else
    local line_end=''
  fi

  printf -- "${COLOR_GREEN}${COLOR_BOLD}$line_start_fmt%s${COLOR_RESET}\n" "$cmd" "$line_end"
}

function execute_command_with_time_track()
{
    local cmd="$@"
    local TIMEFORMAT="${COLOR_CYAN}Command [$cmd] took ${COLOR_BOLD}%2lR${COLOR_RESET}"
    time "$@"
}

function execute_command()
{
    if [ $# -eq 0 ]; then
      return
    fi

  fill_line "$@"
  execute_command_with_time_track "$@"
}

function ask_execute_command()
{
  local cmd="$@"
  local default="${default:-y}"

  if [ "$default" == "n" ]; then
    local sel="[y/N]"
  else
    local sel="[Y/n]"
  fi

  read -e -p "$(prompt COLOR_GREEN "Execute [${COLOR_BOLD}${cmd}${COLOR_RESET}${COLOR_GREEN}] now? $sel")" res

  if [ "$default" == "n" ]; then
    res="${res:-n}"
  else
    res="${res:-y}"
  fi

  case "${res,,}" in
    y|yes|s|sim)
        execute_command "$@"
  esac
}

confirm_execute_command()
{
  local cmd="$@"
  local default="${default:-y}"

  if [ "$default" == "n" ]; then
    local sel="[y/N]"
  else
    local sel="[Y/n]"
  fi

  read -e -p "$(prompt COLOR_GREEN "Execute [${COLOR_BOLD}${cmd}${COLOR_RESET}${COLOR_GREEN}] now? $sel")" res

  if [ "$default" == "n" ]; then
    res="${res:-n}"
  else
    res="${res:-y}"
  fi

  case "${res,,}" in
    y|yes|s|sim)
        execute_command "$@"
    ;;
    n|no|nao) return 2
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

is_local_git_repo()
{
    [ -v flux_git_repo ] && grep -q "ssh://git@git.flux-system.svc.cluster.local/git" <<<"$flux_git_repo"
}

get_current_migration_version()
{
    cat $MIGRATION_VERSION_FILE 2>/dev/null
}

set_current_migration_version()
{
    echo $1 > $MIGRATION_VERSION_FILE
}

get_current_cluster_version()
{
    cat $CLUSTER_VERSION_FILE
}

get_current_version()
{
    cat $VERSION_FILE
}

list_versions()
{
    if ! git show v1.0.1 -q -- . &>/dev/null; then
        warn 'Missing git repo tags.'
        warn 'Please run "git fetch --tags upstream main" or use flag "-U|--no-check-update" and try again'
        exit 2
    fi

    GIT_DIR=${REPO_DIR:-.}/.git git tag | grep '^v[0-9]' | cut -c 2- | sort  -V -r
}

get_latest_version()
{
    list_versions | head -1
}

fmt_version()
{
    local v="$1"
    local n="${2:-0}"
    v=( ${v//[.-]/ } )

    if [ ${#v[@]} -eq 0 ]; then
      warn "Invalid version format: $1"
      return 1
    fi

    if [ ${#v[*]} -eq 3 ]; then
      v[3]=999
    fi

    local last=$[ ${#v[*]} - 1 ]
    if [[ "${v[$last]}" =~ [a-z] ]]; then
      v[$last]=${v[$last]/alpha/1}
      v[$last]=${v[$last]/beta/2}
    fi

    if [ "$n" -gt 0 ]; then
        printf "%03d" ${v[@]:0:$n}
    else
        printf "%03d" ${v[@]}
    fi
}

update_ca_certificates()
{
    if [ -e $CLUSTER_DIR/cacerts.crt ]; then
        sudo cp -vf $CLUSTER_DIR/cacerts.crt /etc/pki/ca-trust/source/anchors/custom-cacerts.crt
        sudo update-ca-trust
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

    if [ -n "$DOCKER_SOCK_GID" ]; then
        if getent group $DOCKER_SOCK_GID; then
            DOCKER_SOCK_GROUP="$(getent group $DOCKER_SOCK_GID|cut -f1 -d:)"
        else
            DOCKER_SOCK_GROUP="docker-container"
            groupadd $DOCKER_SOCK_GROUP -g $DOCKER_SOCK_GID
        fi
    fi

    if ! CONTAINER_USER=$(id -nu $CONTAINER_USER_ID 2>/dev/null); then
        CONTAINER_USER=getup
        #info "Creating user $CONTAINER_USER ($CONTAINER_USER_ID)"
        local sudo_group=sudo
        if grep -q ^wheel: /etc/group; then
          sudo_group=wheel
        fi
        useradd $CONTAINER_USER -u $CONTAINER_USER_ID -g $CONTAINER_GROUP_ID -G ${sudo_group}${DOCKER_SOCK_GROUP:+,$DOCKER_SOCK_GROUP} -m -k /etc/skel
    fi

    export CONTAINER_USER
    export HOME=/home/$CONTAINER_USER

    shopt -s dotglob
    if [ -d $HOME ]; then
        install -o $CONTAINER_USER_ID -g $CONTAINER_GROUP_ID -m 700 /etc/skel/* $HOME/
    fi

    for src in .gitconfig .ssh .tsh; do
        if [ -d "/home/_host/$src" ]; then
            cp -a --update /home/_host/$src $HOME/
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
            cp -f $CLUSTER_DIR/identity $private_key_path
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

function get_host_ip()
{
    if which ip &>/dev/null; then
        ip r \
            | awk '/^default/{print $5}' \
            | head -n1 \
            | xargs ip -4 -o a show dev \
            | awk '{print $4}' \
            | cut -f1 -d /
    else
        netstat -nr \
            | awk '/^0.0.0.0/{print $NF}' \
            | head -n1 \
            | xargs ifconfig \
            | awk '/inet /{print $2}'
    fi
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
        case "${customer_name}_${cluster_name}_${cluster_type}" in
            standalone_standalone_standalone)
                ps1_envelope "\[$COLOR_BLUE\]standalone"
            ;;
            *)
                ps1_envelope cluster "\[$COLOR_YELLOW\]${customer_name:-?}\[$COLOR_RESET\]|\[$COLOR_YELLOW\]${cluster_name:-?}\[$COLOR_RESET\]|\[$COLOR_YELLOW\]${cluster_type:-?}"
        esac
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
    for decl; do
      export "$decl"
    done

    if [ -v CLUSTER_DIR ] && [ -d "$CLUSTER_DIR" ]; then
        export CLUSTER_CONF="$CLUSTER_DIR/cluster.conf"
        source_env_tf "$CLUSTER_CONF"
        export MIGRATION_VERSION_FILE=$CLUSTER_DIR/migration.txt
        export CLUSTER_VERSION_FILE=$CLUSTER_DIR/version.txt
    fi

    if [ -v cluster_type ]; then
        export TEMPLATE_DIR=$TEMPLATES_DIR/$cluster_type
    fi

    if [ -v cluster_provider ]; then
        export CLUSTER_PROVIDER_DIR=$TEMPLATES_DIR/providers/$cluster_provider
        export CLUSTER_PROVIDER_TF=$TEMPLATES_DIR/providers/${cluster_provider}_modules.tf
    fi

    if ! [ -v TELEPORT_PROXY ]; then
        export TELEPORT_PROXY=getup.teleport.sh
    fi
}

if ! [ -v ROOT_DIR ]; then
    export ROOT_DIR=$(readlink -nf $(dirname $0))
fi

if $INSIDE_CONTAINER; then
    pathmunge $REPO_DIR after

    export PROVIDER_ENV="$CLUSTER_DIR/provider.env"
    source_env "$PROVIDER_ENV"
    source_env_tf "$PROVIDER_ENV"
    export DOT_PROVIDER_ENV="$CLUSTER_DIR/.provider.env"
    source_env "$DOT_PROVIDER_ENV"

    source_env $ROOT_DIR/.dockerenv
    export CLUSTER_ENV="$CLUSTER_DIR/cluster.env"
    source_env "$CLUSTER_ENV"
    export DOT_CLUSTER_ENV="$CLUSTER_DIR/.cluster.env"
    source_env "$DOT_CLUSTER_ENV"

    if [ "$UID" == 0 ] && [ -v KUBECTL_VERSION ] && [ -x "/usr/local/bin/kubectl_$KUBECTL_VERSION" ]; then
      ln -fs /usr/local/bin/kubectl_$KUBECTL_VERSION /usr/local/bin/kubectl
    fi
else
    export REPO_DIR=$ROOT_DIR
fi

export VERSION_FILE=$REPO_DIR/version.txt
export TEMPLATES_DIR=$REPO_DIR/templates
export REPO_CONF=$REPO_DIR/repo.conf
#export CLUSTER_TYPES="aks doks eks generic gke kind kubespray okd oke"
#export CLUSTER_PROVIDERS="aws azure do gcp none oci"
export CLUSTER_TYPES="aks eks generic gke kind kubespray okd oke"
export CLUSTER_PROVIDERS="aws azure do gcp oci none"

# Mapping cluster types -> providers are valid only for non-managed clusters.
# For managed clusters, code related to provider-specifc features are builtin
# inside terraform-cluster-${type} modules.
declare -A CLUSTER_TYPES_PROVIDERS
CLUSTER_TYPES_PROVIDERS[aks]=none
CLUSTER_TYPES_PROVIDERS[doks]=none
CLUSTER_TYPES_PROVIDERS[eks]=none
CLUSTER_TYPES_PROVIDERS[generic]="$CLUSTER_PROVIDERS"
CLUSTER_TYPES_PROVIDERS[gke]=none
CLUSTER_TYPES_PROVIDERS[kind]="$CLUSTER_PROVIDERS"
CLUSTER_TYPES_PROVIDERS[kubespray]="$CLUSTER_PROVIDERS"
CLUSTER_TYPES_PROVIDERS[okd]="$CLUSTER_PROVIDERS"
CLUSTER_TYPES_PROVIDERS[oke]=none

source_env "$REPO_CONF"
update_globals
