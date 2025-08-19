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
)

# MAIN
source ./nwmakefiler.sh

for test_name in "${test_names[@]}"; do
    eval "$test_name"
    echo
done