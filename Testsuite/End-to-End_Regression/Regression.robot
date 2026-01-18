#*** Settings ***
#Library         PuppeteerLibrary
#
#### Resource List of Keywords ###
#Resource        ../Keywords/Login_keywords.robot
#
#### Resource List of Variables ###
#Resource        ../Variables/Login_variables.robot
#
#### Documentation ###
#Documentation   This a Regression test suite
#
#### Keyword executed on start of each tests ###
#Test Setup      Launch Website
#
#### Keyword executed on start of each tests ###
#Test Teardown   Close All Browser
#
#
#*** Test Cases ***
#
#Login 01 - Login using valid Username and Password
#    [Tags]  High
#    User Login                  ${USERNAME}             ${PASSWORD}


