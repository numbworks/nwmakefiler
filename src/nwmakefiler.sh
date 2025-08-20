#!/bin/bash

# CONTENT
content=""

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
    cat <<EOF
clear:
	@clear
EOF
}
create_section2_makefile_info() {
    cat <<EOF
makefile-info:
	@echo "MODULE_NAME: \$(MODULE_NAME)"; \\
	echo "MODULE_VERSION: \$(MODULE_VERSION)"; \\
	echo "COVERAGE_THRESHOLD: \$(COVERAGE_THRESHOLD)%"
EOF
}
create_section2_changelog_concise() {
    cat <<EOF
changelog-concise:
	@value=\$$(cat \$(ROOT_DIR)/CHANGELOG | grep -c -e "v\$(MODULE_VERSION)\$\$" -e "v\$(MODULE_VERSION) - BREAKING CHANGES\$\$"); \\
	if [ \$\$value -eq 1 ]; then echo "[OK] \$@: 'CHANGELOG' updated to current version!"; else echo "[WARNING] \$@: 'CHANGELOG' not updated to current version!"; fi;
EOF
}
create_section2_codemetrics_concise() {
    cat <<EOF
codemetrics-concise:
	@value=\$$(radon cc -a -s \$(ROOT_DIR)/src/\$(MODULE_NAME)*.py  | grep -oP "Average complexity: \\K[A-F]"); \\
	if [[ "\$\$value" == *"A"* ]]; then echo "[OK] \$@: the cyclomatic complexity is excellent ('\$\$value')."; else echo "[WARNING] \$@: the cyclomatic complexity is not excellent ('\$\$value')"; fi;
EOF
}
create_section2_codemetrics_verbose() {
    cat <<EOF
codemetrics-verbose:
	@clear; \\
	radon cc -a -s \$(ROOT_DIR)/src/\$(MODULE_NAME)*.py | grep -e '^[ ]*[CFM].*' | grep -v ' - A';
EOF
}
create_section2_compile_concise() {
    cat <<EOF
compile-concise:
	@value=\$$(python -m py_compile \$(ROOT_DIR)/src/\$(MODULE_NAME).py 2>&1); \\
	if [ -z "\$\${value}" ]; then value=0; else value=1; fi; \\
	if [ \$\$value -eq 0 ]; then echo "[OK] \$@: compiling the library throws no issues."; else echo "[WARNING] \$@: compiling the library throws some issues."; fi;
EOF
}
create_section2_compile_verbose() {
    cat <<EOF
compile-verbose:
	@clear; \\
	python -m py_compile \$(ROOT_DIR)/src/\$(MODULE_NAME).py;
EOF
}
create_section2_coverage_concise() {
    cat <<EOF
coverage-concise:
	@cd \$(ROOT_DIR)/tests/; \\
	coverage run -m unittest \$(MODULE_NAME)tests.py > /dev/null 2>&1; \\
	value=\$$(coverage report --include=\$(MODULE_NAME).py | grep -oP 'TOTAL\\s+\\d+\\s+\\d+\\s+\\K\\d+(?=%)'); \\
	if [ \$\$value -ge \$(COVERAGE_THRESHOLD) ]; then echo "[OK] \$@: unit test coverage >= \$(COVERAGE_THRESHOLD)%."; else echo "[WARNING] \$@: unit test coverage < \$(COVERAGE_THRESHOLD)%."; fi;
EOF
}
create_section2_coverage_verbose() {
    cat <<EOF
coverage-verbose:
	@clear; \\
	cd \$(ROOT_DIR)/tests/; \\
	coverage run -m unittest \$(MODULE_NAME)tests.py > /dev/null 2>&1; \\
	rm -rf htmlcov; \\
	coverage html --include=\$(MODULE_NAME).py && sed -n '/<table class="index" data-sortable>/,/<\\/table>/p' htmlcov/class_index.html | pandoc --from html --to plain; \\
	sleep 3; \\
	rm -rf htmlcov;
EOF
}
create_section2_docstrings_concise() {
    cat <<EOF
docstrings-concise:
	@file_path=\$(ROOT_DIR)/src/\$(MODULE_NAME).py; \\
	value=\$$(python -m nwdocstringchecking -fp \$\$file_path -e MessageCollection -e init -e str -e repr); \\
	if [[ "\$\$value" == *"All methods have docstrings."* ]]; then echo "[OK] \$@: all methods have docstrings."; else echo "[WARNING] \$@: not all methods have docstrings."; fi;
EOF
}
create_section2_docstrings_verbose() {
    cat <<EOF
docstrings-verbose:
	@clear; \\
	file_path=\$(ROOT_DIR)/src/\$(MODULE_NAME).py; \\
	python -m nwdocstringchecking -fp \$\$file_path -e MessageCollection -e init -e str -e repr;
EOF
}
create_section2_setup_concise() {
    cat <<EOF
setup-concise:
	@value=\$$(cat \$(ROOT_DIR)/src/setup.py | grep -oP 'MODULE_VERSION\\s*:\\s*str\\s*=\\s*"\K[\\d.]+'); \\
	if [ \$\$value == "\$(MODULE_VERSION)" ]; then echo "[OK] \$@: 'setup.py' updated to current version!"; else echo "[WARNING] \$@: 'setup.py' not updated to current version!"; fi;
EOF
}
create_section2_tryinstall_concise() {
    cat <<EOF
tryinstall-concise:
	@value=\$$(make tryinstall-verbose 2>&1); \\
	last_chars=\$$(echo "\$\$value" | tail -c 100); \\
	if [[ "\$\$last_chars" == *"Version: \$(MODULE_VERSION)"* ]]; then echo "[OK] \$@: installation process works."; else echo "[WARNING] \$@: installation process fails!"; fi;
EOF
}
create_section2_tryinstall_verbose() {
    cat <<EOF
tryinstall-verbose:
	@clear; \\
	cd /home; \\
	rm -rf build; \\
	rm -rf dist; \\
	rm -rf \$(MODULE_NAME).egg-info; \\
	rm -rf venv; \\
	python /workspaces/\$(MODULE_NAME)/src/setup.py bdist_wheel; \\
	python -m venv venv; \\
	source venv/bin/activate; \\
	pip install dist/\$(MODULE_NAME)*.whl; \\
	pip show \$(MODULE_NAME) | grep Version; \\
	deactivate; \\
	rm -rf build; \\
	rm -rf dist; \\
	rm -rf \$(MODULE_NAME).egg-info; \\
	rm -rf venv;
EOF
}
create_section2_type_concise() {
    cat <<EOF
type-concise:
	@value=\$$(mypy \$(ROOT_DIR)/src/\$(MODULE_NAME).py --disable-error-code=import-untyped | grep -c "error:"); \\
	value+=\$$(mypy \$(ROOT_DIR)/tests/\$(MODULE_NAME)tests.py --disable-error-code=import-untyped  --disable-error-code=import-not-found | grep -c "error:"); \\
	if [ \$\$value -eq 0 ]; then echo "[OK] \$@: passed!"; else echo "[WARNING] \$@: not passed! '\$\$value' error(s) found!"; fi;
EOF
}
create_section2_type_verbose() {
    cat <<EOF
type-verbose:
	@clear; \\
	mypy \$(ROOT_DIR)/src/\$(MODULE_NAME).py --check-untyped-defs --disable-error-code=import-untyped; \\
	mypy \$(ROOT_DIR)/tests/\$(MODULE_NAME)tests.py --check-untyped-defs --disable-error-code=import-untyped --disable-error-code=import-not-found;
EOF
}
create_section2_unittest_concise() {
    cat <<EOF
unittest-concise:
	@value=\$$(python \$(ROOT_DIR)/tests/\$(MODULE_NAME)tests.py 2>&1 | grep -oP '(?<=Ran )\\d+(?= tests)'); \\
	if [ -z "\$\${value}" ]; then value=0; fi; \\
	if [ \$\$value -gt 0 ]; then echo "[OK] \$@: '\$\$value' tests found and run."; else echo "[WARNING] \$@: '\$\$value' tests found and run."; fi;
EOF
}
create_section2_unittest_verbose() {
    cat <<EOF
unittest-verbose:
	@clear; \\
	python \$(ROOT_DIR)/tests/\$(MODULE_NAME)tests.py;
EOF
}

# FUNCTIONS FOR SECTION 3
create_section3_name() {
	echo "# UTILITIES" 
}
create_section3_calculate_commitavg() {
    cat <<EOF
calculate-commitavg:
	@clear; \\
	python -m nwcommitaverages;
EOF
}
create_section3_create_classdiagram() {
    cat <<EOF
create-classdiagram:
	@clear; \\
	pyreverse \$(ROOT_DIR)/src/\$(MODULE_NAME).py -o mmd -d /home/\$(MODULE_NAME)/; \\
	md_file="/home/\$(MODULE_NAME)/classes.mmd"; \\
	tmp_file="/home/\$(MODULE_NAME)/temp.mmd"; \\
	final_file="/home/\$(MODULE_NAME)/Diagram-Architecture.md"; \\
	awk '/classDiagram|--\\*/ { print }' \$\$md_file > \$\$tmp_file; \\
	echo '```mermaid' > \$\$md_file; \\
	cat \$\$tmp_file >> \$\$md_file; \\
	echo '```' >> \$\$md_file; \\
	rm \$\$tmp_file; \\
	mv \$\$md_file \$\$final_file
EOF
}
create_section3_check_pythonversion() {
    cat <<EOF
check-pythonversion:
	@clear; \\
	code="from nwpackageversions import LanguageChecker; print(LanguageChecker().get_version_status(required=(3, 12, 5)))"; \\
	python -c "\$\$code"
EOF
}
create_section3_check_requirements() {
    cat <<EOF
check-requirements:
	@clear; \\
	file_path="\$(ROOT_DIR)/.devcontainer/Dockerfile"; \\
	code="from nwpackageversions import RequirementChecker; print(RequirementChecker().try_check(file_path = '\$\$file_path', only_stable_releases = True, sort_requirement_details = True))"; \\
	python -c "\$\$code";
EOF
}
create_section3_update_codecoverage() {
    cat <<EOF
update-codecoverage:
	@clear; \\
	cd \$(ROOT_DIR)/tests/; \\
	coverage run -m unittest \$(MODULE_NAME)tests.py > /dev/null 2>&1; \\
	value=\$$(coverage report --include=\$(MODULE_NAME).py | grep -oP 'TOTAL\\s+\\d+\\s+\\d+\\s+\\K\\d+(?=%)'); \\
	if [ \$\$value -le 39 ]; then color="red"; elif [ \$\$value -le 69 ]; then color="orange"; else color="green"; fi; \\
	url="https://img.shields.io/badge/coverage-\$\${value}.0%25-\$\${color}"; \\
	echo "\$\$url" > \$(ROOT_DIR)/codecoverage.txt; \\
	curl -s \$\$url -o \$(ROOT_DIR)/codecoverage.svg; \\
	if [ \$\$? -eq 0 ]; then echo "[OK] \$@: coverage badge updated successfully!"; else echo "[ERROR] \$@: failed to update coverage badge."; fi;
EOF
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
            if [[ "$func" == "$item" ]]; then
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
add_to_function_names_all() {
    function_names_all+=("$1")
}
add_array_to_function_names_all() {
    local array_name="$1"
    local -n arr_ref="$array_name"
    function_names_all+=( "${arr_ref[@]}" )
}
show_function_names_all() {
    for function_name in "${function_names_all[@]}"; do
        echo "$function_name"
    done
}
eval_function_names_all() {
    for function_name in "${function_names_all[@]}"; do
        output=$(eval "$function_name")
        content+="$output"$'\n'
    done
}
reset_function_names_all() {
    function_names_all=()
}
reset_content() {
    content=""
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
)
declare -A options_s3=(
    ["3cal"]="calculate-commitavg"
    ["3cls"]="create-classdiagram"
    ["3pyv"]="check-pythonversion"
	["3req"]="check-requirements"
	["3upd"]="update-codecoverage"
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
show_menu_header() {
    echo "============================="
    echo "         NWMAKEFILER         "
    echo "============================="
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
    for key in $(printf "%s\n" "${!options_s2[@]}" | sort); do
        echo "  - [$key] ${options_s2[$key]}"
    done
    echo
}
show_menu_options_s3() {
    echo "SECTION3 (UTILITIES)"
    echo
    for key in $(printf "%s\n" "${!options_s3[@]}" | sort); do
        echo "  - [$key] ${options_s3[$key]}"
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
    echo "============================="
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
        add_to_function_names_s1 "create_section1_module_name \"$module_name\""
        unset options_s1["1mn"]
        add_to_log_messages "${FUNCNAME[0]}: success! MODULE_NAME: '$module_name'."
    else
        add_to_log_messages "${FUNCNAME[0]}: failure! MODULE_NAME ('$module_name') can't be empty."
    fi
}
handle_1mv() {
    read -p "ENTER MODULE_VERSION: " module_version

    if validate_module_version "$module_version"; then
        add_to_function_names_s1 "create_section1_module_version \"$module_version\""
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
handle_save() {

    if validate_s1 function_names_s1; then

        content+=$(create_section1_name)
        content+=$(create_target_list ".PHONY" function_names_s2)
        content+=$(create_section1_shell)
        content+=$(create_section1_root_dir)
        content+=$(create_section1_module_name)
        content+=$(create_section1_module_version)
        content+=$(create_section1_coverage_threshold)
        content+=$'\n\n'

        content+=$(create_section2_name)
        eval_function_names_all function_names_s2
        content+=$'\n\n'

        content+=$(create_section3_name)
        eval_function_names_all function_names_s3
        content+=$'\n\n'

        content+=$(create_section4_name)
        content+=$(create_target_list "all-concise" function_names_s2)
        content+=$'\n'

        script_dir="$(get_current_folder_path)"
        echo "$content" > "$script_dir/makefile"

        exit 0

    else

        add_to_log_messages "${FUNCNAME[0]}: failure! In order to save(), all 'Section 1' information must be provided."

    fi

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

        3cal) handle_3cal ;;
        3cls) handle_3cls ;;
        3pyv) handle_3pyv ;;
        3req) handle_3req ;;
        3upd) handle_3upd ;;

        save) handle_save ;;
        exit) exit 0;;

        *) handle_wrong_input $1 ;;
    esac
}

# MAIN
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    while true; do
        clear
        show_menu
        read -p "ENTER OPTION: " user_input
        handle_input "$user_input"
        echo
    done