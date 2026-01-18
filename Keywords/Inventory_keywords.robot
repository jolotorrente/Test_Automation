*** Settings ***
Library         PuppeteerLibrary
Library         String
Library         Collections

### Resource List of Keywords ###
Resource        ../Keywords/Global_keywords.robot

### Resource List of Variables ###
Resource        ../Variables/Login_variables.robot
Resource        ../Variables/Inventory_variables.robot


*** Keywords ***
######################################
## Keywords for Product Interaction ##
######################################

# This keyword is used to Assert Login Page Elements
Validate Inventory Page Elements
    #Assertions for Existence of Inventory Page Elements
    #App Logo
    Wait Until Element Is Visible                   xpath://*[@class='app_logo']
    Element Text Should Be                          xpath://*[@class='app_logo']  Swag Labs
    #Shopping Cart
    Wait Until Element Is Visible                   xpath://*[@id='shopping_cart_container']
    Element Should Be Enabled                       xpath://*[@id='shopping_cart_container']
    #Burger Menu
    Wait Until Element Is Visible                   xpath://*[@id='react-burger-menu-btn']
    Element Should Be Enabled                       xpath://*[@id='react-burger-menu-btn']
    #Product Title
    Wait Until Element Is Visible                   xpath://*[@class='title']
    Element Text Should Be                          xpath://*[@class='title']  Products
    #Product Sort Container
    Wait Until Element Is Visible                   xpath://*[@class='product_sort_container']
    Element Should Be Enabled                       xpath://*[@class='product_sort_container']
    #Inventory List
    Wait Until Element Is Visible                   xpath://*[@class='inventory_list']


# This keyword is used to Assert Elements on Product View
Validate Element Per Product
    ${productcount} =       Get Element Count       xpath://*[@class='inventory_item']//*[@class='inventory_item_name ']
    FOR     ${i}    IN RANGE    ${productcount}
        ${index} =          Evaluate  ${i} + 1
        Element Should Be Visible                   xpath://*[@class='inventory_item'][${index}]//*[@class='inventory_item_img']
        ${productname} =    Get Text                xpath://*[@class='inventory_item'][${index}]//*[@class='inventory_item_description']//*[@class='inventory_item_name ']
        Click Element                               xpath://*[@class='inventory_item'][${index}]//*[@class='inventory_item_img']
        Wait Until Element Is Visible               xpath://*[@id='back-to-products']
        Element Should Be Visible                   xpath://*[@class='inventory_details_img_container']
        Capture Page Screenshot                     Listed-Product-${index}.png
        Click Element                               xpath://*[@id='back-to-products']
    END


# This keyword is used to Add Random Products to Cart
Add Product to Cart
    #Count the total Products in the Current Page
    Wait Until Element Is Visible                   xpath://div[@class='inventory_item']
    ${productcounter} =     Get Element Count       xpath://div[@class='inventory_item']
    # Generate a random number how many products to add
    ${productquantity} =    Evaluate                random.randint(1, ${productcounter})    random
    # Generate a list of unique random indexes
    ${add_indexes} =        Evaluate                list(range(1, ${productcounter}+1))    # list of all indexes
    ${random_indexes} =     Evaluate                random.sample(${add_indexes}, ${productquantity})    random
    # Loop through each unique random indexes
    FOR     ${index}    IN      @{random_indexes}
        # Build Add to cart button XPath
        ${add_btn} =        Set Variable            xpath://*[@class='inventory_item'][${index}]//*[text()='Add to cart']
        # Get relativeproduct name  to the button
        ${productname} =    Get Text                xpath://*[@class='inventory_item'][${index}]//*[@class='inventory_item_description']//*[@class='inventory_item_name ']
        # Scroll until Add Button is Visible on the active screen
        Scroll Element Into View                    ${add_btn}
        Wait Until Element Is Visible               ${add_btn}
        Click Element                               ${add_btn}
        # Validate in Cart that Product was added
        Open Cart
        Wait Until Element Is Visible               xpath://*[@class='title' and text()='Your Cart']
        Element Should Be Visible                   xpath://*[@class='inventory_item_name' and text()='${productname}']
        Set Screenshot Directory                    ${SCREENSHOT_INVENTORY_DIR}
        Capture Page Screenshot                     Product-${productname}_Added to Cart.png
        Return to Shopping
    END
    # Validate Final Cart Badge
    Wait Until Element Is Visible                   xpath://span[@class='shopping_cart_badge']
    ${cartcounter} =        Get Text                xpath://span[@class='shopping_cart_badge']
    Should Be Equal As Integers                     ${cartcounter}    ${productquantity}


# This keyword is used to Remove Random Product
Remove Product from Shopping Page
    [Arguments]    ${quantity}=1    ${retries}=3
    Wait Until Element Is Visible                   xpath://button[text()='Remove']
    @{removed_products} =   Create List
    ${attempt} =    Set Variable    0
    WHILE    ${attempt} < ${retries}
        ${remove_count} =   Get Element Count       xpath://button[text()='Remove']
        Run Keyword If      ${remove_count} == 0    Exit For Loop
        ${actual_qty} =     Evaluate                min(${quantity}, ${remove_count})
        FOR    ${i}    IN RANGE    ${actual_qty}
            # Pick random Remove button
            ${random_index} =   Evaluate            random.randint(1, ${remove_count})    random
            ${remove_btn} =     Set Variable        xpath:(//button[text()='Remove'])[${random_index}]
            # Capture product name from CART *before removal*
            Open Cart
            Wait Until Element Is Visible           xpath://div[@class='cart_item']
            ${cart_items} =     Get Element Count   xpath://div[@class='cart_item']
            Run Keyword If    ${cart_items} == 0    Exit For Loop
            ${productname} =    Get Text            xpath:(//div[@class='cart_item'])[1]//div[@class='inventory_item_name']
            Append To List    ${removed_products}    ${productname}
            Return to Shopping
            Wait Until Element Is Visible           ${remove_btn}
            Click Element                           ${remove_btn}
            Sleep   0.5s
            # Validate Add button reappears
            Wait Until Element Is Visible           xpath:(//button[text()='Add to cart'])[${random_index}]
            # Validate product is removed from cart
            Open Cart
            Wait Until Element Is Visible           xpath://*[@class='title' and text()='Your Cart']
            Element Should Not Be Visible           xpath://div[@class='inventory_item_name' and text()='${productname}']
            Return to Shopping
        END
        Exit For Loop
    END


# This keyword is used to Remove a Product from the Shopping Cart
Remove Product from Shopping Cart
    Open Cart
    Wait Until Element Is Visible                   xpath://*[@class='cart_list']//*[text()='Remove']
    ${removebtncounter} =   Get Element Count       xpath://*[@class='cart_list']//*[text()='Remove']
    # Generate a random number on which product to remove
    ${remove_indexes} =     Evaluate                list(range(1, ${removebtncounter} + 1))     random
    ${random_index} =       Evaluate                random.choice(${remove_indexes})            random
    # Build Remove to cart button XPath
    ${remove_btn} =         Set Variable            xpath://*[@class='cart_list']//*[@class='cart_item'][${random_index}]//*[text()='Remove']
    ${productname} =        Get Text                xpath://*[@class='cart_list']//*[@class='cart_item'][${random_index}]//*[@class='inventory_item_name']
    # Scroll until Remove Button is Visible on the active screen
    Wait Until Element Is Visible                   xpath://*[@class='cart_list']//*[text()='Remove']
    Scroll Element Into View                        ${remove_btn}
    Wait Until Element Is Visible                   ${remove_btn}
    Click Element                                   ${remove_btn}
    # Validate product was removed from cart (before reload)
    Wait Until Element Is Visible                   xpath://*[@class='title' and text()='Your Cart']
    Element Should Not Be Visible                   xpath://*[@class='inventory_item_name' and text()='${productname}']
    # Reload page and validate again
    Reload Page
    Wait Until Element Is Visible                   xpath://*[@class='title' and text()='Your Cart']
    Element Should Not Be Visible                   xpath://*[@class='inventory_item_name' and text()='${productname}']
    # Cross-check inventory page
    Go To                                           https://www.saucedemo.com/inventory.html
    Wait Until Element Is Visible                   xpath://div[@class='inventory_item' and .//div[text()='${productname}']]
    Element Should Be Visible                       xpath://div[@class='inventory_item' and .//div[text()='${productname}']]//button[text()='Add to cart']
    Capture Page Screenshot                         Product-${productname}_Removed_and_Inventory_Checked.png
    Return to Shopping