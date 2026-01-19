*** Settings ***
Library         PuppeteerLibrary
Library         String

### Resource List of Keywords ###
Resource        ../Keywords/Global_keywords.robot
Resource        ../Keywords/Inventory_keywords.robot

### Resource List of Variables ###
Resource        ../Variables/Checkout_variables.robot

*** Keywords ***
##################################
##  Checkout Component Keywords ##
##################################

# This Keyword is used to checkout current cart
Checkout Cart
    [Arguments]    ${firstname}    ${lastname}    ${postalcode}
    Set Screenshot Directory        ${SCREENSHOT_CHECKOUT_DIR}
    Open Cart
    Validate Cart
    Initiate Checkout
    Supply User Information  ${firstname}    ${lastname}    ${postalcode}
    Finish Checkout


# This Keyword is used to checkout current cart
Initiate Checkout
    # Build Add to cart button XPath
    ${checkout_btn} =       Set Variable            xpath://*[@id='checkout' and text()='Checkout']
    Scroll Element Into View                        ${checkout_btn}
    Click Button                                    ${checkout_btn}


# This keyword Validates the Gross Total of Products added to Cart by Adding the Prices of each Product
Validate Cart
    Wait Until Element Is Visible                   xpath://*[@id='checkout' and text()='Checkout']
    # Get the total number of items in the cart that will be used for the FOR Loop
    ${cart_count} =         Get Element Count       xpath://*[@class='inventory_item_price']
    ${total} =              Set Variable            0
    # Loop through all items and sum the prices
    FOR    ${index}    IN RANGE    1    ${cart_count + 1}
        ${price_text} =     Get Text                xpath:(//*[@class='inventory_item_price'])[${index}]
        # Remove $ sign and convert to float
        ${price} =          Evaluate                float(${price_text.replace('$','')})
        ${total} =          Evaluate                ${total} + ${price}
        Set Test Variable    ${total}
    END
    Sleep    1s


# This keyword Completes the Checkout form with random names and postal code from a List Variable
# List Variable is declared on Checkout_variables.robot
Supply User Information
    [Arguments]    ${firstname}    ${lastname}    ${postalcode}
    Wait Until Element Is Visible                   xpath://*[@class='title' and text()='Checkout: Your Information']
    # Pick random values from the lists
    ${firstname} =          Evaluate                random.choice(@{FIRST_NAME})    random
    Set Test Variable    ${firstname}
    ${lastname} =           Evaluate                random.choice(@{LAST_NAME})     random
    Set Test Variable    ${lastname}
    ${postalcode} =         Evaluate                random.choice(@{POSTAL_CODE})   random
    Set Test Variable    ${postalcode}
    # Fill checkout fields with the randomly chosen values
    Input Text                                      xpath://*[@id='first-name']    ${firstname}
    Input Text                                      xpath://*[@id='last-name']     ${lastname}
    Input Text                                      xpath://*[@id='postal-code']   ${postalcode}
    # Check if all three input values are NOT empty
    IF    '${firstname}' != '' and '${lastname}' != '' and '${postalcode}' != ''
        Validate Complete User Information
    ELSE
        Validate Incomplete User Information Error
    END


# This keyword Validates User Information supplied and Completes the Step 1: User Information of Checkout
Validate Complete User Information
    ${textfirst} =          Get Value               xpath://*[@id='first-name']
    Should Be Equal As Strings                      ${firstname}    ${textfirst}
    ${textlast} =           Get Value               xpath://*[@id='last-name']
    Should Be Equal As Strings                      ${lastname}     ${textlast}
    ${textpostal} =         Get Value               xpath://*[@id='postal-code']
    Should Be Equal As Strings                      ${postalcode}   ${textpostal}
    Sleep   1s
    Click Element                                   xpath://*[@id='continue']


# This keyword Validates error handling on supplied User Information
Validate Incomplete User Information Error
    Click Element                                   xpath://*[@id='continue']
    # Get the actual error message displayed on the UI
    ${actual_error}=        Get Text                xpath://*[@class='error-message-container error']
    # Loop through expected checkout error messages
    FOR    ${expected_error}    IN    @{USERINFOCHECKOUTERROR}
        IF    '${actual_error}' == '${expected_error}'
            # Expected error encountered – validation passes
            Element Should Be Visible               xpath://*[@class='error-message-container error']
            Element Should Contain                  xpath://*[@class='error-message-container error']    ${expected_error}
            ${matched} =    Set Variable            ${True}
            User Logout
            Pass Execution                          Error Occurred: ${actual_error} Has Been Validated. Expected Error In Negative Tests
        END
    END
    #Fallout IF Statement if the Error Message encountered was not defined the List Variable
    IF    not ${matched}
        Fail                    Error Flow Not Yet Covered. Please create a New Test Case for Uncovered Error Message
    END


# This keyword Completes the Checkout Process After User Information has been Supplied
Finish Checkout
    Wait Until Element Is Visible                   xpath://*[@id='finish']
    # Get tax and convert to float
    ${tax_text} =           Get Text                xpath://*[@class='summary_tax_label']
    ${tax} =                Evaluate                float("${tax_text}".split('$')[1])
    Log  Total Tax Amount = ${tax}
    # Calculate net total (items total + tax)
    ${nettotal} =    Evaluate    ${total} + ${tax}
    Log  Net Total = ${nettotal}
    # Get summary total from page and convert to float
    ${summarytotal_text} =  Get Text                xpath://*[@class='summary_total_label']
    ${summary_total} =      Evaluate                float("${summarytotal_text}".split('$')[1])
    Log  Summary Total = ${summary_total}
    # Assert Final Total Amount by comparing Total From Cart + Tax and Checkout Summary Total
    Should Be Equal As Numbers                      ${nettotal}    ${summary_total}
    Click Element                                   xpath://*[@id='finish']
    Wait Until Element Is Visible                   xpath://*[@class='complete-header']


# This keyword Validates existence of Checkout: User Information page elements
Validate User Information Page Elements
    Set Screenshot Directory        ${SCREENSHOT_CHECKOUT_DIR}
    Open Cart
    Initiate Checkout
    # List Variable for repeating xpaths
    @{userinfo_elem} =  Create List
    ...    xpath://*[@id='first-name']
    ...    xpath://*[@id='last-name']
    ...    xpath://*[@id='postal-code']
    FOR    ${elem}    IN    @{userinfo_elem}
        Wait Until Element Is Visible               ${elem}
        Element Should Be Enabled                   ${elem}
        ${elemvalue}=    Get Value                  ${elem}
        Should Be Empty                             ${elemvalue}
    END
    # Placeholder validations
    ${fname_label} =        Get Element Attribute   ${userinfo_elem}[0]         placeholder
    Should Be Equal                                 ${fname_label}              First Name
    ${lname_label} =        Get Element Attribute   ${userinfo_elem}[1]         placeholder
    Should Be Equal                                 ${lname_label}              Last Name
    ${zip_label} =          Get Element Attribute   ${userinfo_elem}[2]         placeholder
    Should Be Equal                                 ${zip_label}                Zip/Postal Code
    # Page-level validation
    Element Should Be Visible                       xpath://*[@class='title']
    Element Text Should Be                          xpath://*[@class='title']   Checkout: Your Information
    Element Should Be Visible                       xpath://*[@id='cancel']
    Element Text Should Be                          xpath://*[@id='cancel']     Cancel