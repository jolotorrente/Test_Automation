*** Settings ***
Library         PuppeteerLibrary

### Resource List of Keywords ###
Resource        ../../Keywords/Global_keywords.robot
Resource        ../../Keywords/Login_keywords.robot

### Resource List of Variables ###
Resource        ../../Variables/Login_variables.robot

### Documentation ###
Documentation   This test suite verifies the log-in and log out functionality

### Keyword executed on start of each tests ###
Test Setup      Launch Website

### Keyword executed on start of each tests ###
Test Teardown   Close All Browser


*** Test Cases ***

Login 01 - Login using valid Username and Password
    [Tags]  High
    User Login                  ${USERNAME}             ${PASSWORD}

Login 02 - Negative Test: Login using valid Username Invalid Password
    [Tags]  Medium
    User Login                  ${USERNAME}             ${INVALIDPASSWORD}

Login 03 - Negative Test: Login using Locked Out User
    [Tags]  Medium
    User Login                  ${LOCKED_USERNAME}      ${PASSWORD}

Login 04 - Negative Test: Login using Empty or Null Username
    [Tags]  Low
    User Login                  ${NULL}                 ${PASSWORD}

Login 05 - Negative Test: Login using Empty or Null Password
    [Tags]  Low
    User Login                  ${USERNAME}             ${NULL}

Login 06 - Login Credentials should allow alphanumeric and special characters
    [Tags]  Low
    Validate Input Fields       ${INPUT_VALIDATION}

Login 07 - Validate Login Page Elements
    [Tags]  Low
    Validate Login Page Elements

Logout 01 - Logout to Website After Successful Login
    [Tags]  High    Regression      Security
    User Login                  ${USERNAME}             ${PASSWORD}
    User Logout