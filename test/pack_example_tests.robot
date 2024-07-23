*** Settings ***
Documentation           Tests to compile & execute remote csolution examples
Suite Setup             Global Setup
Suite Teardown          Global Teardown
Library                 lib${/}utils.py 
Library                 BuiltIn
Library                 String
Library                 Collections
Library                 lib${/}elf_compare.py
Library                 DataDriver
Library                 OperatingSystem
Resource                resources${/}global.resource
Resource                resources${/}utils.resource
Test Template           Test packs examples


*** Variables ***
${context_string}  ${EMPTY}

*** Test Cases ***
Test pack example ${pack_id} and expect ${expect}    Default    UserData

*** Keywords ***
Test packs examples
    [Arguments]     ${pack_id}        ${expect}
    ${pack_root_dir}=        Join And Normalize Path    ${TEST_DATA_DIR}    ${Local_Pack_Root_Dir}
    Create Directory         ${pack_root_dir}
    Cpackget Init            ${pack_root_dir}
    Cpackget Install Pack    ${pack_id}    ${pack_root_dir}
    Change Directory Permissions    ${pack_root_dir}
    ${files}    Glob Files In Directory    ${pack_root_dir}    *.csolution.*    ${True}
    FOR    ${file}    IN    @{files}
        ${file}=    Normalize Path    ${file}
        Run Csolution Project    ${file}    ${expect}
    END

Run Csolution Project
    [Arguments]                      ${input_file}    ${expect}    ${args}=@{EMPTY}
    ${contexts}=    Get Contexts From Project        ${input_file}    ${expect}    ${args}
    ${filcontexts}=    Convert And Filter Contexts    ${contexts}
    Log Many        ${args}
    Log Many        ${filcontexts}
    # Append To List        ${args}    ${filcontexts}
    @{MERGED_LIST}    Create List    @{args}    @{filcontexts}
    Log Many        ${MERGED_LIST}
    Run Project With cbuildgen       ${input_file}    ${expect}    ${MERGED_LIST}
    Run Project with cbuild2cmake    ${input_file}    ${expect}    ${args}
    ${parent_path}=                  Get Parent Directory Path    ${input_file}
    ${result}=                       Run Keyword And Return
    ...    Compare Elf Information   ${input_file}
    ...    ${parent_path}${/}${Out_Dir}${/}${Default_Out_Dir}  
    ...    ${parent_path}${/}${Default_Out_Dir}
    Should Be True    ${result}

Convert And Filter Contexts
    [Documentation]    Example test to convert a string to an array, filter it, and join it
    [Arguments]        ${all_contexts}
    @{lines}=    Split String    ${all_contexts}    \n
    Log    ${lines}

    # Filter out items containing '+iar'
    @{filtered_lines}=    Create List
    FOR    ${line}    IN    @{lines}
        log    ${line}
        ${result}=    Run Keyword And Return Status    Should Contain    ${line}    iar
        Run Keyword If    ${result}==False    Append To List    ${filtered_lines}    ${line}
    END
   Log Many    ${filtered_lines}

    # # Prefix remaining items with '-c ' and join them
    # ${context_string}=    Set Variable    ${EMPTY}
    # FOR    ${line}    IN    @{filtered_lines}
    #     Append To List
    #     ${context_string}=    Evaluate    "-c ${line} ${context_string}"
    # END

    # Log Many       ${context_string}
    # RETURN    ${context_string}

    # Prefix remaining items with '-c ' and join them
    @{context_list_args}=    Create List
    FOR    ${line}    IN    @{filtered_lines}
        Append To List    ${context_list_args}    -c    ${line}
    END

    Log Many       ${context_list_args}
    RETURN    ${context_list_args}
