*** Settings ***
Library         PuppeteerLibrary

### Resource List of Keywords ###
Resource        ../../Keywords/Global_keywords.robot
Resource        ../../Keywords/Login_keywords.robot
Resource        ../../Keywords/Inventory_keywords.robot
Resource        ../../Keywords/Checkout_keywords.robot

### Resource List of Variables ###
Resource        ../../Variables/Login_variables.robot
Resource        ../../Variables/Checkout_variables.robot

### Documentation ###
Documentation   This test suite verifies the log-in and log out functionality

### Keyword executed on start of each tests ###
Test Setup      Launch Website

### Keyword executed on start of each tests ###
Test Teardown   Close All Browser


*** Test Cases ***
End-to-End_Regression 01 - User to Purchase Products added to Cart
    [Tags]  High    Regression
    User Login                  ${USERNAME}         ${PASSWORD}
    Add Product to Cart
    Checkout Cart               ${FIRST_NAME}       ${LAST_NAME}        ${POSTAL_CODE}
    User Logout

#End-to-End_Regression 02 - User to Remove Products prior to Checkout and Payment
#    [Tags]  High    Regression
#    User Login                  ${USERNAME}             ${PASSWORD}

#End-to-End_Regression 03 - Retain Products added to Cart after Logout when User did not complete Checkout
#    [Tags]  High    Regression
#    User Login