#!/bin/bash

# CONTENT
content=""

# VALIDATORS
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

# FUNCTIONS FOR SECTION 1
create_section1_name() {
	echo "# SETTINGS" 
}
create_section1_phony() {
	echo ".PHONY: " 
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