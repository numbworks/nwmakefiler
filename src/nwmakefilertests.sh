#!/bin/bash

# HELPERS
assert_success() {
    if "$@"; then
        echo "Passed: $*"
    else
        echo "Failed: $*"
    fi
}
assert_failure() {
    if "$@"; then
        echo "Failed: $*"
    else
        echo "Passed: $*"
    fi
}
assert_in_list() {
    local expected="$1"
    shift
    local list=("$@")

    for item in "${list[@]}"; do
        if [[ "$item" == "$expected" ]]; then
            echo "Passed"
            return
        fi
    done

    echo "Failed"
}
assert_list_count() {
    local expected_count="$1"
    shift
    local list=("$@")
    local actual_count="${#list[@]}"

    if [[ "$actual_count" -eq "$expected_count" ]]; then
        echo "Passed"
    else
        echo "Failed (expected: $expected_count, actual: $actual_count)."
    fi
}
assert_strings_equal() {
    local expected="$1"
    local actual="$2"

    if [[ "$actual" == "$expected" ]]; then
        echo "Passed"
    else
        echo "Failed (expected: $expected, actual: $actual)."
    fi
}

# TESTS
test_validatemoduleversion_shouldreturnexpectedexitcode_whenvalidgument() {
    echo "${FUNCNAME[0]}"

    assert_success validate_module_version "1.0.0"
    assert_success validate_module_version "0.1.2"
}
test_validatemoduleversion_shouldreturnexpectedexitcode_wheninvalidgument() {
    echo "${FUNCNAME[0]}"
    
    assert_failure validate_module_version "1.0"
    assert_failure validate_module_version "1"
    assert_failure validate_module_version "1.0.0.0"
    assert_failure validate_module_version "abc.def.ghi"
    assert_failure validate_module_version ""
}
test_validatecoveragethreshold_shouldreturnexpectedexitcode_whenvalidgument() {
    echo "${FUNCNAME[0]}"

    assert_success validate_coverage_threshold 0
    assert_success validate_coverage_threshold 100
    assert_success validate_coverage_threshold 75
}
test_validatecoveragethreshold_shouldreturnexpectedexitcode_wheninvalidgument() {
    echo "${FUNCNAME[0]}"

    assert_failure validate_coverage_threshold -1
    assert_failure validate_coverage_threshold 101
    assert_failure validate_coverage_threshold "abc"
    assert_failure validate_coverage_threshold ""
}

test_validates1_shouldreturnexpectedexitcode_whenvalidfunctionlist() {
    echo "${FUNCNAME[0]}"

    # Arrange
    local valid_functions=(
        "create_section1_name"
        "create_section1_shell"
        "create_section1_root_dir"
        "create_section1_module_name"
        "create_section1_module_version"
        "create_section1_coverage_threshold"
    )

    # Act, Assert
    assert_success validate_s1 valid_functions
}
test_validates1_shouldreturnexpectedexitcode_wheninvalidfunctionlist() {
    echo "${FUNCNAME[0]}"

    # Arrange
    local invalid_functions=(
        "create_section1_name"
        "create_section1_shell"
        "create_section1_root_dir"        
        "create_section1_module_name"
        "create_section1_module_version"
    )

    # Act, Assert
    assert_failure validate_s1 invalid_functions
}
test_validates1_shouldreturnexpectedexitcode_whenemptyfunctionlist() {
    echo "${FUNCNAME[0]}"

    # Arrange
    local empty_functions=()

    # Act, Assert
    assert_failure validate_s1 empty_functions
}

test_addtofunctionnamess1_shouldcontainexpecteditem_wheninvoked() {
    echo "${FUNCNAME[0]}"

    # Arrange
    function_names_s1=()
    function_name="some_function_name"

    # Act
    add_to_function_names_s1 $function_name

    # Assert
    assert_in_list $function_name "${function_names_s1[@]}"
    assert_list_count 1 "${function_names_s1[@]}"
}
test_addtofunctionnamess2_shouldcontainexpecteditem_wheninvoked() {
    echo "${FUNCNAME[0]}"

    # Arrange
    function_names_s2=()
    function_name="some_function_name"

    # Act
    add_to_function_names_s2 $function_name

    # Assert
    assert_in_list $function_name "${function_names_s2[@]}"
    assert_list_count 1 "${function_names_s2[@]}"
}
test_addtofunctionnamess3_shouldcontainexpecteditem_wheninvoked() {
    echo "${FUNCNAME[0]}"

    # Arrange
    function_names_s3=()
    function_name="some_function_name"

    # Act
    add_to_function_names_s3 $function_name

    # Assert
    assert_in_list $function_name "${function_names_s3[@]}"
    assert_list_count 1 "${function_names_s3[@]}"
}
test_resetfunctionnamesall_shouldremoveallitems_wheninvoked() {
    echo "${FUNCNAME[0]}"

    # Arrange
    function_names_all=("fn1" "fn2")

    # Act
    reset_function_names_all

    # Assert
    assert_list_count 0 "${function_names_all[@]}"
}
test_createsection1name_shouldreturnexpectedstring_wheninvoked() {
    echo "${FUNCNAME[0]}"

    # Arrange
    expected="# SETTINGS"

    # Act
    actual=$(create_section1_name)

    # Assert
    assert_strings_equal "$expected" "$actual"
}
test_createsection1shell_shouldreturnexpectedstring_wheninvoked() {
    echo "${FUNCNAME[0]}"

    # Arrange
    expected="SHELL := /bin/bash"

    # Act
    actual=$(create_section1_shell)

    # Assert
    assert_strings_equal "$expected" "$actual"
}
test_createsection1rootdir_shouldreturnexpectedstring_wheninvoked() {
    echo "${FUNCNAME[0]}"

    # Arrange
    expected='ROOT_DIR := $(shell cd .. && pwd)'

    # Act
    actual=$(create_section1_root_dir)

    # Assert
    assert_strings_equal "$expected" "$actual"
}
test_createsection1modulename_shouldreturnexpectedstring_wheninvoked() {
    echo "${FUNCNAME[0]}"

    # Arrange
    module_name="nwsomething"
    expected='MODULE_NAME = "nwsomething"'

    # Act
    actual=$(create_section1_module_name "$module_name")

    # Assert
    assert_strings_equal "$expected" "$actual"
}
test_createsection1moduleversion_shouldreturnexpectedstring_wheninvoked() {
    echo "${FUNCNAME[0]}"

    # Arrange
    version="2.1.0"
    expected='MODULE_VERSION = "2.1.0"'

    # Act
    actual=$(create_section1_module_version "$version")

    # Assert
    assert_strings_equal "$expected" "$actual"
}
test_createsection1coveragethreshold_shouldreturnexpectedstring_whenvalidargument() {
    echo "${FUNCNAME[0]}"

    # Arrange
    threshold=70
    expected="COVERAGE_THRESHOLD = 70"

    # Act
    actual=$(create_section1_coverage_threshold "$threshold")

    # Assert
    assert_strings_equal "$expected" "$actual"
}

# TEST NAMES
declare -a test_names=(
    "test_validatemoduleversion_shouldreturnexpectedexitcode_whenvalidgument"
    "test_validatemoduleversion_shouldreturnexpectedexitcode_wheninvalidgument"
    "test_validatecoveragethreshold_shouldreturnexpectedexitcode_whenvalidgument"
    "test_validatecoveragethreshold_shouldreturnexpectedexitcode_wheninvalidgument"
    "test_validates1_shouldreturnexpectedexitcode_whenvalidfunctionlist"
    "test_validates1_shouldreturnexpectedexitcode_wheninvalidfunctionlist"
    "test_validates1_shouldreturnexpectedexitcode_whenemptyfunctionlist"
    "test_addtofunctionnamess1_shouldcontainexpecteditem_wheninvoked"
    "test_addtofunctionnamess2_shouldcontainexpecteditem_wheninvoked"
    "test_addtofunctionnamess3_shouldcontainexpecteditem_wheninvoked"
    "test_resetfunctionnamesall_shouldremoveallitems_wheninvoked"
    "test_createsection1name_shouldreturnexpectedstring_wheninvoked"
    "test_createsection1shell_shouldreturnexpectedstring_wheninvoked"
    "test_createsection1rootdir_shouldreturnexpectedstring_wheninvoked"
    "test_createsection1modulename_shouldreturnexpectedstring_wheninvoked"
    "test_createsection1moduleversion_shouldreturnexpectedstring_wheninvoked"
    "test_createsection1coveragethreshold_shouldreturnexpectedstring_whenvalidargument"
)

# MAIN
source ./nwmakefiler.sh

for test_name in "${test_names[@]}"; do
    eval "$test_name"
    echo
done