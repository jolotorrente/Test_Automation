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
Checkout 01 - Checkout Products added to Cart
    [Tags]  High    Regression
    User Login                  ${USERNAME}         ${PASSWORD}
    Add Product to Cart
    Checkout Cart               ${FIRST_NAME}       ${LAST_NAME}        ${POSTAL_CODE}
    User Logout

Checkout 02 - Negative Test: Checkout without any User Information (All Fields are NULL)
    [Tags]  High    Regression
    User Login                  ${USERNAME}         ${PASSWORD}
    Add Product to Cart
    Checkout Cart               ${MY_LIST}          ${MY_LIST}          ${MY_LIST}

Checkout 03 - Negative Test: Checkout without First Name
    [Tags]  Medium
    User Login                  ${USERNAME}         ${PASSWORD}
    Add Product to Cart
    Checkout Cart               ${MY_LIST}          ${LAST_NAME}        ${POSTAL_CODE}

Checkout 04 - Negative Test: Checkout without Last Name
    [Tags]  Medium
    User Login                  ${USERNAME}         ${PASSWORD}
    Add Product to Cart
    Checkout Cart               ${FIRST_NAME}       ${MY_LIST}          ${POSTAL_CODE}

Checkout 05 - Negative Test: Checkout without Postal Code
    [Tags]  Medium
    User Login                  ${USERNAME}         ${PASSWORD}
    Add Product to Cart
    Checkout Cart               ${FIRST_NAME}       ${LAST_NAME}        ${MY_LIST}

Checkout 06 - Validate Checkout: User Information Page Elements
    [Tags]  Low
    User Login                  ${USERNAME}         ${PASSWORD}
    Add Product to Cart
    Validate User Information Page Elements
    User Logout