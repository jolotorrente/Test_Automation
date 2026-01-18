*** Settings ***
Library         PuppeteerLibrary
Library         String

### Resource List of Variables ###
Resource        ../Variables/Login_variables.robot

*** Keywords ***
##############################
## Login Component Keywords ##
##############################

#This keyword is used to launch the Test Website (saucedemo.com)
Launch Website
    &{options} =  Create Dictionary                 headless=${HEADLESS}
    Open Browser   ${TEST_URL}                      browser=${BROWSER}    options=${options}
    Set Viewport Size                               1920    1080
    Wait Until Element Is Visible                   xpath://*[@id='user-name']

#This keyword is used to Login on the Test Website (saucedemo.com)
User Login
    [Arguments]    ${username}    ${password}
    Set Screenshot Directory                        ${SCREENSHOT_BASE_DIR}
    Input Text                                      xpath://*[@id='user-name']    ${username}
    Input Password                                  xpath://*[@id='password']     ${password}
    Click Element                                   xpath://*[@id='login-button']
    ${loginstatus} =  Run Keyword And Return Status
    ...  Element Should Be Visible                  xpath://*[@class='app_logo' and text()='Swag Labs']
    IF    ${loginstatus}
        Validate Successful Login
    ELSE
        Validate Failed Login
    END

#This keyword is used to Validate that login page elements exist
Validate Login Page Elements
    #List Variable for repeating xpaths
    ${login_elements} =  Create List
    ...    xpath://*[@id='user-name']
    ...    xpath://*[@id='password']
    ...    xpath://*[@id='login-button']
    FOR  ${elem}  IN  @{login_elements}
        Wait Until Element Is Visible               ${elem}
        Element Should Be Enabled                   ${elem}
    END

    Element Text Should Be                          xpath://*[@class='login_logo']  Swag Labs

    ${userlabel}=    Get Element Attribute          xpath://*[@id='user-name']      placeholder
    Should Be Equal                                 ${userlabel}    Username

    ${passlabel}=    Get Element Attribute          xpath://*[@id='password']       placeholder
    Should Be Equal                                 ${passlabel}    Password

    ${loginlabel}=    Get Element Attribute         xpath://*[@id='login-button']   value
    Should Be Equal                                 ${loginlabel}   Login

# Validate successful login
Validate Successful Login
    ${expected_elements} =  Create List
    ...    xpath://*[@id='react-burger-menu-btn']
    ...    xpath://*[@class='title' and text()='Products']
    ...    xpath://*[@class='shopping_cart_link']
    ...    xpath://*[@class='product_sort_container']
    Wait Until Element Is Visible                   xpath://*[@class='app_logo' and text()='Swag Labs']
    FOR  ${elem}  IN  @{expected_elements}
        Element Should Be Visible    ${elem}
    END
    Set Test Message    User was able login Successfully.    append=yes

# Validate failed login
Validate Failed Login
    &{errors} =  Create Dictionary
    ...    invalid=Epic sadface: Username and password do not match any user in this service
    ...    locked=Epic sadface: Sorry, this user has been locked out.
    ...    emptyuser=Epic sadface: Username is required
    ...    emptypass=Epic sadface: Password is required

    ${actualerror} =  Get Text                      xpath://*[@class='error-message-container error']

    Run Keyword If    '${actualerror}' == '${errors["invalid"]}'    Validate Error Message      ${errors["invalid"]}
    ...    ELSE IF    '${actualerror}' == '${errors["locked"]}'     Validate Error Message      ${errors["locked"]}
    ...    ELSE IF    '${actualerror}' == '${errors["emptyuser"]}'  Validate Error Message      ${errors["emptyuser"]}
    ...    ELSE IF    '${actualerror}' == '${errors["emptypass"]}'  Validate Error Message      ${errors["emptypass"]}
    ...    ELSE                                                     Fail                        msg=Error Flow Not Yet Covered

# Helper for Validate Failed Login
Validate Error Message
    [Arguments]    ${message}
    Element Should Be Visible                       xpath://*[@class='error-message-container error']
    Element Should Contain                          xpath://*[@class='error-message-container error']    ${message}

# Validate input fields accept valid characters
Validate Input Fields
    [Arguments]    @{input}
    FOR    ${newinput}    IN    @{input}
        Input Text                                  xpath://*[@id='user-name']    ${newinput}
        ${testusername} =  Get Value                xpath://*[@id='user-name']
        Should Be Equal As Strings                  ${newinput}    ${testusername}
        Clear Element Text                          xpath://*[@id='user-name']
    END
    FOR    ${newinput}  IN  @{input}
        Input Text                                  xpath://*[@id='password']    ${newinput}
        ${testpassword} =  Get Value                xpath://*[@id='password']
        Should Be Equal As Strings                  ${newinput}    ${testpassword}
        Clear Element Text                          xpath://*[@id='password']
    END