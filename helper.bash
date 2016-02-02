# bash

equals_var() {
  declare -p $1 >/dev/null 2>&1 || return 1
  declare -p $2 >/dev/null 2>&1 || return 1
  if true || [[ ${BASH_VERSINFO[0]} -lt 4 ]] || [[ ${BASH_VERSINFO[0]} == 4 && ${BASH_VERSINFO[1]} -lt 3 ]]; then
    eval "$(declare -p "$1" | perl -pe's/\S+?=/equals_var__left=/')"
    eval "$(declare -p "$2" | perl -pe's/\S+?=/equals_var__right=/')"
  else
    declare -n equals_var__left=$1
    declare -n equals_var__right=$2
  fi
  # 非配列
  if [[ $(declare -p $1 $2 | grep -E '^declare -[^ ]*[aA]' | wc -l) == 0 ]]; then
    [[ $equals_var__left == $equals_var__right ]]; return $?
  fi
  # 配列or連想配列
  [[ $(declare -p $1 $2 | grep -E '^declare -[^ ]*a' | wc -l) == [02] ]] || return 1
  [[ $(declare -p $1 $2 | grep -E '^declare -[^ ]*A' | wc -l) == [02] ]] || return 1
  [[ ${#equals_var__left[@]} == ${#equals_var__right[@]} ]] || return 1
  local idx
  for idx in "${!equals_var__left[@]}"; do
    [[ ${equals_var__left[$idx]} == ${equals_var__right[$idx]} ]] || return 1
  done
  for idx in "${!equals_var__right[@]}"; do
    [[ ${equals_var__left[$idx]} == ${equals_var__right[$idx]} ]] || return 1
  done
}
