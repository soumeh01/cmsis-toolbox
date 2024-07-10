*** Settings ***
Documentation           Tests to compile & execute remote csolution examples
Suite Setup             Global Setup
Suite Teardown          Global Teardown
Library                 lib${/}utils.py 
Library                 String
Library                 Collections
Library                 lib${/}elf_compare.py
Library                 DataDriver
Library                 OperatingSystem
Resource                resources${/}global.resource
Resource                resources${/}utils.resource
Test Template           Test packs examples


*** Test Cases ***
Test pack example ${pack_id} and expect ${expect}    Default    UserData

*** Keywords ***
Test packs examples
    [Arguments]     ${pack_id}        ${expect}
    ${pack_root_dir}=        Set Variable    ${TEST_DATA_DIR}${/}${Local_Pack_Root_Dir}${/}
    Create Directory         ${pack_root_dir}
    Cpackget Init            ${pack_root_dir}
    Cpackget Install Pack    ${pack_id}    ${pack_root_dir}
    ${files}    Glob Files In Directory    ${pack_root_dir}    *.csolution.*    ${True}
    FOR    ${file}    IN    @{files}
        Run Csolution Project    ${file}    ${expect}
    END

Run Csolution Project
    [Arguments]                      ${input_file}    ${expect}    ${args}=@{EMPTY}
    Run Project With cbuildgen       ${input_file}    ${expect}    ${args}
    Run Project with cbuild2cmake    ${input_file}    ${expect}    ${args}
    ${parent_path}=                  Get Parent Directory Path    ${input_file}
    ${result}=                       Run Keyword And Return
    ...    Compare Elf Information   ${input_file}
    ...    ${parent_path}${/}${Out_Dir}${/}${Default_Out_Dir}
    ...    ${parent_path}${/}${Default_Out_Dir}
    Should Be True    ${result}
