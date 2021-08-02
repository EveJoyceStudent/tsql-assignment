-- USE assignment;
-- ALTER LOGIN admin WITH DEFAULT_DATABASE = assignment;

-- SELECT sp.name
--     , sp.default_database_name
-- FROM sys.server_principals sp
-- WHERE sp.name = SUSER_SNAME();

-- SELECT *
-- FROM INFORMATION_SCHEMA.TABLES

GO

-- ADD_CUSTOMER	Stored Procedure - Add a new customer to Customer table.
-- Parameters
-- 	pcustid    	INT	            Customer Id
-- 	pcustname	nvarchar(100)	Customer Name

-- Insert a new customer using parameter values.
-- Set the SALES_YTD value to zero.   Set the STATUS value to 'OK'

-- Exceptions
-- 	Duplicate primary key	        50010. Duplicate customer ID
-- 	pcustid outside range: 1-499	50020. Customer ID out of range
-- 	Other	                        50000.  Use value of error_message()


IF OBJECT_ID('ADD_CUSTOMER') IS NOT NULL
DROP PROCEDURE ADD_CUSTOMER;
GO

CREATE PROCEDURE ADD_CUSTOMER @PCUSTID INT, @PCUSTNAME NVARCHAR(100) AS

BEGIN
    BEGIN TRY

        IF @PCUSTID < 1 OR @PCUSTID > 499
            THROW 50020, 'Customer ID out of range', 1

        INSERT INTO CUSTOMER (CUSTID, CUSTNAME, SALES_YTD, STATUS) 
        VALUES (@PCUSTID, @PCUSTNAME, 0, 'OK');

    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() = 2627
            THROW 50010, 'Duplicate customer ID', 1
        ELSE IF ERROR_NUMBER() = 50020
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;

END;

GO

-- testing
-- EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude1';
-- EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude2';
-- EXEC ADD_CUSTOMER @pcustid = 500, @pcustname = 'testdude3';
-- select * from customer;



-- DELETE_ALL_CUSTOMERS	Stored Procedure (returns Int) - Delete all customers from Customer table.
-- No Parameters

-- Delete all customers from Customer table.
-- Return the int of rows deleted

-- Exceptions
-- 	Other	50000.  Use value of error_message()



IF OBJECT_ID('DELETE_ALL_CUSTOMERS') IS NOT NULL
DROP PROCEDURE DELETE_ALL_CUSTOMERS;

GO

CREATE PROCEDURE DELETE_ALL_CUSTOMERS AS

BEGIN
    BEGIN TRY
        DELETE FROM CUSTOMER;
        RETURN @@ROWCOUNT;
    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH;
END;

GO

-- testing
-- EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude1';
-- EXEC ADD_CUSTOMER @pcustid = 2, @pcustname = 'testdude2';
-- EXEC ADD_CUSTOMER @pcustid = 3, @pcustname = 'testdude3';
-- select * from customer;
-- EXEC DELETE_ALL_CUSTOMERS;
-- select * from customer;



-- ADD_PRODUCT - Add a new product to Product table.
-- Parameters	
-- 	pprodid     Int	        Product Id
-- 	pprodname	nvarchar	Product Name
-- 	pprice	    money	    Price

-- Requirements	Insert a new product using parameter values.
-- Set the SALES_YTD value to zero. 

-- Exceptions
-- 	Duplicate primary key	            50030. Duplicate product ID
-- 	pprodid outside range: 1000 - 2500	50040. Product ID out of range
-- 	pprice outside range: 0 – 999.99	50050. Price out of range
-- 	Other	                            50000.  Use value of error_message()


IF OBJECT_ID('ADD_PRODUCT') IS NOT NULL
DROP PROCEDURE ADD_PRODUCT;
GO

CREATE PROCEDURE ADD_PRODUCT @PRODID INT, @PRODNAME NVARCHAR(100), @PPRICE MONEY AS

BEGIN
    BEGIN TRY

        IF @PRODID < 1000 OR @PRODID > 2500
            THROW 50040, 'Product ID out of range', 1
        
        IF @PPRICE < 0 OR @PPRICE > 999.99
            THROW 50050, 'Price out of range', 1

        INSERT INTO PRODUCT (PRODID, PRODNAME, SELLING_PRICE, SALES_YTD) 
        VALUES (@PRODID, @PRODNAME, @PPRICE, 0);

    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() = 2627
            THROW 50030, 'Duplicate product ID', 1
        ELSE IF ERROR_NUMBER() = 50040
            THROW
        ELSE IF ERROR_NUMBER() = 50050
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;

END;

GO

-- testing
-- EXEC ADD_PRODUCT @PRODID = 100, @PRODNAME ='Too Low', @PPRICE = 500
-- EXEC ADD_PRODUCT @PRODID = 2000, @PRODNAME ='Too Expensive', @PPRICE = 10000
-- EXEC ADD_PRODUCT @PRODID = 2001, @PRODNAME ='Just Right', @PPRICE = 100
-- EXEC ADD_PRODUCT @PRODID = 2002, @PRODNAME ='Just Duplicate', @PPRICE = 100
-- SELECT * FROM PRODUCT

-- DELETE_ALL_PRODUCTS	(returns Int) - Delete all products from Product table.
-- No Parameters

-- Requirements	Delete all products from Product table.
-- Return the int of rows deleted

-- Exceptions
-- 	Other	50000.  Use value of error_message()

IF OBJECT_ID('DELETE_ALL_PRODUCTS') IS NOT NULL
DROP PROCEDURE DELETE_ALL_PRODUCTS;

GO

CREATE PROCEDURE DELETE_ALL_PRODUCTS AS

BEGIN
    BEGIN TRY
        DELETE FROM PRODUCT;
        RETURN @@ROWCOUNT;
    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH;
END;

GO

---- testing ----
-- EXEC ADD_PRODUCT @PRODID = 2003, @PRODNAME ='Just Right', @PPRICE = 100
-- select * from PRODUCT;
-- EXEC DELETE_ALL_PRODUCTS;
-- select * from PRODUCT;

-- GET_CUSTOMER_STRING - Get one customers details from customer table
-- Parameters
-- 	pcustid        	Int	            Customer Id
-- 	pReturnString	NVARCHAR(1000)	OUT Parameter
-- Requirements	Assign a string to the OUT parameter using the format:
-- Custid: 999  Name:XXXXXXXXXXXXXXXXXXXX  Status XXXXXXX SalesYTD:99999.99

-- Exceptions
-- 	No matching customer id found	50060. Customer ID not found
-- 	Other	50000.  Use value of error_message()

GO

IF OBJECT_ID('GET_CUSTOMER_STRING') IS NOT NULL
DROP PROCEDURE GET_CUSTOMER_STRING;
GO

CREATE PROCEDURE GET_CUSTOMER_STRING @PCUSTID INT, @pReturnString NVARCHAR(100) OUTPUT AS

BEGIN
    DECLARE @PCUSTNAME NVARCHAR(100), @STATUS NVARCHAR(7), @SALESYTD MONEY;

    BEGIN TRY
    SELECT @PCUSTNAME = CUSTNAME, @STATUS = [STATUS], @SALESYTD = SALES_YTD
    FROM CUSTOMER 
    WHERE CUSTID = @PCUSTID

    IF @@ROWCOUNT = 0
    THROW 50060, 'Customer ID not found', 1

    SET @pReturnString = CONCAT('Custid: ', @PCUSTID, 'Name: ', @PCUSTNAME, 'Status: ', @STATUS, 'SalesYTD: ', @SALESYTD);

    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() = 50060
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;
END;

GO

---- testing ----
BEGIN
    DECLARE @OUTPUTVALUE NVARCHAR(100);
    EXEC GET_CUSTOMER_STRING @pcustid=1, @preturnstring = @OUTPUTVALUE OUTPUT;
    PRINT (@OUTPUTVALUE);
END

-- UPD_CUST_SALESYTD - Update one customer's sales_ytd value in the customer table
-- Parameters
-- pcustid      Int         Customer Id
-- pamt     	Money       Change Amount
-- Requirements	Change one customer's SALES_YTD value by the pamt value. 

-- Exceptions
-- 	No rows updated	                        50070.  Customer ID not found
-- 	pamt outside range:-999.99 to 999.99	50080.  Amount out of range
-- 	Other	                                50000.  Use value of error_message()


GO

IF OBJECT_ID('UPD_CUST_SALESYTD') IS NOT NULL
DROP PROCEDURE UPD_CUST_SALESYTD;
GO

CREATE PROCEDURE UPD_CUST_SALESYTD @PCUSTID INT, @PAMT MONEY AS
BEGIN
    BEGIN TRY

    IF @PAMT<-999.99 OR @PAMT>999.99
        THROW 50080, 'Amount out of range', 1

    -- SELECT SALES_YTD
    UPDATE CUSTOMER
    SET SALES_YTD += @PAMT
    WHERE CUSTID = @PCUSTID

    IF @@ROWCOUNT = 0
    THROW 50070, 'Customer ID not found', 1

    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() in (50070, 50080)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;
END;

GO

--------------- TODO: Add testing --------------- 
---- testing ----

-- GET_PROD_STRING - Get one products details from product table
-- Parameters
-- 	pprodid         Int             Product Id
-- 	pReturnString	NVARCHAR(1000)	OUT Parameter
-- Requirements	Assign a string to the OUT parameter using the format:
-- "Prodid: 999  Name:XXXXXXXXXXXXXXXXXXXX  Price 999.99 SalesYTD:99999.99"

-- Exceptions
-- 	No matching product id found	50090.  Product ID not found
-- 	Other	                        50000.  Use value of error_message()


GO

IF OBJECT_ID('GET_PROD_STRING') IS NOT NULL
DROP PROCEDURE GET_PROD_STRING;
GO

CREATE PROCEDURE GET_PROD_STRING @PRODID INT, @pReturnString NVARCHAR(1000) OUTPUT AS

BEGIN
    DECLARE @PRODNAME NVARCHAR(100), @PRICE MONEY, @SALESYTD MONEY;

    BEGIN TRY
    SELECT @PRODNAME = PRODNAME, @PRICE = SELLING_PRICE, @SALESYTD = SALES_YTD
    FROM PRODUCT 
    WHERE PRODID = @PRODID

    IF @@ROWCOUNT = 0
    THROW 50090, 'Product ID not found', 1

    SET @pReturnString = CONCAT('Prodid: ', @PRODID, 'Name: ', @PRODNAME, 'Price: ', @PRICE, 'SalesYTD: ', @SALESYTD);

    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() = 50090
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;
END;

GO

---- testing ----
BEGIN
    DECLARE @OUTPUTVALUE NVARCHAR(100);
    EXEC GET_PROD_STRING @PRODID=2000, @preturnstring = @OUTPUTVALUE OUTPUT;
    PRINT (@OUTPUTVALUE);
END

--------------- TODO: finish procedure --------------- 
-- UPD_PROD_SALESYTD - Update one product's sales_ytd value in the product table
-- Parameters
-- 	pprodid         Int     Product Id
-- 	pamt            Money	Change Amount
-- Requirements	Change one product's SALES_YTD value by the pamt value. 
-- Exceptions
-- 	No rows updated                         50100. Product ID not found
-- 	pamt outside range:-999.99 to 999.99	50110. Amount out of range
-- 	Other                                   50000. Use value of error_message()

