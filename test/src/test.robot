*** Settings ***
Documentation           Test to execute solution examples
Suite Setup             Suite Setup
Suite Teardown          Suite Teardown
Resource                ${RESOURCES}/utils.resource
# Test Template           Run csolution examples
Library                 Collections 

*** Variables ***
${RESOURCES}            ..${/}resources
@{build_examples}       build-asm    build-c     build-cpp    linker-pre-processing    pre-include
@{build_files}          solution     solution    solution     solution                 solution

*** Test Cases ***
Build Examples with cbuildgen
    FOR    ${example}    IN    @{build_examples}
    ${index}=    Get Index From List    ${build_examples}    ${example}
    Run cbuild     ${testDataDir}${/}${example}${/}${build_files}[${index}].csolution.yml
    END

Build Examples with cbuild2cmake
    FOR    ${example}    IN    @{build_examples}
    ${index}=    Get Index From List    ${build_examples}    ${example}
    Run cbuild     ${testDataDir}${/}${example}${/}${build_files}[${index}].csolution.yml    --cbuild2cmake
    END
# Run build-asm                ${testDataDir}${/}build-asm${/}solution.csolution.yml
# Run build-c                  ${testDataDir}/build-c${/}solution.csolution.yml
# Run build-cpp                ${testDataDir}/build-cpp${/}solution.csolution.yml
# # Run include-define         ${testDataDir}/include-define${/}solution.csolution.yml
# Run linker-pre-processing    ${testDataDir}/linker-pre-processing${/}solution.csolution.yml
# Run pre-include              ${testDataDir}/pre-include${/}solution.csolution.yml


# Run build-asm cbuild2cmake                ${testDataDir}${/}build-asm${/}solution.csolution.yml             --cbuild2cmake
# Run build-c cbuild2cmake                  ${testDataDir}/build-c${/}solution.csolution.yml                  --cbuild2cmake
# Run build-cpp cbuild2cmake                ${testDataDir}/build-cpp${/}solution.csolution.yml                --cbuild2cmake
# Run linker-pre-processing cbuild2cmake    ${testDataDir}/linker-pre-processing${/}solution.csolution.yml    --cbuild2cmake
# Run pre-include cbuild2cmake              ${testDataDir}/pre-include${/}solution.csolution.yml              --cbuild2cmake

*** Keywords ***
Run csolution examples
    [Arguments]    ${input_file}    @{args}
    Run cbuild     ${input_file}    @{args}

Suite Setup
    ${parent_dir}=                   Join Path         ${CURDIR}        ..
    ${src_dir}=                      Join Path         ${parent_dir}    data
    ${dest_dir}=                     Join Path         ${parent_dir}    run
    Set Global Variable              ${testDataDir}    ${dest_dir}
    Copy Directory                   ${src_dir}        ${testDataDir}

Suite Teardown
    Remove Directory with Content    ${testDataDir}
