from mysql.connector import connect, Error
import mysql.connector
from getpass import getpass
import pandas as pd
from reportlab.pdfgen import canvas
import matplotlib.pyplot as plt

remote_dba = 'test'
remote_dba_pass = 'my_password'

def connect_db(username, password):
    '''
    PARAMETERS
    username: String
        The user's username that will be used to connect to the database
    password: String
        The user's password that will be used to connect to the databse.
    RETURNS
    conn: mysql.connector
        Establishes a connection to the restaurant database
    
    Establishes a connection to the database and if access is permitted,
    provides user with access to the database.
    '''
    try:
        conn = connect(
            host='localhost',
            user=username,
            password=password,
            database='restaurant'
        )
    except Error as e:
        print(e)
    return conn

#----------------------- Manager -----------------------------
def generate_sales_report(conn):
    '''
    PARAMETERS
    conn: mysql.connector
        Establishes a connection to the restaurant database
    RETURNS
    None.
    
    Downloads a report of the total sales for each week to the maanger's 
    device. Provides insights on weeks that the restaurant did well and weeks
    that the restaurant didnt.
    '''
    get_sales_query = '''
    SELECT * FROM weekly_sales ORDER BY week_start_date;
    '''
    weeks = []
    sales = []
    with conn.cursor() as cursor:
        cursor.execute(get_sales_query)
        results = cursor.fetchall()
        for r in results:
            weeks.append(r[0])
            sales.append(float(r[1]))
    report = canvas.Canvas("weekly_sales_report.pdf")
    
    report.setFont("Helvetica-Bold", 16)
    report.drawString(50, 750, "Weekly Sales Report")
    
    report.setFont("Helvetica", 12)
    y = 700
    for i in range(len(weeks)):
        report.drawString(50, y, f'Week Start Date: {weeks[i]}')
        report.drawString(50, y - 30, f'Total Sales: {sales[i]}')
        y -=60
    
    report.save()
    
    plt.plot(weeks, sales)
    plt.title("Sales By Week")
    plt.xlabel("Week Start Date")
    plt.ylabel("Sales ($)")
    plt.xticks(rotation = 45)
    plt.savefig("sales_report_graph.png")
    plt.show()
    
def popular_menu_items_report(conn):
    '''
    PARAMETERS
    conn: mysql.connector
        Establishes a connection to the restaurant database
    RETURNS
    None.
    
    Downloads a report of the most popular items in the menu. Provides insight
    to the manager on which menu items are selling well and which ones are not.
    '''
    get_popular_menu_items_query = '''
    SELECT mi.item_name, COUNT(iio.item_id) as times_ordered
    FROM menu_item as mi
    RIGHT JOIN item_in_order as iio
    ON mi.item_id = iio.item_id
    GROUP BY iio.item_id
    ORDER BY times_ordered DESC;
    '''
    items = []
    times_ordered = []
    with conn.cursor() as cursor:
        cursor.execute(get_popular_menu_items_query)
        results = cursor.fetchall()
        for r in results:
            items.append(r[0])
            times_ordered.append(r[1])
    plt.bar(x = items, height = times_ordered)
    plt.title("Most commonly ordered menu items")
    plt.xlabel("Item Name")
    plt.ylabel("Times ordered") 
    plt.xticks(rotation = 90)
    plt.show()
    plt.savefig("popular_items_graph.png")
    
def order_counts_graph(conn):
    '''
    PARAMETERS
    conn: mysql.connector
        Establishes a connection to the restaurant database
    RETURNS
    None.
    
    Downlaods a report of the total number of orders placed each day. Provides
    managers insight on which days of the week are most popular times to order.
    '''
    get_order_counts_query= '''
    SELECT DATE(order_date), COUNT(*) as num_orders
    FROM cust_order
    GROUP BY DATE(order_date)
    ORDER BY DATE(order_date);
    '''
    dates = []
    counts = []
    with conn.cursor() as cursor:
        cursor.execute(get_order_counts_query)
        results = cursor.fetchall()
        for r in results:
            dates.append(r[0])
            counts.append(r[1])
    plt.plot(dates, counts)
    plt.title("Number of Orders Per Date")
    plt.xlabel("Date")
    plt.ylabel("Number of Orders Placed")
    plt.xticks(rotation = 90)
    plt.savefig("order_counts.png")
    plt.show()
    

def manager_interface(conn, user_id):
    while True:
        print("What would you like to do?")
        print("[1] Add a new employee")
        print("[2] View/Update the menu")
        print("[3] View/Update inventory")
        print("[4] View reservations")
        print('[5] Download reports')
        print("[6] Exit")
        
        choice = input("Enter your choice: ")

        if choice == '1':
            # Option to add a new employee
            add_new_employee(conn)
        elif choice == '2':
            # Option to view/update the menu
            view_update_menu(conn)
        elif choice == '3':
            # Option to view/update inventory
            view_update_inventory(conn)
        elif choice == '4':
            # Option to view reservations
            view_reservations(conn)
        elif choice == '5':
            generate_sales_report(conn)
            popular_menu_items_report(conn)
            order_counts_graph(conn)
            print("Sales report successfully downloaded")
        elif choice == '6':
            # Exit the interface
            print("Exiting manager interface.")
            break
        else:
            print("Invalid choice. Please enter a valid option.")
            
def grant_permissions(username, role, password, specific):
    '''
    PARAMETERS:
        conn: mysql connector
            Connects the program to the database
        username: String
            The username by which the new user is identified
        role : String
            One of Manager, Chef, or Customer
            Represents the role of the new user
        password: String
            The password that identifies the new user
        specific: String
            In the case that the user is a manager, represents department.
            In the case that the user is a chef, represents specialty.
    RETURNS:
        None
    
    Upon creation of a new user, creates the new user in the database and 
    grants role-specific permissions upon the new user.
    '''
    conn = connect_db(remote_dba, remote_dba_pass)
    if role == "Customer":
        with conn.cursor() as cursor:
            cursor.callproc('AddUserWithRole', (f'{username}', f'{password}', "Customer",))
            conn.commit()
        find_new_customer_id = '''
        SELECT user_id FROM user
        WHERE user_name = %s; 
        '''
        with conn.cursor() as cursor:
            cursor.execute(find_new_customer_id, (username,))
            results = cursor.fetchone()
            current_id = results[0]
        insert_customer_query = f'''
        INSERT INTO customer (customer_id)
        VALUES ({current_id});
        '''
        grant_user_privs = f'''
        GRANT SELECT, INSERT, UPDATE ON restaurant.user TO {username}@'localhost';
        '''
        grant_res_privs = f'''
        GRANT SELECT, INSERT, UPDATE, DELETE ON restaurant.reservation 
        TO {username}@'localhost';
        '''
        grant_menu_item_privs = f'''
        GRANT SELECT, INSERT, UPDATE ON restaurant.menu_item 
        TO {username}@'localhost';
        '''
        grant_cust_order_privs = f'''
        GRANT SELECT, INSERT, UPDATE ON restaurant.cust_order
        TO {username}@'localhost';
        '''
        grant_item_in_order_privs = f'''
        GRANT SELECT, INSERT, UPDATE ON restaurant.item_in_order 
        TO {username}@'localhost';
        '''
        all_queries = [insert_customer_query, grant_user_privs,
                       grant_res_privs, grant_menu_item_privs, 
                       grant_cust_order_privs, grant_item_in_order_privs]
        with conn.cursor() as cursor:
            for query in all_queries:
                cursor.execute(query)
                conn.commit()
        customer_interface(conn, current_id)
    if role == "Manager":
        with conn.cursor() as cursor:
            cursor.callproc('AddUserWithRole', (f'{username}', f'{password}', "Manager",))
            conn.commit()
        find_new_manager_id = '''
        SELECT user_id FROM user
        WHERE user_name = %s; 
        '''
        with conn.cursor() as cursor:
            cursor.execute(find_new_manager_id, (username,))
            results = cursor.fetchone()
            current_id = results[0]
        insert_manager_query = '''
        INSERT INTO manager (manager_id, dept_name)
        VALUES (%s, %s);
        '''
        grant_manager_privs = f'''
        GRANT SELECT, INSERT, UPDATE, DELETE ON restaurant.* TO {username}@'localhost';
        '''
        all_queries = [insert_manager_query, grant_manager_privs]
        with conn.cursor() as cursor:
            for query in all_queries:
                cursor.execute(query, (current_id, specific,))
                conn.commit()
    if role == "Chef":
        with conn.cursor() as cursor:
            cursor.callproc("AddUserWithRole",(f'{username}', f'{password}', "Chef",))
            conn.commit()
        find_new_chef_id = '''
        SELECT user_id FROM user
        WHERE user_name = %s;
        '''
        with conn.cursor() as cursor:
            cursor.execute(find_new_chef_id, (username,))
            results = cursor.fetchone()
            current_id = results[0]
        insert_chef_query = '''
        INSERT INTO chef (chef_id, specialization)
        VALUES (%s, %s);
        '''
        with conn.cursor() as cursor:
            cursor.execute(insert_chef_query, (current_id, specific,))
        grant_user_privs = f'''
        GRANT SELECT on restaurant.user TO {username}@'localhost';
        '''
        grant_inventory_privs = f'''
        GRANT SELECT, INSERT, UPDATE ON restaurant.inventory_item 
        TO {username}@'localhost';
        '''
        grant_order_privs = f'''
        GRANT SELECT, INSERT, UPDATE ON restaurant.cust_order 
        TO {username}@'localhost';
        '''
        all_queries = [grant_user_privs, grant_inventory_privs, grant_order_privs]
  
        with conn.cursor() as cursor:
            for query in all_queries:
                cursor.execute(query)
                conn.commit()
    
    
def add_new_employee(conn):
    print("Adding a new employee...")

    # Prompt user for employee details
    name = input("Enter employee username: ")
    user_password = input("Enter employee password: ")
    user_role = input("Enter employee role: ")
    if user_role == "Chef":
        specific = input("Enter chef specialty: ")
    if user_role == "Manager":
        specific = input("Enter manager department: ")
    grant_permissions(name, user_role, user_password, specific)


def view_update_menu(conn):
    print("Viewing/Updating the menu...")

    # Create a cursor
    cursor = conn.cursor()

    try:
        # Fetch and display the current menu
        menu_query = "SELECT * FROM menu_item"
        cursor.execute(menu_query)
        menu_data = cursor.fetchall()

        # Display the menu using pandas DataFrame
        if menu_data:
            columns = [desc[0] for desc in cursor.description]
            df = pd.DataFrame(menu_data, columns=columns)
            print(df)
        else:
            print("The menu is currently empty.")

        # Allow the manager to update the menu
        update_option = input("Do you want to update the menu? (yes/no): ").lower()
        if update_option == 'yes':
            item_name = input("Enter the name of the item to update: ")
            new_price = input("Enter the new price for the item: ")

            # Update the price of the specified item
            update_query = f"UPDATE menu_item SET price = {new_price} WHERE item_name = '{item_name}'"
            cursor.execute(update_query)
            conn.commit()

            print("Menu updated successfully.")
        else:
            print("Menu not updated.")

    except mysql.connector.Error as e:
        # Handle exceptions, e.g., print the error
        print(f"Error: {e}")
    finally:
        # Close the cursor
        cursor.close()


def view_update_inventory(conn):
    print("Viewing/Updating inventory...")

    # Create a cursor
    cursor = conn.cursor()

    try:
        # Fetch and display the current inventory
        inventory_query = "SELECT * FROM inventory_item"
        cursor.execute(inventory_query)
        inventory_data = cursor.fetchall()

        # Display the inventory using pandas DataFrame
        if inventory_data:
            columns = [desc[0] for desc in cursor.description]
            df = pd.DataFrame(inventory_data, columns=columns)
            print(df)
        else:
            print("The inventory is currently empty.")

        # Allow the manager to update the inventory
        update_option = input("Do you want to update the inventory? (yes/no): ").lower()
        if update_option == 'yes':
            item_name = input("Enter the name of the item to update: ")
            new_quantity = input("Enter the new quantity for the item: ")

            # Update the quantity of the specified item
            update_query = f"UPDATE inventory_item SET stock_quantity = {new_quantity} WHERE item_name = '{item_name}'"
            cursor.execute(update_query)
            conn.commit()

            print("Inventory updated successfully.")
        else:
            print("Inventory not updated.")

    except mysql.connector.Error as e:
        # Handle exceptions, e.g., print the error
        print(f"Error: {e}")
    finally:
        # Close the cursor
        cursor.close()

def view_reservations(conn):
    reservations_query = "SELECT * FROM reservation"
    df_reservations = pd.read_sql(reservations_query, conn)
    
    print("\nCurrent Reservations:")
    print(df_reservations)

#------------------- Chef -----------------------------------
    
def chef_interface(conn, user_id):
    while True:
        print("What would you like to do?")
        print("[1] View orders")
        print("[2] Update order status")
        print("[3] Check inventory")
        print("[4] Exit")
        
        choice = input("Enter your choice: ")

        if choice == '1':
            # Option to view orders
            view_orders(conn)
        elif choice == '2':
            # Option to update order status
            update_order_status(conn)
        elif choice == '3':
            # Option to check inventory
            view_update_inventory(conn)
        elif choice == '4':
            # Exit the interface
            print("Exiting chef interface.")
            break
        else:
            print("Invalid choice. Please enter a valid option.")

   
def view_orders(conn):
    print("Viewing orders...")

    cursor = conn.cursor()

    try:
        orders_query = "SELECT * FROM cust_order"
        cursor.execute(orders_query)
        orders_data = cursor.fetchall()

        if orders_data:
            columns = [desc[0] for desc in cursor.description]
            df = pd.DataFrame(orders_data, columns=columns)
            print(df)
        else:
            print("There are currently no orders.")
    except mysql.connector.Error as e:
        print(f"Error: {e}")
    finally:
        cursor.close()

def update_order_status(conn):
    print("Updating order status...")

    order_id = input("Enter the ID of the order to update: ")
    new_status = input("Enter the new status for the order: ")

    cursor = conn.cursor()

    try:
        update_query = f"UPDATE cust_order SET status = '{new_status}' WHERE order_id = {order_id}"
        cursor.execute(update_query)
        conn.commit()

        print("Order status updated successfully.")
    except mysql.connector.Error as e:
        print(f"Error: {e}")
    finally:
        cursor.close()


#--------------------- Customer -----------------------------
def make_reservation(conn, user_id):
    '''

    Parameters
    ----------
    conn : sql connector
        Point of connection to the restaurant database in SQL
    user_id : int
        The user_id of the currently logged-in user.

    Returns
    -------
    None.
    
    Allows user to make a reservation and commits the new reservation to the 
    sql database.

    '''
    date = input("What date would you like to make a reservation for? ")
    num_guests = input("For how many? ")
    time = input("At what time? ")
    requests_choice = input("Any requests? [y/n] ")
    if requests_choice == 'y':
        requests = input("Enter requests here: ")
        add_reservation_query = """
        INSERT INTO reservation(date, time, num_guests, status, requests, customer_id)
        VALUES (%s, %s, %s, %s, %s, %s)
        """
        reservation_tuple = (date, time, num_guests, "Reserved", requests, user_id,)
    else:
        add_reservation_query = """
        INSERT INTO reservation(date, time, num_guests, status, customer_id)
        VALUES (%s, %s, %s, %s, %s)
        """
        reservation_tuple = (date, time, num_guests, "Reserved", user_id,)
    with conn.cursor() as cursor:
        cursor.execute(add_reservation_query, reservation_tuple)
        conn.commit()

def modify_reservation(conn, user_id):
    '''

    Parameters
    ----------
    conn : sql connector
        Point of connection to the restaurant database in SQL
    user_id : int
        The user_id of the currently logged-in user.

    Returns
    -------
    None.
    
    Allows user to modify a reservation and commits the updates to the 
    sql database.
    '''
    print()
    current_reservations_query = f'''
    SELECT res_id, date, time, num_guests
    FROM reservation
    WHERE customer_id = {user_id}
    AND DATEDIFF(date, NOW()) > 0
    ORDER BY date;
    '''
    with conn.cursor() as cursor:
        cursor.execute(current_reservations_query)
        reservs = cursor.fetchall()
        ids = []
        dates = []
        times = []
        num_guests = []
        for r in reservs:
            ids.append(r[0])
            dates.append(r[1])
            times.append(str(r[2]).replace("0 days", ''))
            num_guests.append(r[3])
        reservations_df = pd.DataFrame({
            "ID" : ids,
            "Date" : dates, 
            "Time" : times, 
            'Number of Guests' : num_guests})
    print("Your active reservations:")
    print(reservations_df[['Date', "Time", "Number of Guests"]])
    print("Which reservation would you like to edit?" )
    for i in range(len(reservations_df)):
        print(f'[{i + 1}] {reservations_df["Date"].iloc[i]}')
    modify_res = int(input())
    res_id_to_modify = reservations_df['ID'].iloc[modify_res - 1]
    print("What would you like to do?")
    print("[1] Cancel the reservation")
    print("[2] Change the date/time")
    print('[3] Change the number of guests')
    print("[4] Go back")
    action = input()
    if action == '1':
        confirmation = input("Are you sure you want to cancel? [y/n] ")
        if confirmation == 'y':
            print("Reservation cancelled")
            delete_reservation_query = f'''
            DELETE FROM reservation 
            WHERE res_id = {res_id_to_modify};
            '''
            with conn.cursor() as cursor:
                cursor.execute(delete_reservation_query)
                conn.commit()
        else: 
            customer_interface(conn, user_id)
    if action == '2':
        new_date = input("What date would you like to change it to? ")
        new_time = input("What time would you like to change it to? ")
        update_res_query_date = f'''
        UPDATE reservation
        SET date = {new_date}
        WHERE res_id = {res_id_to_modify};
        '''
        update_res_query_time = f'''
        UPDATE reservation
        SET time = {new_time}
        WHERE res_id = {res_id_to_modify};
        '''
        with conn.cursor() as cursor:
            cursor.execute(update_res_query_date)
            conn.commit()
            cursor.execute(update_res_query_time)
            conn.commit()
    if action == '3':
        new_guests = input("How many guests would you like to change the reservation to? ")
        update_guests_query = f'''
        UPDATE reservation
        SET num_guests = {new_guests}
        WHERE res_id = {res_id_to_modify};
        '''
        with conn.cursor() as cursor:
            cursor.execute(update_guests_query)
            conn.commit()
    if action == '4':
        customer_interface(conn, user_id)

def get_menu_df(conn):
    menu_item_query = '''
    SELECT item_id, item_name, price, description
    FROM menu_item
    '''
    with conn.cursor() as cursor:
        cursor.execute(menu_item_query)
        menu = cursor.fetchall()
        ids = []
        names = []
        prices = []
        descriptions = []
        for item in menu:
            ids.append(item[0])
            names.append(item[1])
            prices.append(item[2])
            descriptions.append(item[3])
        menu_df = pd.DataFrame({
            'ID': ids, 
            'Item' : names, 
            'Price': prices, 
            'Description': descriptions})
    return menu_df

def end_dialog():
    print("What would you like to do?")
    print("[1] Home")
    print("[2] Log Out")
    choice = input()
    return choice

def show_menu(menu_df):
    print("Select an item to see more details")
    print(menu_df[['Item']])
    item_no = int(input())
    return item_no

def calculate_order_total(cart_df):
    '''
    Parameters
    ----------
    cart_df: DataFrame
        A dataframe representing the items in a user's cart
    Returns
    -------
    Sum of all the prices in the dataframe.
    Represents the total of the users order.
    
    Calculates the sum of all the prices of the items in the users cart
    '''
    prices = list(cart_df['Price'])
    return sum(prices)
    
   
def view_cart(cart, menu_df):
    '''

     Parameters
     ----------
     cart : dict
         A dictionary representing a particular order's cart. Keys are item ids
         and values are quantity of that item id.
     menu_df: DataFrame:
         A dataframe storing information about an item's ID, name, price, and 
         description
     Returns
     -------
     None.
     
     Allows users to view their cart
     '''
    print("Your cart")
    item_names = []
    item_qtys = []
    item_prices = []
    for id_, qty in cart.items():
        row = menu_df.loc[menu_df["ID"] == id_]
        item_names.append(row['Item'].values[0])
        item_qtys.append(qty)
        item_price = qty * row['Price'].values[0]
        item_prices.append(item_price)
    cart_df = pd.DataFrame({
        "Item" : item_names, 
        "Quantity": item_qtys, 
        "Price" : item_prices})
    print(cart_df.to_string(index = False, index_names = False))
    total = calculate_order_total(cart_df)
    print(f'Your total is: ${total}')

def commit_new_order(cart, conn, user_id):
    '''

    Parameters
    ----------
    cart : dict
        Represents the users cart. Keys are item_ids and values are quantities.
    conn : mysql connector
        Point of connection to the restaurant database in mysql
    user_id : int
        The id of the user placing the orde.

    Returns
    -------
    None.
    
    Commits the new order to the sql database

    '''
    add_order_query = '''
    INSERT INTO cust_order (status, customer_id)
    VALUES (%s, %s)
    '''
    cust_info_tuple = ("Received", user_id)
    with conn.cursor() as cursor:
        cursor.execute(add_order_query, cust_info_tuple)
        conn.commit()
        current_order_id = cursor.lastrowid
    add_item_query = '''
    INSERT INTO item_in_order (item_id, order_id, quantity)
    VALUES (%s, %s, %s)
    '''
    for item, qty in cart.items():
        insert_item_tuple = (int(item), int(current_order_id), int(qty))
        with conn.cursor() as cursor:
            cursor.execute(add_item_query, insert_item_tuple)
            conn.commit()
        
    
def place_order(conn, user_id):
    menu_df = get_menu_df(conn)
    cart = {}
    while True:
        print("[1] View menu")
        print("[2] View cart")
        print('[3] Checkout')
        choice = input()
        if choice == '1':
            item_no = show_menu(menu_df)
            current_item = menu_df[["Item", "Price", "Description"]].iloc[item_no]
            item_id = menu_df['ID'].iloc[item_no]
            print(current_item)
            print('[1] Add item to cart')
            print("[2] Go back to menu")
            selection = input()
            if selection == '1':
                quantity = int(input("Quantity: "))
                cart[item_id] = quantity
                print("Item added to cart")
        if choice == '2':
            view_cart(cart, menu_df)
        if choice == '3':
            view_cart(cart, menu_df)
            confirm = input("Are you sure you want to check out? [y/n] ")
            if confirm == 'y':
                print("Order placed")
                commit_new_order(cart, conn, user_id)
                break
        

def view_order_status(conn, user_id):
    '''
    Parameters
    ----------
    conn : mysql connector
        Point of connection to the restaurant database in mysql
    user_id : int
        user id of the user query the order status

    Returns
    -------
    None.
    
    Shows user the order status of their active orders
    '''
    print()
    print("Your active orders:")
    show_active_orders_query = f'''
    SELECT order_id, status FROM cust_order
    WHERE customer_id = {user_id}
    AND status = "Received"
    OR status = "Preparing";
    '''    
    order_ids = []
    order_statuses = []
    with conn.cursor() as cursor:
        cursor.execute(show_active_orders_query)
        orders = cursor.fetchall()
        for o in orders:
            order_ids.append(o[0])
            order_statuses.append(o[1])
    orders_df = pd.DataFrame({
        'Order ID' : order_ids, 
        "Status" : order_statuses})
    print(orders_df)

def view_order_details(conn, order_id):
    '''
    Parameters
    ----------
    conn: mysql connector
        Point of connection to restaurant database
    order_id: int
        ID of order to be queried

    Returns
    -------
    None.
    
    Displays the details of this order, including date and time placed, items 
    in order. 
    '''
    menu_df = get_menu_df(conn)
    find_order_items_query = f'''
    SELECT item_id, quantity 
    FROM item_in_order
    WHERE order_id = {order_id};
    '''
    cart = {}
    with conn.cursor() as cursor:
        cursor.execute(find_order_items_query)
        items = cursor.fetchall()
        for item in items:
            cart[item[0]] = item[1]
    view_cart(cart, menu_df)

def view_past_orders(conn, user_id):
    '''
    Parameters
    ----------
    conn: mysql connector
        Point of connection to restaurant database
    user_id: int
        ID of user querying database

    Returns
    -------
    None.
    
    Allows user to see past orders and items in the order.
    '''
    print()
    print("Your past orders")
    print("   Order ID     Date")
    view_past_orders_query = f'''
    SELECT order_id, DATE(order_date) FROM cust_order
    WHERE customer_id = {user_id}
    AND status = "Complete";
    '''
    order_ids = []
    dates = []
    with conn.cursor() as cursor:
        cursor.execute(view_past_orders_query)
        orders = cursor.fetchall()
        for o in orders:
            order_ids.append(o[0])
            dates.append(o[1])
    for i in range(len(order_ids)):
        print(f"[{i + 1}] {order_ids[i]}     {dates[i]}")
    order = int(input("Select an order: "))
    current_order_id = order_ids[order - 1]
    view_order_details(conn, current_order_id)
    
    
def customer_interface(conn, user_id):
    while True:
        print("What would you like to do?")
        print("[1] Make a reservation")
        print("[2] Modify an existing reservation")
        print('[3] Place an Order')
        print('[4] View Order Status')
        print("[5] View Your Past Orders")
        print('[6] Exit')
        choice = input()
        if choice == '1':
            make_reservation(conn, user_id)
            end_choice = end_dialog()
            if end_choice =='2':
                print("Have a good day!")
                break
            
        if choice == '2':
            modify_reservation(conn, user_id)
            end_choice = end_dialog()
            if end_choice == '2':
                print("Have a good day!")
                break
            
        if choice == '3':
            place_order(conn, user_id)
            end_choice = end_dialog()
            if end_choice == '2':
                print("Have a good day!")
                break
        
        if choice == '4':
            view_order_status(conn, user_id)
            end_choice = end_dialog()
            if end_choice == '2':
                print("Have a good day!")
                break
            
        if choice == '5':
            view_past_orders(conn, user_id)
            end_choice = end_dialog()
            if end_choice == '2':
                print("Have a good day!")
                break
        if choice == '6':
            print("Have a nice day!")
            break
        
        
        
def add_new_customer(username, password):
    '''
    

    Parameters
    ----------
    conn : sql connector
        Established connection to the restaurant database.

    Returns
    -------
    None.
    
    Adds new customers to the database
    '''
    print()
    existing_users_query = '''
    SELECT user_name FROM user
    '''
    existing_usernames = []
    conn = connect_db(username, password)
    with conn.cursor() as cursor:
        cursor.execute(existing_users_query)
        results = cursor.fetchall()
        for r in results:
            existing_usernames.append(r[0])
    while True:
        desired_username = input("Enter username: ")
        if desired_username in existing_usernames:
            print("Username already taken")
        else:
            break
    while True:
        password1 = getpass("Enter password: ")
        password2 = getpass("Confirm password: ")
        if password1 != password2:
            print("Passwords must match")
        else:
            break
    grant_permissions(desired_username, "Customer", password1, "")
       
    
    
def main():
    print()
    print("Welcome to our restaurant!")
    print()
    print("[1] Login")
    print('[2] Sign Up')
    choice = input()
    if choice == '1':
        print()
        username = input("Enter username: ")
        password = getpass("Enter password: ")
        
        conn = connect_db(username, password)
        
        role_query = 'SELECT role FROM user WHERE user_name = %s'
        id_query = 'SELECT user_id FROM user WHERE user_name = %s'
        val_tuple = (username,)
        with conn.cursor() as cursor:
            cursor.execute(role_query, val_tuple)
            role = cursor.fetchall()
            cursor.execute(id_query, val_tuple)
            user_id = int(cursor.fetchone()[0])
        if role[0] == ('Chef',):
            print()
            print(f'Hello, {username}')
            chef_interface(conn, user_id)
        if role[0] == ('Manager',):
            print()
            print(f'Hello, {username}')
            manager_interface(conn, user_id)
        if role[0] == ('Customer',):
            print()
            print(f'Hello, {username}')
            customer_interface(conn, user_id)
                        
            
    if choice == '2':
        add_new_customer(remote_dba, remote_dba_pass)
main()