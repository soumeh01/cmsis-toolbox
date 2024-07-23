*** Settings ***
Documentation    A collection of commonly used keywords across multiple test suites
Library          BuiltIn
Library          Collections
Library          Process
Library                 String
Library          OperatingSystem
Library          ..${/}lib${/}utils.py
Resource         global.resource

*** Variables ***
${TEST_ENV_FILE}    test_env.md
${RESULT}           ${EMPTY}

*** Keywords ***
Global Setup
    ${parent_dir}=                    Join And Normalize Path    ${CURDIR}        ..
    ${src_dir}=                       Join And Normalize Path    ${parent_dir}    ${Data}
    ${dest_dir}=                      Get Test Data Directory
    Set Global Variable               ${TEST_DATA_DIR}    ${dest_dir}
    Copy Directory                    ${src_dir}          ${dest_dir}
    ${output_file_path}               Get Output File Path
    ${parent_path}=                   Get Parent Directory Path    ${output_file_path}
    ${test_env_file}=    Join And Normalize Path    ${parent_path}    ${TEST_ENV_FILE}
    Write Test Environment            ${test_env_file} 

Global Teardown
    Remove Directory with Content    ${TEST_DATA_DIR}

Get Test Data Directory
    [Documentation]      Retrieve the directory path for test input data
    ${parent_dir}=       Join And Normalize Path    ${CURDIR}        ..
    ${test_data_dir}=    Join And Normalize Path    ${parent_dir}    ${Build}
    RETURN               ${test_data_dir}

Run Program1
    [Documentation]             Run specified executable with arguments
    [Arguments]                 ${exe_path}      ${command}
    ${result}        Run Process    ${exe_path}      ${command}
    ...    shell=True    stdout=${CURDIR}/stdout.txt
    ${ret_code}=                Set Variable If    ${result.rc} == ${0}    ${result.rc}    ${1}
    Log Output String           ${result.stdout}
    RETURN                      ${ret_code}

Run Program
    [Documentation]             Run specified executable with arguments
    [Arguments]                 ${exe_path}      ${command}    ${input_File}    @{args}
    ${result}    Run Process    ${exe_path}      ${command}    ${input_File}    @{args}
    ...    shell=True    stdout=${CURDIR}/stdout.txt
    ${ret_code}=                Set Variable If    ${result.rc} == ${0}    ${result.rc}    ${1}
    Log Output String           ${result.stdout}
    RETURN

Run Program2
    [Documentation]             Run specified executable with arguments
    [Arguments]                 ${exe_path}      ${input_File}    @{args}
    Log Many        ${exe_path}
    Log Many        ${input_file}
    Log Many        ${args}
    ${result}    Run Process    ${exe_path}      ${input_File}    @{args}
    ...    shell=True    stdout=${CURDIR}/stdout.txt
    ${ret_code}=                Set Variable If    ${result.rc} == ${0}    ${result.rc}    ${1}
    Log Output String           ${result.stdout}
    RETURN

# Run cbuild
#     [Documentation]                Run cbuild with specified arguments
#     [Arguments]                    ${cmdline_args}=@{EMPTY}
#     Append To List                 ${cmdline_args}    -p    -r    --update-rte
#     Log Many                       ${cmdline_args}
#     ${str_args}=     Convert List To Single String    ${cmdline_args}
#     Log Many                       ${str_args}
#     ${ret_code}=    Run Program    cbuild    ${str_args}
#     RETURN                         ${ret_code}

Run cbuild
    [Documentation]                Run cbuild with specified arguments
    [Arguments]                    ${input_file}    ${command}    ${args}=@{EMPTY}
    Append To List                 ${args}    -p    -r    --update-rte
    Log Many        ${command}
    Log Many        ${input_file}
    Log Many        ${args}
    ${ret_code}=    Run Keyword If    '${command}' == '${EMPTY}'    Run Program2    cbuild    ${input_file}    @{args}
    ...    ELSE    Run Program    cbuild    ${command}    ${input_file}    @{args}
    # ${ret_code}=    Run Program    cbuild    ${command}    ${input_file}    @{args}
    RETURN                         ${ret_code}

Change Directory Permissions
    [Documentation]                 Change directory permissions
    [Arguments]                     ${target_dir}
    ${result}                       Run Process    chmod    -R    755    ${target_dir}
    Should Be Equal                 ${result.rc}    ${0}

Remove Directory with Content
    [Documentation]                 Remove directory and its content from target directory
    [Arguments]                     ${target_dir}
    ${target_dir}=    Normalize Path    ${target_dir}
    Change Directory Permissions    ${target_dir}
    Remove Directory                ${target_dir}      recursive=${True}
    Wait Until Removed              ${target_dir}      timeout=5 seconds

Checkout GitHub Repository
    [Documentation]                 Checkout github repository
    [Arguments]                     ${github_repo_url}    ${dest_path}
    ${result}=    Run Process       git    clone          ${github_repo_url}    ${dest_path}
    Log                             ${result.stdout}
    Log                             ${result.stderr}
    Should Be Equal As Integers     ${result.rc}          ${0}

Run Project with cbuildgen
    [Documentation]     Run the csolution project with cbuildgen
    [Arguments]         ${input_file}    ${expect}        ${args}=@{EMPTY}
    ${parent_path}=     Get Parent Directory Path         ${input_file}
    ${output_dir}=    Normalize Path    ${parent_path}${/}${Out_Dir}
    Append To List      ${args}    --output    ${output_dir}    --cbuildgen
    # ${args}=    Insert At Front     ${args}    ${input_file}
    ${ret_code}=        Run cbuild       ${input_file}    ${EMPTY}    ${args}
    Should Be Equal     ${ret_code}      ${expect}        msg=Unexpected status returned by cbuildgen execution

Run Project With cbuild2cmake
    [Documentation]     Run the csolution project with cbuild2cmake
    [Arguments]         ${input_file}     ${expect}        ${args}=@{EMPTY}
    Append To List        ${args}    --cbuild2cmake
    ${args}=    Insert At Front     ${args}    ${input_file}
    ${ret_code}=        Run cbuild        ${input_file}    ${empty}    ${args}
    Should Be Equal     ${ret_code}       ${expect}        msg=Unexpected status returned by cbuild2cmake execution

Append Additional Arguments
    [Documentation]              Append values to the list
    [Arguments]                  ${list}    @{values}
    ${args}=    Combine Lists    ${list}    ${values}
    RETURN                       ${args}

Log Output String
    [Documentation]             Log STDOUT message
    [Arguments]                 ${message}
    Log Many                    StdOut: ${message}

Get Output File Path
    [Documentation]             Find path to output files
    ${output_path}=             Get Variable Value    ${OUTPUT_FILE}
    RETURN                      ${output_path}

Get Destination Path
    [Documentation]                 Get destination directory path from url
    [Arguments]                     ${github_url}
    ${dest_dir}=    Evaluate        "${github_url}".split('/')[-1]
    ${dest_dir}=    Set Variable    ${TEST_DATA_DIR}${/}${Remote_Example_Dir}${/}${dest_dir}
    RETURN                          ${dest_dir}

Cpackget Init
    [Documentation]     Initialize pack root directory
    [Arguments]         ${pack_root_dir}
    Run Program         cpackget    init    https://www.keil.com/pack/index.pidx    -R    ${pack_root_dir}

Cpackget Install Pack 
    [Documentation]     Install pack to pack root directory
    [Arguments]         ${pack_id}    ${pack_root_dir}
    ${ret_code}=        Run Program         cpackget    add    ${pack_id}
    ...    -R    ${pack_root_dir}
    ...    --agree-embedded-license    --force-reinstall
    RETURN              ${ret_code}

Get Contexts From Project
    [Documentation]     Run the csolution project with cbuildgen
    [Arguments]         ${input_file}    ${expect}        ${args}=@{EMPTY}
    ${parent_path}=     Get Parent Directory Path         ${input_file}
    ${result}    Run Process    csolution     list    contexts    ${input_File}
    ...    -q    shell=True    stdout=${CURDIR}/stdout.txt
    ${ret_code}=        Set Variable If    ${result.rc} == ${0}    ${result.rc}    ${1}
    Should Be Equal     ${ret_code}      ${expect}        msg=Unexpected status returned by list context command
    RETURN              ${result.stdout}

Convert List To Single String
    [Arguments]    ${LIST}
    ${RESULT}=    Set Variable    ${EMPTY}
    FOR    ${element}    IN    @{LIST}
        ${RESULT}=    Evaluate    ${element} ${RESULT}
    END
    RETURN    ${RESULT}

Join And Normalize Path
    [Arguments]        ${prefixPath}    ${suffixPath}
    ${resultPath}=     Join Path      ${prefixPath}    ${suffixPath}
    ${resultPath}=     Normalize Path    ${resultPath}
    RETURN             ${resultPath}

Normalize Path
    [Arguments]        ${Path}
    ${resultPath}=     Replace String    ${Path}    \\    /
    RETURN             ${resultPath}