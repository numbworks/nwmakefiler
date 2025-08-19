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
test_createfunctionnamesall_shouldcontainexpecteditems_wheninvoked() {
    echo "${FUNCNAME[0]}"

    # Arrange
    function_names_s1=("fn1")
    function_names_s2=("fn2")
    function_names_s3=("fn3")
    function_names_all=()

    # Act
    create_function_names_all

    # Assert
    assert_in_list "fn1" "${function_names_all[@]}"
    assert_in_list "fn2" "${function_names_all[@]}"
    assert_in_list "fn3" "${function_names_all[@]}"
    assert_list_count 3 "${function_names_all[@]}"
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

# TEST NAMES
declare -a test_names=(
    "test_validatemoduleversion_shouldreturnexpectedexitcode_whenvalidgument"
    "test_validatemoduleversion_shouldreturnexpectedexitcode_wheninvalidgument"
    "test_validatecoveragethreshold_shouldreturnexpectedexitcode_whenvalidgument"
    "test_validatecoveragethreshold_shouldreturnexpectedexitcode_wheninvalidgument"
    "test_addtofunctionnamess1_shouldcontainexpecteditem_wheninvoked"
    "test_addtofunctionnamess2_shouldcontainexpecteditem_wheninvoked"
    "test_addtofunctionnamess3_shouldcontainexpecteditem_wheninvoked"
    "test_createfunctionnamesall_shouldcontainexpecteditems_wheninvoked"
    "test_resetfunctionnamesall_shouldremoveallitems_wheninvoked"
)

# MAIN
source ./nwmakefiler.sh

for test_name in "${test_names[@]}"; do
    eval "$test_name"
    echo
done