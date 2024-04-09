*** Settings ***
Documentation    A resource file with reusable keywords and variables.
Library          Process

*** Keywords ***
Run Program
    [Documentation]    Run specified executable with arguments
    [Arguments]        ${exe_path}    ${input_File}    @{args}    ${expected_ret_code}=0
    ${result}          Run Process    ${exe_path}      ${input_File}    @{args}    shell=True    stdout=${CURDIR}/stdout.txt	 stderr=STDOUT
    Run Keyword If     '${result.rc}' != '${expected_ret_code}'    Log Many    Output: ${result.stdout}    Return Code: ${result.rc}
    Should Be Equal    '${result.rc}'   '${expected_ret_code}'

Run csolution
    [Documentation]    Run csolution example with specified arguments
    [Arguments]        ${input_file}    @{args}
    Run Program        cbuild           ${input_file}    @{args}