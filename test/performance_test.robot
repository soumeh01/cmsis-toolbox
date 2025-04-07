*** Settings ***
Library           OperatingSystem
Library           Collections
Library           Process
Library           String
Suite Setup       Read And Clone Repositories
# Suite Teardown    Remove Directory with Content    ${CURDIR}${/}${CLONE_DIR}
Resource          resources${/}exec.resource

*** Variables ***
${INPUT_FILE}    input.csv
${OUTPUT_FILE}   performance_record.json    # Default value
${CLONE_DIR}     performance_test_dir
@{REPO_LIST}     # Stores cloned repository information

*** Test Cases ***
Record Command Execution Time
    FOR    ${input}    IN    @{REPO_LIST}
        ${data}               Split String    ${input}    ,
        ${csolution_file}     Set Variable    ${data}[1]
        ${expect}             Set Variable    ${data}[2]
        ${example_dir}        Set Variable    ${data}[3]
        ${expect_int}         Convert To Integer    ${expect}
        # Run Cbuild Setup      ${example_dir}${/}${csolution_file}    ${expect_int}    --perf-report=${OUTPUT_FILE}
    END
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
        ${clone_path}    Set Variable    ${CURDIR}${/}${CLONE_DIR}${/}${repo_name}

        Checkout GitHub Repository    ${github_url}    ${clone_path}
        Run Process    git    clone    ${github_url}    ${clone_path}
        Append To List    ${REPO_LIST}    ${github_url},${file_path},${expectation},${clone_path}
    END

    Log    Cloned Repositories: ${REPO_LIST}
