*** Settings ***
Documentation           Tests to execute solution examples
Resource                ./global.robot
Resource                ${RESOURCES}/utils.resource
Library                 Collections 
# Variables               TestExamples.yml
Suite Setup             Global Setup
Suite Teardown          Global Teardown
Test Template           Run Example

*** Variables ***
${build-asm}                build-asm
${build-c}                  build-c
${build-cpp}                build-cpp
${include-define}           include-define
${language-scope}           language-scope
${linker-pre-processing}    linker-pre-processing
${pre-include}              pre-include

*** Test Cases ***
Validate build-asm Example
    ${TEST_DATA_DIR}${/}${build-asm}${/}solution.csolution.yml    ${0}

Validate build-c Example
    ${TEST_DATA_DIR}${/}${build-c}${/}solution.csolution.yml      ${0}

Validate build-cpp Example
    ${TEST_DATA_DIR}${/}${build-cpp}${/}solution.csolution.yml    ${0}

Validate include-define Example
    ${TEST_DATA_DIR}${/}${include-define}${/}solution.csolution.yml    ${0}

Validate language-scope Example
    ${TEST_DATA_DIR}${/}${language-scope}${/}solution.csolution.yml    ${0}

Validate linker-pre-processing Example
    ${TEST_DATA_DIR}${/}${linker-pre-processing}${/}solution.csolution.yml    ${0}

Validate pre-include Example
    ${TEST_DATA_DIR}${/}${pre-include}${/}solution.csolution.yml    ${0}


*** Keywords ***
Run Example
    [Arguments]               ${input_file}      ${expect}      ${args}=@{EMPTY}
    ${cbuildgen_args}=        Append Additional Arguments    ${args}
    ${cbuild2cmake_args}=     Append Additional Arguments    ${args}    --cbuild2cmake
    ${ret_code1}=             Run cbuild                     ${input_file}    ${cbuildgen_args}
    ${ret_code2}=             Run cbuild                     ${input_file}    ${cbuild2cmake_args}
    Should Be Equal           ${ret_code1}    ${expect}
    Should Be Equal           ${ret_code2}    ${expect}

Append Additional Arguments
    [Arguments]                  ${list}    @{values}
    ${args}=    Combine Lists    ${list}    ${values}
    RETURN                       ${args}


























# Build Examples with cbuildgen
#     FOR    ${test}    IN    @{Test_Examples}
#     ${ret_code}=    Run cbuild    ${TEST_DATA_DIR}${/}${test["example"]}${/}${test["target"]}.csolution.yml    ${test["args"]}
#     Should Be Equal      ${ret_code}    ${test.expect}
#     END

# Build Examples with cbuild2cmake
#     FOR    ${test}    IN    @{Test_Examples}
#     Append To List          ${test["args"]}    --cbuild2cmake
#     ${ret_code}=    Run cbuild    ${TEST_DATA_DIR}${/}${test["example"]}${/}${test["target"]}.csolution.yml    ${test["args"]}
#     Should Be Equal      ${ret_code}    ${test.expect}
#     END




# *** Variables ***
# @{build_examples}       build-asm    build-c     build-cpp    include-define    linker-pre-processing    pre-include
# @{build_files}          solution     solution    solution     solution          solution                 solution
# @{expected_ret_code}    ${0}         ${0}        ${0}         ${-1}             ${0}                     ${0}



# Build Examples with cbuildgen
#     FOR    ${example}    IN    @{build_examples}
#     ${index}=            Get Index From List    ${build_examples}    ${example}
#     ${ret_code}=         Run cbuild    ${TEST_DATA_DIR}${/}${example}${/}${build_files}[${index}].csolution.yml
#     Should Be Equal      ${ret_code}    ${expected_ret_code}[${index}]
#     END

# Build Examples with cbuild2cmake
#     FOR    ${example}    IN    @{build_examples}
#     ${index}=            Get Index From List    ${build_examples}    ${example}
#     Run cbuild           ${TEST_DATA_DIR}${/}${example}${/}${build_files}[${index}].csolution.yml    --cbuild2cmake
#     END


# Run build-asm                ${TEST_DATA_DIR}${/}build-asm${/}solution.csolution.yml
# Run build-c                  ${TEST_DATA_DIR}/build-c${/}solution.csolution.yml
# Run build-cpp                ${TEST_DATA_DIR}/build-cpp${/}solution.csolution.yml
# # Run include-define         ${TEST_DATA_DIR}/include-define${/}solution.csolution.yml
# Run linker-pre-processing    ${TEST_DATA_DIR}/linker-pre-processing${/}solution.csolution.yml
# Run pre-include              ${TEST_DATA_DIR}/pre-include${/}solution.csolution.yml


# Run build-asm cbuild2cmake                ${TEST_DATA_DIR}${/}build-asm${/}solution.csolution.yml             --cbuild2cmake
# Run build-c cbuild2cmake                  ${TEST_DATA_DIR}/build-c${/}solution.csolution.yml                  --cbuild2cmake
# Run build-cpp cbuild2cmake                ${TEST_DATA_DIR}/build-cpp${/}solution.csolution.yml                --cbuild2cmake
# Run linker-pre-processing cbuild2cmake    ${TEST_DATA_DIR}/linker-pre-processing${/}solution.csolution.yml    --cbuild2cmake
# Run pre-include cbuild2cmake              ${TEST_DATA_DIR}/pre-include${/}solution.csolution.yml              --cbuild2cmake

