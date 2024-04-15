*** Settings ***
Documentation    A resource file with reusable keywords and variables.
Library          Process
Library          OperatingSystem

*** Keywords ***
Run Program
    [Documentation]    Run specified executable with arguments
    [Arguments]        ${exe_path}    ${input_File}    @{args}    ${expected_ret_code}=0
    ${result}          Run Process    ${exe_path}      ${input_File}    @{args}    shell=True    stdout=${CURDIR}/stdout.txt	 stderr=STDOUT
    Run Keyword If     '${result.rc}' != '${expected_ret_code}'    Log Many    Output: ${result.stdout}    Return Code: ${result.rc}
    Should Be Equal    '${result.rc}'   '${expected_ret_code}'

Run cbuild
    [Documentation]    Run csolution example with specified arguments
    [Arguments]        ${input_file}    @{args}
    Run Program        cbuild           ${input_file}    @{args}    -p    -r    --update-rte

Change Directory Permissions
    [Documentation]                 Change directory permissions
    [Arguments]                     ${target_dir}
    ${result}    Run Process        chmod    -R    755    ${target_dir}
    Should Be Equal                 ${result.rc}    ${0}

Remove Directory with Content
    [Documentation]                 Remove directory and its content from target directory
    [Arguments]                     ${target_dir}
    Change Directory Permissions    ${target_dir}
    Remove Directory                ${target_dir}      recursive=${True}
    Wait Until Removed              ${target_dir}      timeout=5 seconds
