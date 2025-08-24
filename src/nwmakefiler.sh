#!/bin/bash

# SYSTEM FUNCTIONS
declare script_name="nwmakefiler"
declare script_version="1.0.0"
declare is_running_from=""

is_curl_installed() {
    command -v curl >/dev/null 2>&1
}
is_connected() {
    curl -s --head --connect-timeout 5 https://www.google.com >/dev/null
}
set_running_from() {
    # If the script is being piped via curl, $0 will be /dev/stdin
    if [[ "$0" == "/dev/stdin" ]]; then
        is_running_from="curl"
    else
        is_running_from="local"
    fi
}
create_target_from_local() {
    local target_name="$1"
    local data_dir="$(dirname "$0")/../data"
    local target_file="$data_dir/$target_name"

    if [[ -f "$target_file" ]]; then
        cat "$target_file"
    else
        echo "Target '$target_name' not found in '$data_dir'."
    fi
}
create_target_from_remote() {
    local target_name="$1"
    local base_url="https://raw.githubusercontent.com/numbworks/nwreadinglist/master/data"
    local remote_file="$base_url/$target_name"

    local content
    content=$(curl --silent --fail "$remote_file")

    if [[ $? -eq 0 ]]; then
        printf "%s\n" "$content"
    else
        echo "Target '$target_name' not found at remote URL '$remote_file'."
    fi
}
create_target() {
    local target_name="$1"

    if [[ "$is_running_from" == "local" ]]; then
        create_target_from_local "$target_name"
    else
        create_target_from_remote "$target_name"
    fi
}

# FUNCTIONS FOR SECTION 1
create_section1_name() {
	echo "# SETTINGS" 
}
create_section1_shell() {
	echo "SHELL := /bin/bash" 
}
create_section1_root_dir() {
	echo "ROOT_DIR := \$(shell cd .. && pwd)" 
}
create_section1_module_name() { 
	echo "MODULE_NAME = \"$1\""; 
}
create_section1_module_version() { 
	echo "MODULE_VERSION = \"$1\""; 
}
create_section1_coverage_threshold() {
    echo "COVERAGE_THRESHOLD = $1"
}

# FUNCTIONS FOR SECTION 2
create_section2_name() {
	echo "# TARGETS" 
}
create_section2_clear() {
    create_target "clear"
}
create_section2_makefile_info() {
    create_target "makefile-info"
}
create_section2_changelog_concise() {
    create_target "changelog-concise"
}
create_section2_codemetrics_concise() {
    create_target "codemetrics-concise"
}
create_section2_codemetrics_verbose() {
    create_target "codemetrics-verbose"
}
create_section2_compile_concise() {
    create_target "compile-concise"
}
create_section2_compile_verbose() {
    create_target "compile-verbose"
}
create_section2_coverage_concise() {
    create_target "coverage-concise"
}
create_section2_coverage_verbose() {
    create_target "coverage-verbose"
}
create_section2_docstrings_concise() {
    create_target "docstrings-concise"
}
create_section2_docstrings_verbose() {
    create_target "docstrings-verbose"
}
create_section2_setup_concise() {
    create_target "setup-concise"
}
create_section2_tryinstall_concise() {
    create_target "tryinstall-concise"
}
create_section2_tryinstall_verbose() {
    create_target "tryinstall-verbose"
}
create_section2_type_concise() {
    create_target "type-concise"
}
create_section2_type_verbose() {
    create_target "type-verbose"
}
create_section2_unittest_concise() {
    create_target "unittest-concise"
}
create_section2_unittest_verbose() {
    create_target "unittest-verbose"
}

# FUNCTIONS FOR SECTION 3
create_section3_name() {
	echo "# UTILITIES" 
}
create_section3_calculate_commitavg() {
    create_target "calculate-commitavg"
}
create_section3_create_classdiagram() {
    create_target "create-classdiagram"
}
create_section3_check_pythonversion() {
    create_target "check-pythonversion"
}
create_section3_check_requirements() {
    create_target "check-requirements"
}
create_section3_update_codecoverage() {
    create_target "update-codecoverage"
}

# FUNCTIONS FOR SECTION 4
create_section4_name() {
	echo "# AGGREGATES" 
}

# VALIDATORS
validate_module_name() {
    [[ -n "$1" ]]
}
validate_module_version() {
    if [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}
validate_coverage_threshold() {
    if ! [[ "$1" =~ ^[0-9]+$ ]]; then
        return 1
    fi

    if (( $1 < 0 || $1 > 100 )); then
        return 1
    fi

    return 0
}
validate_s1() {
    local -n arr=$1

    local required=(
        "create_section1_module_name"
        "create_section1_module_version"
        "create_section1_coverage_threshold"
    )

    for item in "${required[@]}"; do
        local found=false
        for func in "${arr[@]}"; do
            if [[ "$func" == "$item"* ]]; then
                found=true
                break
            fi
        done
        if [[ "$found" == false ]]; then
            return 1
        fi
    done

    return 0
}

# FUNCTION NAMES
declare -a function_names_s1=()
declare -a function_names_s2=()
declare -a function_names_s3=()

add_to_function_names_s1() {
    function_names_s1+=("$1")
}
add_to_function_names_s2() {
    function_names_s2+=("$1")
}
add_to_function_names_s3() {
    function_names_s3+=("$1")
}
eval_function_names() {
    local array_name="$1"
    local -n fn_array="$array_name"

    local content=""
    for function_name in "${fn_array[@]}"; do
        output=$($function_name)
        content+="$output"$'\n'
    done

    echo "$content"
}
contains_at_least_one_concise() {
    local array_name="$1"
    local -n array_ref="$array_name"

    for item in "${array_ref[@]}"; do
        if [[ "$item" == *concise ]]; then
            return 0
        fi
    done
    return 1
}

# MENU
declare -A options_s1=(
    ["1mn"]="MODULE_NAME"
    ["1mv"]="MODULE_VERSION"
    ["1ct"]="COVERAGE_THRESHOLD"
)
declare -A options_s2=(
    ["2cha"]="changelog-concise"
    ["2cod"]="codemetrics-concise/verbose"
    ["2com"]="compile-concise/verbose"
	["2cov"]="coverage-concise/verbose"
	["2doc"]="docstrings-concise/verbose"
	["2set"]="setup-concise"
	["2try"]="tryinstall-concise/verbose"
	["2typ"]="type-concise/verbose"
	["2uni"]="unittest-concise/verbose"
    ["2all"]="all the above"
)
declare -A options_s3=(
    ["3cal"]="calculate-commitavg"
    ["3cls"]="create-classdiagram"
    ["3pyv"]="check-pythonversion"
	["3req"]="check-requirements"
	["3upd"]="update-codecoverage"
    ["3all"]="all the above"
)
declare -a log_messages=()

add_to_log_messages() {
    log_messages+=("$1")
}
create_target_list() {
    local prefix="$1"       # ".PHONY" or "all-concise"
    local array_name="$2"
    local -n input_array="$array_name"
    local targets=()

    for fn in "${input_array[@]}"; do
        # Skip if ends in "verbose"
        if [[ "$fn" == *verbose ]]; then
            continue
        fi

        # Strip "create_section2_" or "create_section3_"
        local target="${fn#create_section2_}"
        target="${target#create_section3_}"

        # Replace underscores with hyphens
        target="${target//_/-}"

        targets+=("$target")
    done

    # If prefix is .PHONY, add "all-concise" to the end
    if [[ "$prefix" == ".PHONY" ]]; then
        targets+=("all-concise")
    fi

    # Join the target names into a single string
    local target_line="$prefix: ${targets[*]}"
    echo "$target_line"
}
get_current_folder_path() {
    echo "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
}
show_array() {
    local array_name="$1"
    local -n arr="$array_name"

    for item in "${arr[@]}"; do
        echo "$item"
    done
}
show_menu_header() {
    local width=40
    local title="${script_name} v${script_version}"
    local padding=$(( (width - ${#title}) / 2 ))
    local line=$(printf '=%.0s' $(seq 1 $width))

    echo "$line"
    printf "%*s%s%*s\n" "$padding" "" "$title" "$((width - padding - ${#title}))" ""
    echo "$line"
    echo
}
show_menu_options_s1() {
    echo "SECTION1 (SETTINGS)"
    echo

    options_s1_keys=("1mn" "1mv" "1ct")
    
    for key in "${options_s1_keys[@]}"; do
        if [[ -v options_s1[$key] ]]; then
            echo "  - [$key] ${options_s1[$key]}"
        fi
    done

    echo
}
show_menu_options_s2() {
    echo "SECTION2 (TARGETS)"
    echo

    options_s2_keys=("2cha" "2cod" "2com" "2cov" "2doc" "2set" "2try" "2typ" "2uni" "2all")
    
    for key in "${options_s2_keys[@]}"; do
        if [[ -v options_s2[$key] ]]; then
            echo "  - [$key] ${options_s2[$key]}"
        fi
    done

    echo
}
show_menu_options_s3() {
    echo "SECTION3 (UTILITIES)"
    echo

    options_s3_keys=("3cal" "3cls" "3pyv" "3req" "3upd" "3all")
    
    for key in "${options_s3_keys[@]}"; do
        if [[ -v options_s3[$key] ]]; then
            echo "  - [$key] ${options_s3[$key]}"
        fi
    done

    echo
}
show_menu_log_messages() {
    local count=${#log_messages[@]}
    local start=$(( count > 5 ? count - 5 : 0 ))

    echo "LAST FIVE LOG MESSAGES"
    echo
    for ((i = start; i < count; i++)); do
        echo "  $((i + 1)). ${log_messages[i]}"
    done
    echo
}
show_menu_commands() {
    echo "COMMANDS"
    echo
    echo "  - [save] Save"
    echo "  - [exit] Exit"
    echo
}
show_menu_footer() {
    local width=40
    local line
    line=$(printf '=%.0s' $(seq 1 $width))

    echo "$line"
    echo
    echo
}
show_menu() {
    show_menu_header
    show_menu_options_s1
    show_menu_options_s2
    show_menu_options_s3
    show_menu_commands
    show_menu_log_messages   
    show_menu_footer
}
handle_1mn() {
    read -p "ENTER MODULE_NAME: " module_name
    
    if validate_module_name "$module_name"; then
        add_to_function_names_s1 "create_section1_module_name $module_name"
        unset options_s1["1mn"]
        add_to_log_messages "${FUNCNAME[0]}: success! MODULE_NAME: '$module_name'."
    else
        add_to_log_messages "${FUNCNAME[0]}: failure! MODULE_NAME ('$module_name') can't be empty."
    fi
}
handle_1mv() {
    read -p "ENTER MODULE_VERSION: " module_version

    if validate_module_version "$module_version"; then
        add_to_function_names_s1 "create_section1_module_version $module_version"
        unset options_s1["1mv"]
        add_to_log_messages "${FUNCNAME[0]}: success! MODULE_VERSION: '$module_version'."
    else
        add_to_log_messages "${FUNCNAME[0]}: failure! MODULE_VERSION ('$module_version') must adopt the MAJOR.MINOR.PATCH format (e.g., 1.0.0)."
    fi
}
handle_1ct() {
    read -p "ENTER COVERAGE_THRESHOLD: " coverage_threshold

    if validate_coverage_threshold "$coverage_threshold"; then           
        add_to_function_names_s1 "create_section1_coverage_threshold $coverage_threshold"
        unset options_s1["1ct"]
        add_to_log_messages "${FUNCNAME[0]}: success! COVERAGE_THRESHOLD: $coverage_threshold."
    else
        add_to_log_messages "${FUNCNAME[0]}: failure! COVERAGE_THRESHOLD ($coverage_threshold) must be an integer in the [0-100] range."
    fi
}
handle_2cha() {
    add_to_function_names_s2 "create_section2_changelog_concise"
    unset options_s2["2cha"]
    add_to_log_messages "${FUNCNAME[0]}: success!"
}
handle_2cod() {
    add_to_function_names_s2 "create_section2_codemetrics_concise"
    add_to_function_names_s2 "create_section2_codemetrics_verbose"
    unset options_s2["2cod"]
    add_to_log_messages "${FUNCNAME[0]}: success!"
}
handle_2com() {
    add_to_function_names_s2 "create_section2_compile_concise"
    add_to_function_names_s2 "create_section2_compile_verbose"
    unset options_s2["2com"]
    add_to_log_messages "${FUNCNAME[0]}: success!"
}
handle_2cov() {
    add_to_function_names_s2 "create_section2_coverage_concise"
    add_to_function_names_s2 "create_section2_coverage_verbose"
    unset options_s2["2cov"]
    add_to_log_messages "${FUNCNAME[0]}: success!"
}
handle_2doc() {
    add_to_function_names_s2 "create_section2_docstrings_concise"
    add_to_function_names_s2 "create_section2_docstrings_verbose"
    unset options_s2["2doc"]
    add_to_log_messages "${FUNCNAME[0]}: success!"
}
handle_2set() {
    add_to_function_names_s2 "create_section2_setup_concise"
    unset options_s2["2set"]
    add_to_log_messages "${FUNCNAME[0]}: success!"
}
handle_2try() {
    add_to_function_names_s2 "create_section2_tryinstall_concise"
    add_to_function_names_s2 "create_section2_tryinstall_verbose"
    unset options_s2["2try"]
    add_to_log_messages "${FUNCNAME[0]}: success!"
}
handle_2typ() {
    add_to_function_names_s2 "create_section2_type_concise"
    add_to_function_names_s2 "create_section2_type_verbose"
    unset options_s2["2typ"]
    add_to_log_messages "${FUNCNAME[0]}: success!"
}
handle_2uni() {
    add_to_function_names_s2 "create_section2_unittest_concise"
    add_to_function_names_s2 "create_section2_unittest_verbose"
    unset options_s2["2uni"]
    add_to_log_messages "${FUNCNAME[0]}: success!"
}
handle_2all() {
    handle_2cha
    handle_2cod
    handle_2com
    handle_2cov
    handle_2doc
    handle_2set
    handle_2try
    handle_2typ
    handle_2uni
    unset options_s2["2all"]
    add_to_log_messages "${FUNCNAME[0]}: success!"
}
handle_3cal() {
    add_to_function_names_s3 "create_section3_calculate_commitavg"
    unset options_s3["3cal"]
    add_to_log_messages "${FUNCNAME[0]}: success!"
}
handle_3cls() {
    add_to_function_names_s3 "create_section3_create_classdiagram"
    unset options_s3["3cls"]
    add_to_log_messages "${FUNCNAME[0]}: success!"
}
handle_3pyv() {
    add_to_function_names_s3 "create_section3_check_pythonversion"
    unset options_s3["3pyv"]
    add_to_log_messages "${FUNCNAME[0]}: success!"
}
handle_3req() {
    add_to_function_names_s3 "create_section3_check_requirements"
    unset options_s3["3req"]
    add_to_log_messages "${FUNCNAME[0]}: success!"
}
handle_3upd() {
    add_to_function_names_s3 "create_section3_update_codecoverage"
    unset options_s3["3upd"]
    add_to_log_messages "${FUNCNAME[0]}: success!"
}
handle_3all() {
    handle_3cal
    handle_3cls
    handle_3pyv
    handle_3req
    handle_3upd
    unset options_s3["3all"]
    add_to_log_messages "${FUNCNAME[0]}: success!"
}
handle_save_for_s1() {
    local -n content_ref="$1"

    content_ref+=$(create_section1_name)
    content_ref+=$'\n'

    if contains_at_least_one_concise function_names_s2; then
	
        content_ref+=$(create_target_list ".PHONY" function_names_s2)
        content_ref+=$'\n'
		
    fi

    content_ref+=$(create_section1_shell)
    content_ref+=$'\n'
    content_ref+=$(create_section1_root_dir)
    content_ref+=$'\n'
    content_ref+=$(eval_function_names function_names_s1)
    content_ref+=$'\n\n'
}
handle_save_for_s2() {
    local -n content_ref="$1"

    content_ref+=$(create_section2_name)
    content_ref+=$'\n'

    if [[ ${#function_names_s2[@]} -gt 0 ]]; then
	
        content_ref+=$(create_section2_clear)
        content_ref+=$'\n'
        content_ref+=$(create_section2_makefile_info)
        content_ref+=$'\n'
        content_ref+=$(eval_function_names function_names_s2)
        content_ref+=$'\n\n'
		
    fi
}
handle_save_for_s3() {
    local -n content_ref="$1"

    content_ref+=$(create_section3_name)
    content_ref+=$'\n'

    if [[ ${#function_names_s3[@]} -gt 0 ]]; then
	
        content_ref+=$(eval_function_names function_names_s3)
        content_ref+=$'\n\n'
		
    fi
}
handle_save_for_s4() {
    local -n content_ref="$1"

    content_ref+=$(create_section4_name)
    content_ref+=$'\n'

    if contains_at_least_one_concise function_names_s2; then
	
        content_ref+=$(create_target_list "all-concise" function_names_s2)
		
    fi
}
handle_save() {

    if ! validate_s1 function_names_s1; then

        add_to_log_messages "${FUNCNAME[0]}: failure! In order to save(), all 'Section 1' information must be provided."
        return 1
    
    fi

    local content=""

    handle_save_for_s1 content
    handle_save_for_s2 content
    handle_save_for_s3 content
    handle_save_for_s4 content

    script_dir="$(get_current_folder_path)"
    echo "$content" > "$script_dir/makefile"

    exit 0
}
handle_wrong_input() {
    add_to_log_messages "${FUNCNAME[0]}: failure! Invalid input or no corresponding action available ('$1')."
}
handle_input() {

    case "$1" in
        
        1mn) handle_1mn ;;
        1mv) handle_1mv ;;
        1ct) handle_1ct ;;

        2cha) handle_2cha ;;
        2cod) handle_2cod ;;
        2com) handle_2com ;;
        2cov) handle_2cov ;;
        2doc) handle_2doc ;;
        2set) handle_2set ;;
        2try) handle_2try ;;
        2typ) handle_2typ ;;
        2uni) handle_2uni ;;
        2all) handle_2all ;;

        3cal) handle_3cal ;;
        3cls) handle_3cls ;;
        3pyv) handle_3pyv ;;
        3req) handle_3req ;;
        3upd) handle_3upd ;;
        3all) handle_3all ;;

        save) handle_save ;;
        exit) exit 0;;

        *) handle_wrong_input $1 ;;
    esac
}

# MAIN
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    if ! is_curl_installed; then
        echo "ERROR: 'curl' is not installed. Please install 'curl' first."
        exit 1
    fi

    if ! is_connected; then
        echo "ERROR: no internet connection. Please connect to internet first."
        exit 1
    fi

    set_running_from
    add_to_log_messages "Script is running from: $is_running_from".

    while true; do
        clear
        show_menu
        read -p "ENTER OPTION: " user_input
        handle_input "$user_input"
        echo
    done
fi