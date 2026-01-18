*** Settings ***
Library         PuppeteerLibrary

### Resource List of Keywords ###
Resource        ../../Keywords/Login_keywords.robot
Resource        ../../Keywords/Inventory_keywords.robot
Resource        ../../Keywords/Checkout_keywords.robot

### Resource List of Variables ###
Resource        ../../Variables/Login_variables.robot

### Documentation ###
Documentation   This test suite verifies the log-in and log out functionality

### Keyword executed on start of each tests ###
Test Setup      Launch Website

### Keyword executed on start of each tests ###
Test Teardown   Close All Browser


*** Test Cases ***

Product-Intercation 01 - Validate Product Inventory Page Elements
    [Tags]  High
    User Login                  ${USERNAME}             ${PASSWORD}
    Validate Inventory Page Elements

Product-Intercation 02 - Add Product from the Shopping Page
    [Tags]  High
    User Login                  ${USERNAME}             ${PASSWORD}
    Add Product to Cart

Product-Intercation 03 - Add and Remove Product from the Shopping Page
    [Tags]  High
    User Login                  ${USERNAME}             ${PASSWORD}
    Add Product to Cart
    Remove Product from Shopping Page

 Product-Intercation 4 - Add Product from the Shopping Page and Remove Product from the Shopping Cart
    [Tags]  High
    User Login                  ${USERNAME}             ${PASSWORD}
    Add Product to Cart
    Remove Product from Shopping Cart