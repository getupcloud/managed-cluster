#!/bin/bash

source_env()
{
    # salve `set -a` state
    [ ${-//a/} != $- ] && on=true || on=false
    set -a
    source $1
    # restore `set -a` if was set before
    $on || set +a
}


if [ -v WORKDIR ] && [ -r $WORKDIR/cluster.conf ]; then
    source_env $WORKDIR/cluster.conf
fi

if [ -e /etc/profile.d/kubectl_aliases.sh ]; then
    source_env /etc/profile.d/kubectl_aliases.sh
fi

if [ -t 0 ]; then
    export COLOR_RED="$(tput setaf 1)"
    export COLOR_GREEN="$(tput setaf 2)"
    export COLOR_YELLOW="$(tput setaf 3)"
    export COLOR_BOLD="$(tput bold)"
    export COLOR_RESET="$(tput sgr0)"

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
else
    export COLOR_RED=''
    export COLOR_GREEN=''
    export COLOR_YELLOW=''
    export COLOR_BOLD=''
    export COLOR_RESET=''
fi

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
  echo -e "${COLOR_RESET}$@"
}

debugn()
{
  echo -ne "${COLOR_RESET}$@"
}

info()
{
  echo -e "${COLOR_YELLOW}$@${COLOR_RESET}"
}

infon()
{
  echo -ne "${COLOR_YELLOW}$@${COLOR_RESET}"
}

warn()
{
  echo -e "${COLOR_RED}$@${COLOR_RESET}"
}

warnn()
{
  echo -ne "${COLOR_RED}$@${COLOR_RESET}"
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
    local res=${1//\// }
    res=( ${res//:/ } )
    echo ${res[-2]}
}

git_name()
{
    local res=( ${1//\// } )
    res=${res[-1]}
    echo ${res%.git}
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
