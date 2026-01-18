*** Settings ***
Library         PuppeteerLibrary
Library         String

### Resource List of Keywords ###
Resource        ../Keywords/Inventory_keywords.robot

### Resource List of Variables ###
Resource        ../Variables/Checkout_variables.robot

*** Keywords ***
######################################
## Keywords for Checkout ##
######################################

# This Keyword is used to checkout current cart
Checkout Cart
    [Arguments]  ${firstname}   ${lastname}     ${postalcode}

    Open Cart
    Input Text                              xpath://*[@id='first-name']         ${firstname}
    Input Text                              xpath://*[@id='last-name']          ${lastname}
    Input Text                              xpath://*[@id='postal-code']        ${postalcode}
    Click Element                           xpath://*[@id='finish']