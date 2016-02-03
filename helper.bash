#!/bin/bash

# shellcheck disable=SC2155,SC2154
equals_var() {
  local left_declare=$(declare -p "$1" 2>/dev/null)
  local right_declare=$(declare -p "$2" 2>/dev/null)
  [[ -z $left_declare || -z $right_declare ]] && return 1
  # 属性を取得
  local left_attr=${left_declare#*-}; left_attr=${left_attr%% *}
  local right_attr=${right_declare#*-}; right_attr=${left_attr%% *}
  # 属性を取得
  local left_attr=${left_declare#*-}; left_attr=${left_attr%% *}
  local right_attr=${right_declare#*-}; right_attr=${left_attr%% *}
  # declare -p の出力をevalすることで配列含め変数のクローンを簡単に作れる
  eval "${left_declare/$1=/left=}"
  eval "${right_declare/$2=/right=}"
  # 非配列
  if [[ $left_attr$right_attr != *[aA]* ]]; then
    [[ $left == "$right" ]]; return $?
  fi
  # 配列or連想配列
  [[ ${#left[@]} == "${#right[@]}" ]] || return 1
  [[ $left_attr$right_attr == *a*A* ]] || return 1
  [[ $left_attr$right_attr == *A*a* ]] || return 1
  # local left_idx=("${!left[@]}")
  # local right_idx=("${!right[@]}")
  # (echo $1 $2 $3;IFS=$'\n';echo "${!equals_var__right[*]}")
  # (equals_var equals_var__left_idx equals_var__right_idx inner) || return 1
  for _ in "${!left[@]}" "${!right[@]}"; do
    [[ ${left[$_]} == "${right[$_]}" ]] || return 1
  done
}

# shellcheck disable=SC2155
var_parse() {
  is_identifier "$@" || return 1
  local t=$(declare -p "$1" 2>/dev/null)
  [[ -z $t ]] && return 1
  t=${t#* }
  eval "declare -a $2='(${t%% *} ${t#*=})'"
}

is_identifier() {
  [[ $# != 0 ]] && for _ in "$@"; do [[ $_ == [a-zA-Z_]* && $_ != *[^a-zA-Z0-9_]* ]] || return 1; done
}

var_defined() {
  declare -p -- "$@" >/dev/null 2>&1
}

func_defined() {
  declare -F -- "$@" >/dev/null 2>&1
}

func_deprecated() {
  printf '%s\n' "\`${FUNCNAME[1]}\` is deprecated.${1:+ Redirecting to \`$1\`.}" >&2
  func_redirect "${@}"
}

func_redirect() {
  [[ $# != 0 ]] && "$@"
}

caniuse_hash() {
  func_redirect caniuse_associative_array "$@"
}

caniuse_associative_array() {
  version_ge 4
}

caniuse_declare_g() {
  version_ge 4.2
}

caniuse_declare_n() {
  version_ge 4.3
}

caniuse_regexp() {
  func_redirect caniuse_regular_expressions "$@"
}
caniuse_regular_expressions() {
  # 3.1未満でも使えるが右辺のクオートに関する仕様が違うので使わない方が良い
  version_ge 3.1
}

version_ge() {
  if [[ $# == 1 ]]; then
    local v1=(${BASH_VERSINFO[*]//[^0-9]/ ]})
  else
    local v1=(${1//[^0-9]/ })
    shift
  fi
  local v2=(${1//[^0-9]/ })
  for _ in "${!v2[@]}"; do
    [[ ${v1[$_]} -ge "${v2[$_]}" ]] && continue
    return 1
  done
}

string_contains() {
  [[ $1 == *"$2"* ]]
}

starts_with() {
  [[ $1 == "$2"* ]]
}

ends_with() {
  [[ $1 == *"$2" ]]
}

simple_echo() {
  printf '%s\n' "$*"
}

simple_replace() {
  func_redirect simple_replace_all "$@"
}

simple_replace_single() {
  printf %s "${1/"$2"/$3}"
}

simple_replace_all() {
  printf %s "${1//"$2"/$3}"
}

func_hack() {
  local target_func=$1
  local marker=$2
  local cond_commands=$3
  local then_code=$4
  local else_code=$5
  if (eval "$cond_commands" >/dev/null 2>&1); then
    local inject_code=$then_code
  else
    local inject_code=$else_code
  fi
  eval "$(simple_replace_all "$(declare -f "$target_func")" "$marker" "$inject_code")"
}

quote() {
  for _ in "$@"; do
    printf %q "$_" FIX_TILDABUG
  done
}
func_hack quote FIX_TILDABUG 'version_ge 4.3' '' '| sed "s/~/\\\\~/g"'

# caniuse系の関数を固定値にする
while read -r f; do "$f"; eval "$f() { return $?; }"; done < <(declare -F | perl -pe's/^(.*? ){2}//'|grep ^caniuse_)
