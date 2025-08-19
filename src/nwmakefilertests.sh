#!/bin/bash

# Helpers
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

# Tests
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

# Main
source ./nwmakefiler.sh

clear
test_validatemoduleversion_shouldreturnexpectedexitcode_whenvalidgument
echo
test_validatemoduleversion_shouldreturnexpectedexitcode_wheninvalidgument
echo
test_validatecoveragethreshold_shouldreturnexpectedexitcode_whenvalidgument
echo
test_validatecoveragethreshold_shouldreturnexpectedexitcode_wheninvalidgument