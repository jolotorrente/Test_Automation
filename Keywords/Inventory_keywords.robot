*** Settings ***
Library         PuppeteerLibrary
Library         String
Library         Collections

### Resource List of Variables ###
Resource        ../Variables/Login_variables.robot
Resource        ../Variables/Inventory_variables.robot


*** Keywords ***
######################################
## Keywords for Product Interaction ##
######################################

#This keyword is used to Assert Login Page Elements
Validate Inventory Page Elements
    #Assertions for Existence of Inventory Page Elements
    #App Logo
    Set Screenshot Directory                        ${SCREENSHOT_BASE_DIR}
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


#This keyword is used to Assert Elements on Product View
Validate Element Per Product
    ${productcount} =  Get Element Count            xpath://*[@class='inventory_item']//*[@class='inventory_item_name ']
    FOR    ${i}    IN RANGE    ${productcount}
        ${index} =  Evaluate  ${i} + 1
        Element Should Be Visible                   xpath://*[@class='inventory_item'][${index}]//*[@class='inventory_item_img']
        ${productname} =  Get Text                  xpath://*[@class='inventory_item'][${index}]//*[@class='inventory_item_description']//*[@class='inventory_item_name ']
        Click Element                               xpath://*[@class='inventory_item'][${index}]//*[@class='inventory_item_img']
        Wait Until Element Is Visible               xpath://*[@id='back-to-products']
        Element Should Be Visible                   xpath://*[@class='inventory_details_img_container']

        Capture Page Screenshot                     Listed-Product-${index}.png
        Click Element                               xpath://*[@id='back-to-products']
    END


#This keyword is used to Add Random Products with Random Quantity to Cart
Add Product to Cart
    #Count the total Products in the Current Page
    ${productcounter} =  Get Element Count          xpath://div[@class='inventory_item']
    #Generate a random number how many products to add
    ${productquantity} =  Evaluate    random.randint(1, ${productcounter})    random
    # Generate a list of unique random indexes
    ${all_indexes} =  Evaluate    list(range(1, ${productcounter}+1))    # list of all indices
    ${random_indexes} =  Evaluate    random.sample(${all_indexes}, ${productquantity})    random
    #Loop through each unique random indexes
    FOR    ${index}    IN    @{random_indexes}
        # Build Add to cart button XPath
        ${add_btn} =  Set Variable                  xpath://*[@class='inventory_item'][${index}]//*[text()='Add to cart']
        # Get product name relative to the button
        ${productname} =  Get Text                  xpath://*[@class='inventory_item'][${index}]//*[@class='inventory_item_description']//*[@class='inventory_item_name ']
        # Scroll until Add Button is Visible on the active screen
        Scroll Element Into View                    ${add_btn}
        Wait Until Element Is Visible               ${add_btn}
        Click Element                               ${add_btn}
        Sleep    0.5s
        # Validate in Cart that Product was added
        Open Cart
        Sleep  0.5s
        Wait Until Element Is Visible               xpath://*[@class='title' and text()='Your Cart']
        Element Should Be Visible                   xpath://*[@class='inventory_item_name' and text()='${productname}']
        Capture Page Screenshot                     Product-${productname}_Added to Cart.png
        Return to Shopping
    END
    #Validate Final cart badge
    Wait Until Element Is Visible                   xpath://span[@class='shopping_cart_badge']
    ${cartcounter}=    Get Text                     xpath://span[@class='shopping_cart_badge']
    Should Be Equal As Integers                     ${cartcounter}    ${productquantity}


#This keyword is used to Remove a Current Item in the Cart from the Shopping Page
Remove Product from Shopping Page
    ${removebtncounter} =  Get Element Count        xpath://div[@class='inventory_item']
    #Generate a random number on which product to remove
    ${randomizer} =  Evaluate    random.randint(1, ${removebtncounter})    random
    Wait Until Element Is Visible               xpath://*[@class='inventory_item'][${randomizer}]//*[text()='Remove']
    # Build Remove to cart button XPath
    ${remove_btn} =  Set Variable               xpath://*[@class='inventory_item'][${randomizer}]//*[text()='Remove']
    # Get product name relative to the button
    ${productname} =  Get Text                  xpath://*[@class='inventory_item'][${randomizer}]//*[@class='inventory_item_description']//*[@class='inventory_item_name ']
    # Scroll until Add Button is Visible on the active screen
    Wait Until Element Is Visible               ${remove_btn}
    Click Element                               ${remove_btn}
    Sleep    0.5s
    # Validate in Cart the Product was Removed
    Open Cart
    Sleep  0.5s
    Wait Until Element Is Visible               xpath://*[@class='title' and text()='Your Cart']
    Element Should Not Be Visible               xpath://*[@class='inventory_item_name' and text()='${productname}']
    Sleep    0.5s
    Capture Page Screenshot                     Product-${productname}_Removed to Cart.png
    Return to Shopping


#This keyword is used to Remove a Current Item in the Cart from the Shopping Cart
Remove Product from Shopping Cart
    # Get product name relative to the button
    Open Cart
    ${removebtncounter} =  Get Element Count    xpath://div[@class='inventory_item']
    #Generate a random number on which product to remove
    ${randomizer} =  Evaluate    random.randint(1, ${removebtncounter})    random
    Wait Until Element Is Visible               xpath://*[@class='inventory_item'][${randomizer}]//*[text()='Remove']
    # Build Remove to cart button XPath
    ${remove_btn} =  Set Variable               xpath://*[@class='inventory_item'][${randomizer}]//*[text()='Remove']
    ${productname} =  Get Text                  xpath://*[@class='cart_item'][${randomizer}]//*[@class='inventory_item_name']
    # Scroll until Add Button is Visible on the active screen
    Wait Until Element Is Visible               ${remove_btn}
    Click Element                               ${remove_btn}
    Sleep    0.5s
    # Validate in Cart the Product was Removed
    Sleep  0.5s
    Wait Until Element Is Visible               xpath://*[@class='title' and text()='Your Cart']
    Element Should Not Be Visible               xpath://*[@class='inventory_item_name' and text()='${productname}']
    Sleep    0.5s
    Capture Page Screenshot                     Product-${productname}_Removed to Cart.png
    Return to Shopping


#This keyword is used to return from Shopping Cart to Shopping page
Return to Shopping
    Click Element                                   xpath://*[@id='continue-shopping']


#This keyword is used to display Shopping Cart
Open Cart
    Wait Until Element Is Visible                   xpath://*[@id='shopping_cart_container']
    Click Element                                   xpath://*[@id='shopping_cart_container']
    Wait Until Element Is Visible                   xpath://*[@class='title' and text()='Your Cart']