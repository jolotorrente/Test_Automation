*** Variables ***
#############################
${TEST_URL}                         https://www.saucedemo.com/
${BROWSER}                          chrome
${HEADLESS}                         ${False}
${SCREENSHOT_INVENTORY_DIR}         C:/Test_Automation/reports/screenshots/Products


###########################
## USER TYPES AND INPUTS ##
###########################
${USERNAME}                         standard_user
${INVALID_USERNAME}                 standard-user
${LOCKED_USERNAME}                  locked_out_user
${PASSWORD}                         secret_sauce
${INVALIDPASSWORD}                  secret-sauce
${NULL}
@{INPUT_VALIDATION}                 123qwe!@#  123098  hello world  @$@&$@!@$%.,  1 a ^