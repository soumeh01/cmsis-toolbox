*** Settings ***
Documentation    Test to execute csolution example
Suite Setup      Suite Setup
Resource         ${RESOURCES}/utils.resource
Library          Process
Test Template    Run csolution examples


*** Variables ***
${RESOURCES}      ../resources


*** Test Cases ***       ${input_file}    ${args}
Run Hello example        ${testDataDir}/Hello${/}Hello.csolution.yml    -p    -r    --update-rte


*** Keywords ***
Run csolution examples
    [Arguments]      ${input_file}    @{args}
    Run csolution    ${input_file}    @{args}

Suite Setup
    Set Global Variable  ${testDataDir}  ${CURDIR}${/}..${/}data${/}
