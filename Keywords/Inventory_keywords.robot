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
    Set Test Variable       ${productquantity}
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
    Validate Final Cart Badge



Validate Final Cart Badge
    Wait Until Element Is Visible                   xpath://span[@class='shopping_cart_badge']
    ${cartcounter} =        Get Text                xpath://span[@class='shopping_cart_badge']
    Should Be Equal As Integers                     ${cartcounter}    ${productquantity}


# This keyword Removes a random Product from the Shopping Cart
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
    Return to Shopping
    Wait Until Element Is Visible                   xpath://*[@class='inventory_item' and .//div[text()='${productname}']]
    Element Should Be Visible                       xpath://*[@class='inventory_item' and .//div[text()='${productname}']]//button[text()='Add to cart']
    Capture Page Screenshot                         Product-${productname}_Removed_and_Inventory_Checked.png
    Set Test Message                                ${productname} was removed from the cart


# This keyword Removes a random product from Inventory page and validates Shopping Cart
Remove Product from Shopping Page
    Wait Until Element Is Visible                   xpath://*[@class='inventory_item']
    # Count all products on the Inventory page
    ${total_products} =         Get Element Count   xpath://*[@class='inventory_item']
    # Lists to store products with Remove buttons
    @{products_with_remove} =   Create List
    @{remove_btns} =            Create List
    @{add_btns} =               Create List
    # Loop through all products to find which have Remove buttons
    FOR    ${index}    IN RANGE    1    ${total_products + 1}
        ${has_removebtn} =      Run Keyword And Return Status
        ...    Element Should Be Visible            xpath://*[@class='inventory_item'][${index}]//button[text()='Remove']
        IF    ${has_removebtn}
            # Store product name
            ${product_name} =   Get Text            xpath://*[@class='inventory_item'][${index}]//*[@class='inventory_item_name ']
            Append To List      ${products_with_remove}    ${product_name}
            # Store remove button xpath
            ${remove_btn} =     Set Variable        xpath://*[@class='inventory_item'][${index}]//*[text()='Remove']
            Append To List      ${remove_btns}      ${remove_btn}
            # Store add button xpath for later verification
            ${add_btn} =        Set Variable        xpath://*[@class='inventory_item'][${index}]//*[text()='Add to cart']
            Append To List      ${add_btns}         ${add_btn}
        END
    END
    # Randomly select one product from the stored variable to remove
    ${rand_index} =             Evaluate            random.randint(0, len(${products_with_remove}) - 1)    random
    ${selected_product} =       Set Variable        ${products_with_remove}[${rand_index}]
    ${selected_remove_btn} =    Set Variable        ${remove_btns}[${rand_index}]
    ${selected_add_btn} =       Set Variable        ${add_btns}[${rand_index}]
    # Wait forthe Remove button to Appear then Select
    Wait Until Element Is Visible                   ${selected_remove_btn}
    Click Element                                   ${selected_remove_btn}
    # Validate that 'Add to cart' button reappears
    Wait Until Element Is Visible                   ${selected_add_btn}
    # Validate in cart that the selected product is removed
    Open Cart
    Wait Until Element Is Visible                   xpath://*[@class='title' and text()='Your Cart']
    Element Should Not Be Visible                   xpath://div[@class='inventory_item_name' and text()='${selected_product}']
    Set Test Message                                ${selected_product} was removed from the cart
