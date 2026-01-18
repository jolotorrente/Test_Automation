*** Settings ***
Library         PuppeteerLibrary
Library         String

### Resource List of Keywords ###
Resource        ../Keywords/Global_keywords.robot

### Resource List of Variables ###
Resource        ../Variables/Login_variables.robot
Resource        ../Variables/Logout_variables.robot

*** Keywords ***
###############################
## Logout Component Keywords ##
###############################


# This keyword is used to Verify if User was Properly Logout on the Test Website (saucedemo.com)
Validate Successful Logout
    Set Screenshot Directory                        ${SCREENSHOT_LOGOUT_DIR}
    Validate Login Page Elements
    # Validate the Inventory Page Elements are no longer Available after Logout
    ${unexpected_elements} =  Create List
    ...    xpath://*[@id='react-burger-menu-btn']
    ...    xpath://*[@class='title' and text()='Products']
    ...    xpath://*[@class='shopping_cart_link']
    ...    xpath://*[@class='product_sort_container']
    FOR     ${elem}     IN      @{unexpected_elements}
        Element Should Not Be Visible               ${elem}
    END
    # This will try to Navigate Back on the previous page, which was a Logged In State, using a Javascript
    Execute Javascript      window.history.back()
    # Verify that Error Occured that user can only access previous page when you are logged in
    Element Should Be Visible                       xpath://*[@class='error-message-container error']
    ${actualerror} =        Get Text                xpath://*[@class='error-message-container error']
    Element Text Should Be                          xpath://*[@class='error-message-container error']       ${actualerror}
    Reload Page
    Element Should Be Visible                       xpath://*[@class='error-message-container error']
    ${actualerror} =        Get Text                xpath://*[@class='error-message-container error']
    Element Text Should Be                          xpath://*[@class='error-message-container error']       ${actualerror}


# This keyword is used to Verify if User was Properly Logout on the Test Website (saucedemo.com)
Validate Secured Pages after Logout
    # Build Variable for XPATH locator
    # Build List Variable for the following Webpages
    # For Loop to Navigate to different websites, declared as List Variable, that require Login to verify that pages are Unaccessible
    FOR    ${url}    IN    @{PROTECTED_PAGES}
        Go To                                           ${url}
        Validate Protected Page Error
    END
    # Navigate to a random Product Page
    ${productindex} =    Evaluate    random.randint(0, 10)      random
    Go To                                           https://www.saucedemo.com/inventory-item.html?id=${productindex}
    Validate Protected Page Error
    Reload Page


# This Keyword is a sub-keyword helper to Validate Protected Pages
Validate Protected Page Error
    Element Should Be Visible                       ${ERROR_LOCATOR}
    ${actualerror} =        Get Text                ${ERROR_LOCATOR}
    Element Text Should Be                          ${ERROR_LOCATOR}       ${actualerror}