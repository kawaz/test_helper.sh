#!/usr/bin/env bats
load ../helper

v=1

@test "no declared variable" {
  ! equals_var no_declared1 no_declared2
  ! equals_var no_declared1 v
  ! equals_var v no_declared2
  ! equals_var "" ""
  ! equals_var v ""
  ! equals_var "" v
}

@test "no argument" {
  ! equals_var
  ! equals_var v
  ! equals_var "" v
}

@test "same var" {
  local s1= s2="foo"
  equals_var s1 s1
  equals_var s2 s2
  local a1=() a2=(a b c)
  equals_var a1 a1
  equals_var a2 a2
  if [[ 4 -le $BASH_VERSINFO ]]; then
    declare -A A1 A2
    A1=() A2=([kawaii]=justice [love]=power)
    equals_var A1 A1
    equals_var A2 A2
  fi
}

@test "differ type" {
  s1= s2=one s3="one two" a1=() a2=(one) a3=(one two)
  declare -A A1=() A2=([one]=one) A3=([one]=one [two]=two)
  ! equals_var s1 a1
  ! equals_var a1 s1
  ! equals_var s1 A1
  ! equals_var A1 s1
  ! equals_var a1 A1
  ! equals_var A1 a1
  ! equals_var s2 a2
  ! equals_var a2 s2
  ! equals_var s2 A2
  ! equals_var A2 s2
  ! equals_var a2 A2
  ! equals_var A2 a2
  ! equals_var s3 a3
  ! equals_var a3 s3
  ! equals_var s3 A3
  ! equals_var A3 s3
  ! equals_var a3 A3
  ! equals_var A3 a3
}

@test "string var" {
  local s1= s2= s3=foo s4=foo s5=bar s6="bar " s7=" bar"
  equals_var s1 s2
  equals_var s2 s1
  equals_var s3 s4
  equals_var s4 s3
  ! equals_var s1 s3
  ! equals_var s3 s1
  ! equals_var s3 s5
  ! equals_var s5 s3
  ! equals_var s5 s6
  ! equals_var s6 s5
  ! equals_var s5 s7
  ! equals_var s7 s5
}

@test "array var" {
  local a11=() a12=()
  local a21=(a b) a22=(a b)
  local a31=(a b c) a32=(a b c)
  local a41=(foo bar) a42=(foo bar)
  equals_var a11 a12
  equals_var a12 a11
  equals_var a21 a22
  equals_var a22 a21
  equals_var a31 a32
  equals_var a32 a31
  equals_var a41 a42
  equals_var a42 a41
  ! equals_var a11 a21
  ! equals_var a21 a11
  ! equals_var a21 a31
  ! equals_var a31 a21
  ! equals_var a21 a41
  ! equals_var a41 a21
}

@test "array var (skiped index)" {
  local a11=([5]=five [10]=ten)
  local a12=([5]=five [10]=ten)
  local a2=(file ten)
  local a3=(1 2 3 4 file 6 7 8 9 ten)
  local a4=("" "" "" "" file "" "" "" "" ten)
  local a5=([5]=five [10]=ten [2]=two)
  local a6=([5]=five [10]=ten [2]="")
  equals_var a11 a12
  equals_var a12 a11
  ! equals_var a11 a2
  ! equals_var a2 a11
  ! equals_var a11 a3
  ! equals_var a3 a11
  ! equals_var a11 a4
  ! equals_var a4 a11
  ! equals_var a11 a5
  ! equals_var a5 a11
  ! equals_var a6 a11
  ! equals_var a11 a6
  ! equals_var a5 a6
  ! equals_var a6 a5
}

@test "hash var" {
  declare -A A11=()
  declare -A A12=()
  declare -A A21=([one]=1 [two]=2)
  declare -A A22=([one]=1 [two]=2)
  declare -A A31=([one]=1 [two]=2 [three]="san")
  declare -A A32=([one]=1 [two]=2 [three]="san")
  equals_var A11 A12
  equals_var A12 A11
  equals_var A21 A22
  equals_var A22 A21
  equals_var A31 A32
  equals_var A32 A31
  ! equals_var A11 A21
  ! equals_var A21 A11
  ! equals_var A11 A31
  ! equals_var A31 A11
  ! equals_var A21 A31
  ! equals_var A31 A21
}
