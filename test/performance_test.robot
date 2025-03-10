*** Settings ***
Library           OperatingSystem
Library           Collections
Library           Process
Library           String
Library           lib${/}record_execution_time.py 
Suite Setup       Read And Clone Repositories
Suite Teardown    Remove Directory with Content    ${CURDIR}/performance_test_dir
Resource          resources${/}exec.resource

*** Variables ***
${INPUT_FILE}    input.csv
${OUTPUT_FILE}   performance_record.csv    # Default value
@{REPO_LIST}     # Stores cloned repository information

*** Test Cases ***
Record Command Execution Time
    Record Execution Times     ${REPO_LIST}    ${OUTPUT_FILE}
    # FOR    ${item}    IN    @{REPO_LIST}
    #     ${data}           Split String    ${item}    ,
    #     ${github_url}     Set Variable    ${data}[0]
    #     ${file_path}      Set Variable    ${data}[1]
    #     ${expectation}    Set Variable    ${data}[2]
    #     ${clone_path}    Set Variable    ${data}[3]

    #     Log To Console    \nRepo: ${github_url}
    #     Log To Console    Path: ${file_path}
    #     Log To Console    Expectation: ${expectation}
    #     Log To Console    Clone Path: ${clone_path}
    # END

*** Keywords ***
Read And Clone Repositories
    ${file_content}    Get File    ${INPUT_FILE}
    ${lines}    Split To Lines    ${file_content}
    
    # Remove the header row safely
    ${line}    Get From List    ${lines}    0    
    ${header}    Set Variable    ${line}
    Remove From List    ${lines}    0

    # # Remove the directory if it exists
    # Remove Directory with Content    ${CURDIR}/performance_test_dir
    FOR    ${line}    IN    @{lines}
        ${data}           Split String    ${line}    ,
        ${github_url}     Set Variable    ${data}[0]
        ${file_path}      Set Variable    ${data}[1]
        ${expectation}    Set Variable    ${data}[2]

        # Clone the repository
        ${repo_name}    Evaluate    "${github_url}".split("/")[-1]
        ${clone_path}    Set Variable    ${CURDIR}/performance_test_dir/${repo_name}

        Checkout GitHub Repository    ${github_url}    ${clone_path}
        Run Process    git    clone    ${github_url}    ${clone_path}
        Append To List    ${REPO_LIST}    ${github_url},${file_path},${expectation},${clone_path}
    END

    Log    Cloned Repositories: ${REPO_LIST}

# Print Cloned Repositories
#     Log To Console    \n====== Cloned Repositories Summary ======
#     FOR    ${item}    IN    @{REPO_LIST}
#         ${data}           Split String    ${item}    ,
#         ${github_url}     Set Variable    ${data}[0]
#         ${file_path}      Set Variable    ${data}[1]
#         ${expectation}    Set Variable    ${data}[2]

#         Log To Console    \nURL: ${github_url}
#         Log To Console    Path: ${file_path}
#         Log To Console    Expectation: ${expectation}
#     END
