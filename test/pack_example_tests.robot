*** Settings ***
Documentation           Tests to build pack csolution examples
Suite Setup             Create Test Data Directory
Suite Teardown          Global Teardown
Library                 BuiltIn
Library                 Collections
Library                 DataDriver
Library                 OperatingSystem
Library                 String
Library                 lib${/}elf_compare.py
Library                 lib${/}utils.py 
Resource                resources${/}global.resource
Resource                resources${/}utils.resource
Resource                resources${/}exec.resource
Test Template           Test packs examples


*** Variables ***
${context_string}  ${EMPTY}

*** Test Cases ***
Test pack example ${pack_id} and expect ${expect}    Default    UserData

*** Keywords ***
Test packs examples
    [Arguments]     ${pack_id}    ${expect}
    ${pack_root_dir}=    Join Paths    ${TEST_DATA_DIR}    ${Local_Pack_Root_Dir}
    Create Directory                   ${pack_root_dir}
    Initialize Pack Root Directory     ${pack_root_dir}
    Install Pack         ${pack_id}    ${pack_root_dir}
    Change Directory Permissions       ${pack_root_dir}

    # ${i}=    Set Variable    0
    ${failed_iterations}=    Create List
    ${files}    Glob Files In Directory    ${pack_root_dir}    *.csolution.*    ${True}
    FOR    ${file}    IN    @{files}
        # ${i}=    Evaluate    ${i} + 1
        # Log To Console    \n===========================================
        # Log To Console    Example ${i}: ${file}
        ${file}=      Normalize Path    ${file}
        ${status}=    Run Csolution Project    ${file}    ${expect}
        Run Keyword If    '${status}' == 'False'    Append To List    ${failed_iterations}    ${file}
    END

    IF    ${failed_iterations} != []
        Fail    Test failed for : ${failed_iterations}
    END

    # ${file_count}=    Get Length    ${files}
    # ${limit}=         Evaluate    min(${file_count}, 5)

    # FOR    ${i}    IN RANGE    ${limit}
    #     ${file}=    Set Variable    ${files[${i}]}
    #     ${file}=    Normalize Path    ${file}
    #     Log To Console    \n===========================================
    #     Log To Console    Example ${i + 1}: ${file}
    #     Run Csolution Project    ${file}    ${expect}
    # END
