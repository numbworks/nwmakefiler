#!/bin/bash

content=""
declare -a function_names_s1=()
declare -a function_names_s2=()
declare -a function_names_s3=()
declare -a function_names_all=()

add_to_function_names_s1() {
    function_names_s1+=("$1")
}
add_to_function_names_s2() {
    function_names_s2+=("$1")
}
add_to_function_names_s3() {
    function_names_s3+=("$1")
}
create_function_names_all() {
    function_names_all+=("${function_names_s1[@]}")
    function_names_all+=("${function_names_s2[@]}")
    function_names_all+=("${function_names_s3[@]}")
}
show_function_names_all() {
    for function_name in "${function_names_all[@]}"; do
        echo "$function_name"
    done
}
eval_function_names_all() {
    for function_name in "${function_names_all[@]}"; do
        output="$($function_name)"
        content+="$output"$'\n'
    done
}
reset_function_names_all() {
    function_names_all=()
}
reset_content() {
    content=""
}