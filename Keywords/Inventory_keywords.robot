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
###################################################
##  Inventory / Shopping Page Component Keywords ##
###################################################

# This keyword Asserts the Inventory Page Elements
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


# This keyword Asserts Product Elements on Product View
Validate Product Elements on Product View
    ${productcount}=  Get Element Count             xpath://*[@class='inventory_item']//*[@class='inventory_item_name ']
    FOR  ${i}  IN RANGE  ${productcount}
        ${index}=  Evaluate  ${i} + 1
        Element Should Be Visible                   xpath://*[@class='inventory_item'][${index}]//*[@class='inventory_item_img']
        ${productname}=  Get Text                   xpath://*[@class='inventory_item'][${index}]//*[@class='inventory_item_description']//*[@class='inventory_item_name ']
        Click Element                               xpath://*[@class='inventory_item'][${index}]//*[@class='inventory_item_img']
        Wait Until Element Is Visible               xpath://*[@id='back-to-products']
        Element Should Be Visible                   xpath://*[@class='inventory_details_img_container']
        Capture Page Screenshot                     Listed-Product-${index}.png
        Click Element                               xpath://*[@id='back-to-products']
    END


# This keyword Returns the total number of products currently displayed on the inventory page
Get Inventory Product Count
    Wait Until Element Is Visible    xpath://div[@class='inventory_item']
    ${productcounter}=    Get Element Count    xpath://div[@class='inventory_item']
    RETURN    ${productcounter}


# This keyword Returns a random number of products to add, based on the total number of products
Generate Random Quantity
    [Arguments]    ${total_products}
    ${rdmquantity}=    Evaluate    random.randint(1, ${total_products})    random
    Set Test Variable    ${rdmquantity}
    RETURN    ${rdmquantity}

# This keyword Returns a list of unique random indexes for selecting products
Generate Random Indexes
    [Arguments]    ${total_products}    ${quantity}
    ${all_indexes}=     Evaluate                    list(range(1, ${total_products}+1))
    ${random_indexes}=  Evaluate                    random.sample(${all_indexes}, ${quantity})    random
    Set Test Variable    ${random_indexes}
    RETURN    ${random_indexes}


# This keyword Returns a random index for cart items
Generate Random Cart Index
    [Arguments]    ${total_in_cart}
    ${all_indexes}=    Evaluate    list(range(1, ${total_in_cart}+1))
    ${random_index}=   Evaluate    random.choice(${all_indexes})    random
    RETURN    ${random_index}


# This keyword Returns the total number of products currently in the cart
Get Cart Product Count
    Wait Until Element Is Visible                   xpath://*[@class='cart_list']//*[text()='Remove']
    ${cart_count}=      Get Element Count           xpath://*[@class='cart_list']//*[text()='Remove']
    RETURN    ${cart_count}


# This keyword Adds Random Product/s to Cart
Add Random Product to Cart
    ${productcounter}=  Get Inventory Product Count
    ${rdmquantity}=     Generate Random Quantity    ${productcounter}
    Set Test Variable   ${rdmquantity}
    ${random_indexes}=  Generate Random Indexes     ${productcounter}    ${rdmquantity}
    FOR  ${index}  IN  @{random_indexes}
        Click And Validate Product    ${index}
    END
    Validate Cart Badge


# Clicks the Add to Cart button for a specific product index and validates it in the cart
Click And Validate Product
    [Arguments]    ${index}
    ${add_btn}=      Set Variable                   xpath://*[@class='inventory_item'][${index}]//*[text()='Add to cart']
    ${productname}=  Get Text                       xpath://*[@class='inventory_item'][${index}]//*[@class='inventory_item_description']//*[@class='inventory_item_name ']
    Scroll Element Into View                        ${add_btn}
    Wait Until Element Is Visible                   ${add_btn}
    Click Element                                   ${add_btn}
    Open Cart
    Wait Until Element Is Visible                   xpath://*[@class='title' and text()='Your Cart']
    Element Should Be Visible                       xpath://*[@class='inventory_item_name' and text()='${productname}']
    Set Screenshot Directory                        ${SCREENSHOT_INVENTORY_DIR}
    Capture Page Screenshot                         Product-${productname}_Added_to_Cart.png
    Return to Shopping


# This keyword Removes Random Product/s from the Shopping Cart
Remove Random Product from Shopping Cart
    Open Cart
    ${cart_count}=      Get Cart Product Count
    ${random_index}=    Generate Random Cart Index  ${cart_count}
    Click And Validate Removal                      ${random_index}


# This keyword Removes ALL Product/s from the Shopping Cart safely
Remove All Products from Shopping Cart
    Open Cart
    ${cart_count}=    Get Cart Product Count
    IF  ${cart_count} > 0
        FOR  ${index}  IN RANGE  ${cart_count}
            Click And Validate Removal    1
            Open Cart
        END
    ELSE
        Log    Cart is already empty, nothing to remove
    END
    Validate Shopping Cart Default State


# This keyword Clicks the Remove button for a specific cart item index and validates removal
Click And Validate Removal
    [Arguments]    ${index}
    ${remove_btn}=      Set Variable                xpath://*[@class='cart_list']//*[@class='cart_item'][${index}]//*[text()='Remove']
    ${productname}=     Get Text                    xpath://*[@class='cart_list']//*[@class='cart_item'][${index}]//*[@class='inventory_item_name']
    Scroll Element Into View                        ${remove_btn}
    Wait Until Element Is Visible                   ${remove_btn}
    Click Element                                   ${remove_btn}
    # Validate removal in Cart
    Wait Until Element Is Visible                   xpath://*[@class='title' and text()='Your Cart']
    Element Should Not Be Visible                   xpath://*[@class='inventory_item_name' and text()='${productname}']
    # Reload and validate again
    Reload Page
    Wait Until Element Is Visible                   xpath://*[@class='title' and text()='Your Cart']
    Element Should Not Be Visible                   xpath://*[@class='inventory_item_name' and text()='${productname}']
    # Cross-check inventory page
    Return to Shopping
    Wait Until Element Is Visible                   xpath://*[@class='inventory_item' and .//div[text()='${productname}']]
    Element Should Be Visible                       xpath://*[@class='inventory_item' and .//div[text()='${productname}']]//button[text()='Add to cart']
    Capture Page Screenshot                         Product-${productname}_Removed_and_Inventory_Checked.png
    Set Test Message                                ${productname} was removed from the cart


# This keyword Removes Random Product/s from Inventory page and validates Shopping Cart
Remove Random Product from Shopping Page
    Wait Until Element Is Visible                   xpath://*[@class='inventory_item']
    # Count all products on the Inventory page
    ${total_products}=  Get Element Count           xpath://*[@class='inventory_item']
    # Lists to store products with Remove buttons
    @{products_with_remove}=  Create List
    @{remove_btns}=  Create List
    @{add_btns}=  Create List
    # Loop through all products to find which have Remove buttons
    FOR  ${index}  IN RANGE  1  ${total_products + 1}
        ${has_removebtn}=  Run Keyword And Return Status
        ...  Element Should Be Visible              xpath://*[@class='inventory_item'][${index}]//button[text()='Remove']
        IF  ${has_removebtn}
            # Store product name
            ${product_name}=  Get Text              xpath://*[@class='inventory_item'][${index}]//*[@class='inventory_item_name ']
            Append To List      ${products_with_remove}    ${product_name}
            # Store remove button xpath
            ${remove_btn}=  Set Variable            xpath://*[@class='inventory_item'][${index}]//*[text()='Remove']
            Append To List      ${remove_btns}      ${remove_btn}
            # Store add button xpath for later verification
            ${add_btn}=  Set Variable               xpath://*[@class='inventory_item'][${index}]//*[text()='Add to cart']
            Append To List      ${add_btns}         ${add_btn}
        END
    END
    # Randomly select one product from the stored variable to remove
    ${rand_index}=  Evaluate                        random.randint(0, len(${products_with_remove}) - 1)    random
    ${selected_product}=  Set Variable              ${products_with_remove}[${rand_index}]
    ${selected_remove_btn}=  Set Variable           ${remove_btns}[${rand_index}]
    ${selected_add_btn}=  Set Variable              ${add_btns}[${rand_index}]
    # Wait forthe Remove button to Appear then Select
    Wait Until Element Is Visible                   ${selected_remove_btn}
    Click Element                                   ${selected_remove_btn}
    # Validate that 'Add to cart' button reappears
    Wait Until Element Is Visible                   ${selected_add_btn}
    # Validate in cart that the selected product is removed
    Open Cart
    Wait Until Element Is Visible                   xpath://*[@class='title' and text()='Your Cart']
    Element Should Not Be Visible                   xpath://*[@class='inventory_item_name' and text()='${selected_product}']
    Set Test Message                                ${selected_product} was removed from the cart


# This keyword Validates Cart Quantity
Validate Cart Badge
    # Wait until Shopping Cart is Visible
    Wait Until Element Is Visible                   xpath://*[@class='shopping_cart_link']
    # Evalute if Shopping Cart has Product Counter or None
    ${cartstatus}=  Run Keyword And Return Status
    ...  Element Should Be Visible                  xpath://*[@class='shopping_cart_badge']
    IF  ${cartstatus} == True
        ${cartcounter}=  Get Text                   xpath://*[@class='shopping_cart_badge']
        Should Be Equal As Integers                 ${cartcounter}    ${rdmquantity}
    ELSE
        Validate Shopping Cart Default State
    END


# This keyword Asserts the Shopping Cart Quantity Elements
Validate Shopping Cart Default State
    Open Cart
    # Validate that Burger Menu button is available in Sopping Cart
    Wait Until Element Is Visible                   xpath://*[@class='bm-burger-button']
    # Validate Shopping Cart Title
    Element Should Be Visible                       xpath://*[@class='title' and text()='Your Cart']
    Element Text Should Be                          xpath://*[@class='title' and text()='Your Cart']    Your Cart
    # Validate Shopping Cart Quantity
    Element Should Be Visible                       xpath://*[@class='cart_quantity_label']
    Element Text Should Be                          xpath://*[@class='cart_quantity_label']    QTY
    # Validate Shopping Cart Description
    Element Should Be Visible                       xpath://*[@class='cart_desc_label']
    Element Text Should Be                          xpath://*[@class='cart_desc_label']     Description
    # Validate Continue Shopping button
    Element Should Be Visible                       xpath://*[@id='continue-shopping']
    Element Should Be Enabled                       xpath://*[@id='continue-shopping']
    Element Text Should Be                          xpath://*[@id='continue-shopping']      Continue Shopping
    # Validate Checkout button
    Element Should Be Visible                       xpath://*[@id='checkout']
    # As per website UI, button is not disabled even when there is no product
    Element Should Be Enabled                       xpath://*[@id='checkout']
    Element Text Should Be                          xpath://*[@id='checkout']   Checkout