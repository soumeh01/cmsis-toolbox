*** Settings ***
Suite Setup             Global Setup
Suite Teardown          Global Teardown
Library                 lib${/}utils.py 
Library                 String
Library                 Collections
Library                 lib${/}elf_compare.py 
Resource                resources${/}global.resource
Resource                resources${/}utils.resource
Test Template           Test github examples


*** Variables ***
${csolution-examples}       https://github.com/Open-CMSIS-Pack/csolution-examples.git


*** Test Cases ***
Test github example
    ${csolution-examples}    ${Pass}

*** Keywords ***
Test github examples
    [Arguments]                   ${github_url}        ${expect}    ${dest_dir_name}=${Remote_Example_Dir}
    Checkout GitHub Repository    ${github_url}        ${TEST_DATA_DIR}${/}${dest_dir_name}
    ${files}    Glob Files In Directory    ${test_data_dir}${/}${dest_dir_name}    *.csolution.yml    ${True}
    FOR    ${file}    IN    @{files}
        ${example_name}=    Get Parent Directory Name    ${file}
        Run Keyword If    '${example_name}' == 'Hello'    
        ...    Run Csolution Project    ${file}    ${expect}
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
