*** Settings ***
Library         PuppeteerLibrary

### Resource List of Keywords ###
Resource        ../../Keywords/Global_keywords.robot
Resource        ../../Keywords/Login_keywords.robot
Resource        ../../Keywords/Logout_keywords.robot

### Resource List of Variables ###
Resource        ../../Variables/Login_variables.robot
Resource        ../../Variables/Logout_variables.robot

### Documentation ###
Documentation   This test suite verifies the log-out functionality
...             This also Includes Security Testing by validating Secured Pages
...             This also includes assertion of Elements within the Logout Page

### Keyword executed on start of each tests ###
Test Setup      Launch Website

### Keyword executed on start of each tests ###
Test Teardown   Close All Browser


*** Test Cases ***

Logout 01 - Logout to Website After Successful Login
    [Tags]  High        Regression      Security
    User Login                  ${USERNAME}             ${PASSWORD}
    User Logout


Logout 02 - Logged In Pages Not Accessible After Logout
    [Tags]  High        Regression      Security
    User Login                  ${USERNAME}             ${PASSWORD}
    User Logout
    Validate Secured Pages after Logout

