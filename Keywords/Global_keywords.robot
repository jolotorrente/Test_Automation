*** Settings ***
Library         PuppeteerLibrary
Library         String

### Resource List of Variables ###
Resource        ../Variables/Login_variables.robot

*** Keywords ***
##############################
## Login Component Keywords ##
##############################

# This keyword is used to launch the Test Website (saucedemo.com)
Launch Website
    &{options} =  Create Dictionary                 headless=${HEADLESS}
    Open Browser   ${TEST_URL}                      browser=${BROWSER}    options=${options}
    Set Viewport Size                               1920    1080
    Wait Until Element Is Visible                   xpath://*[@id='user-name']


# This keyword is used to Logout on the Test Website (saucedemo.com)
User Logout
    Wait Until Element Is Visible                   xpath://*[@id='continue-shopping']


# This keyword is used to display Shopping Cart
Open Cart
    #Build OpenCart button XPath
    Wait Until Element Is Visible                   xpath://*[@class='app_logo']
    ${cart_btn} =         Set Variable              xpath://*[@id='shopping_cart_container']
    Scroll Element Into View                        ${cart_btn}
    Wait Until Element Is Visible                   ${cart_btn}
    Click Element                                   ${cart_btn}
    Wait Until Element Is Visible                   xpath://*[@class='title' and text()='Your Cart']


# This keyword is used to return from Shopping Cart to Shopping page
Return to Shopping
    Wait Until Element Is Visible                   xpath://*[@id='continue-shopping']
    Click Element                                   xpath://*[@id='continue-shopping']
    Wait Until Element Is Visible                   xpath://*[@class='app_logo']