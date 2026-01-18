*** Settings ***
Library         PuppeteerLibrary
Library         String

### Resource List of Keywords ###
Resource        ../Keywords/Global_keywords.robot

### Resource List of Variables ###
Resource        ../Variables/Login_variables.robot

*** Keywords ***
##############################
## Login Component Keywords ##
##############################

# This keyword is used to Validate that login page elements exist
Validate Login Page Elements
    # List Variable for repeating xpaths
    ${login_elements} =  Create List
    ...    xpath://*[@id='user-name']
    ...    xpath://*[@id='password']
    ...    xpath://*[@id='login-button']

    FOR  ${elem}  IN  @{login_elements}
        Wait Until Element Is Visible               ${elem}
        Element Should Be Enabled                   ${elem}
    END
    Wait Until Element Is Visible                   xpath://*[@class='login_logo']
    Element Text Should Be                          xpath://*[@class='login_logo']  Swag Labs
    ${userlabel} =          Get Element Attribute   xpath://*[@id='user-name']      placeholder
    Should Be Equal                                 ${userlabel}    Username
    ${passlabel} =          Get Element Attribute   xpath://*[@id='password']       placeholder
    Should Be Equal                                 ${passlabel}    Password
    ${loginlabel} =         Get Element Attribute   xpath://*[@id='login-button']   value
    Should Be Equal                                 ${loginlabel}   Login


# This keyword is a sub-keyword helper and is used to Validate that user Log In was Successful
Validate Successful Login
    ${expected_elements} =  Create List
    ...    xpath://*[@id='react-burger-menu-btn']
    ...    xpath://*[@class='title' and text()='Products']
    ...    xpath://*[@class='shopping_cart_link']
    ...    xpath://*[@class='product_sort_container']
    Wait Until Element Is Visible                   xpath://*[@class='app_logo' and text()='Swag Labs']
    FOR     ${elem}     IN      @{expected_elements}
        Element Should Be Visible    ${elem}
    END

    Set Test Message    User was able login Successfully.    append=yes

# This keyword is a sub-keyword helper and is used to Validate that user Log In was Unsuccessful
Validate Failed Login
    ${actualerror} =    Get Text    xpath://*[@class='error-message-container error']
    ${matched} =    Set Variable    ${False}
    #For Loop to Verify different Error Messages for different Negative Test Cases
    FOR    ${key}    ${expected_error}    IN    &{LOGIN_ERRORS}
        IF    '${actualerror}' == '${expected_error}'
            Validate Error Message    ${expected_error}
            ${matched} =    Set Variable    ${True}
            Exit For Loop
        END
    END
    IF    not ${matched}
        Fail    Error Flow Not Yet Covered. Please create a New Test Case for Uncovered Test Case
    END


# This Keyword is a sub-keyword helper for Validate Failed Login
Validate Error Message
    [Arguments]    ${message}
    Element Should Be Visible                       xpath://*[@class='error-message-container error']
    Element Should Contain                          xpath://*[@class='error-message-container error']    ${message}


# This Keyword is used to Validate input / text fields accept valid characters
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