*** Settings ***
Library         PuppeteerLibrary
Library         String

### Resource List of Keywords ###
Resource        ../Keywords/Login_keywords.robot
Resource        ../Keywords/Logout_keywords.robot

### Resource List of Variables ###
Resource        ../Variables/Login_variables.robot

*** Keywords ***
######################################
## Common Global Component Keywords ##
######################################

# This keyword is used to launch the Test Website (saucedemo.com)
Launch Website
    &{options} =  Create Dictionary                 headless=${HEADLESS}
    Open Browser   ${TEST_URL}                      browser=${BROWSER}    options=${options}
    Set Viewport Size                               1920    1080
    Wait Until Element Is Visible                   xpath://*[@id='user-name']


#This keyword is used to Login on the Test Website (saucedemo.com)
User Login
    [Arguments]    ${username}    ${password}
    Set Screenshot Directory                        ${SCREENSHOT_LOGIN_DIR}
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


# This keyword is used to Logout on the Test Website (saucedemo.com)
User Logout
    Wait Until Element Is Visible                   xpath://*[@class='app_logo']
    Open Burger Menu
    Click Element                                   xpath://*[@id='logout_sidebar_link']
    Wait Until Element Is Visible                   xpath://*[@id='user-name']
    Validate Successful Logout


# This keyword is used to display Shopping Cart
Open Cart
    Wait Until Element Is Visible                   xpath://*[@class='app_logo']
    # Declare OpenCart button XPath to ${cart_btn} variable
    ${cart_btn} =           Set Variable            xpath://*[@id='shopping_cart_container']
    Scroll Element Into View                        ${cart_btn}
    Wait Until Element Is Visible                   ${cart_btn}
    Click Element                                   ${cart_btn}
    Wait Until Element Is Visible                   xpath://*[@class='title' and text()='Your Cart']


# This keyqord is used to open the Burger Menu
Open Burger Menu
    Wait Until Element Is Visible                   xpath://*[@class='bm-burger-button']
    Click Element                                   xpath://*[@class='bm-burger-button']
    Wait Until Element is Visible                   xpath://*[@class='bm-menu']


# This keyword is used to return from Shopping Cart to Shopping page
Return to Shopping
    Wait Until Element Is Visible                   xpath://*[@id='continue-shopping']
    Click Element                                   xpath://*[@id='continue-shopping']
    Wait Until Element Is Visible                   xpath://*[@class='title' and text()='Products']