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
#End-to-End_Regression 01 - User Purchased Products
#    [Tags]  High    Regression
#    User Login                  ${USERNAME}             ${PASSWORD}
#
#End-to-End_Regression 02 - User Remove Products prior to Checkout and Payment
#    [Tags]  High    Regression
#    User Login                  ${USERNAME}             ${PASSWORD}
#
#End-to-End_Regression 03 - Retain Products added to Cart after Logout when User did not complete Checkout
#    [Tags]  High    Regression
