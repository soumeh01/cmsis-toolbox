*** Settings ***
Documentation    Test to execute csolution example
Suite Setup      Suite Setup
Suite Teardown   Suite Teardown
Resource         ${RESOURCES}/utils.resource
Test Template    Run csolution examples


*** Variables ***
${RESOURCES}      ..${/}resources


*** Test Cases ***           ${input_file}        ${args}
Run build-asm                ${testDataDir}/build-asm${/}solution.csolution.yml
Run build-c cbuild2cmake    ${testDataDir}/build-c${/}solution.csolution.yml
Run build-cpp                ${testDataDir}/build-cpp${/}solution.csolution.yml
# Run include-define           ${testDataDir}/include-define${/}solution.csolution.yml
Run linker-pre-processing    ${testDataDir}/linker-pre-processing${/}solution.csolution.yml
Run pre-include              ${testDataDir}/pre-include${/}solution.csolution.yml


Run build-asm cbuild2cmake                ${testDataDir}${/}build-asm${/}solution.csolution.yml             --cbuild2cmake
Run build-c cbuild2cmake                  ${testDataDir}/build-c${/}solution.csolution.yml                  --cbuild2cmake
Run build-cpp cbuild2cmake                ${testDataDir}/build-cpp${/}solution.csolution.yml                --cbuild2cmake
Run linker-pre-processing cbuild2cmake    ${testDataDir}/linker-pre-processing${/}solution.csolution.yml    --cbuild2cmake
Run pre-include cbuild2cmake              ${testDataDir}/pre-include${/}solution.csolution.yml              --cbuild2cmake


*** Keywords ***
Run csolution examples
    [Arguments]    ${input_file}    @{args}
    Run cbuild     ${input_file}    @{args}

Suite Setup
    ${source_directory}            Set Variable           ${CURDIR}${/}..${/}data
    Set Global Variable            ${testDataDir}         ${source_directory}${/}..${/}run
    Copy Directory with Content    ${source_directory}    ${testDataDir}

Suite Teardown
    Remove Directory               ${testDataDir}         recursive=True
