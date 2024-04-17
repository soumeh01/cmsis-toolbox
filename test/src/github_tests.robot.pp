*** Settings ***
Library           DataDriver
Resource          .${/}global.robot
Resource          ${RESOURCES}/utils.resource
Test Template     Test github examples

*** Variables ***
${EXTENSION}    .csolution.yml

*** Test Cases ***
Test github example ${github_url}    Default

*** Keywords ***
Test github examples
    [Arguments]                   ${github_url}
    ${test_data_dir}=             Get Test Data directory
    Checkout GitHub Repository    ${github_url}    ${test_data_dir}${/}remote_examples
    @{files}=    List Files In Directory    ${test_data_dir}${/}remote_examples    recursive=True    pattern=*.txt
    FOR    ${file}    IN    @{files}
        Log    ${file}
    END