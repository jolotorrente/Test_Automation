*** Settings ***
Library         PuppeteerLibrary
Library         String

### Resource List of Keywords ###
Resource        ../Keywords/Global_keywords.robot
Resource        ../Keywords/Inventory_keywords.robot

### Resource List of Variables ###
Resource        ../Variables/Checkout_variables.robot

*** Keywords ***
######################################
## Keywords for Checkout ##
######################################

# This Keyword is used to checkout current cart
Checkout Cart
    [Arguments]    ${firstname}    ${lastname}    ${postalcode}
    Set Screenshot Directory        ${SCREENSHOT_CHECKOUT_DIR}
    Open Cart
    Validate Cart
    Supply User Information  ${firstname}    ${lastname}    ${postalcode}
    Finish Checkout

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
    Scroll Element Into View                        xpath://*[@id='checkout' and text()='Checkout']
    Click Button                                    xpath://*[@id='checkout' and text()='Checkout']


# This keyword fills the checkout form with random names and postal code
Supply User Information
    [Arguments]    ${firstname}    ${lastname}    ${postalcode}
    Wait Until Element Is Visible                   xpath://*[@class='title' and text()='Checkout: Your Information']
    # Pick random values from the lists
    ${firstname} =          Evaluate                random.choice(@{FIRST_NAME})    random
    ${lastname} =           Evaluate                random.choice(@{LAST_NAME})     random
    ${postalcode} =         Evaluate                random.choice(@{POSTAL_CODE})   random
    # Fill checkout fields with the randomly chosen values
    Input Text                                      xpath://*[@id='first-name']    ${firstname}
    Input Text                                      xpath://*[@id='last-name']     ${lastname}
    Input Text                                      xpath://*[@id='postal-code']   ${postalcode}
    Click Element                                   xpath://*[@id='continue']


# This keyword is used to Complete the Checkout Process After User Information has been Supplied
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
    # Assert totals From Cart + Tax == Checkout Summary Total
    Should Be Equal As Numbers                      ${nettotal}    ${summary_total}
    Click Element                                   xpath://*[@id='finish']
    Wait Until Element Is Visible                   xpath://*[@class='complete-header']
