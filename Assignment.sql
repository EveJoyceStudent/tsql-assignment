USE assignment;

SELECT sp.name
    , sp.default_database_name
FROM sys.server_principals sp
WHERE sp.name = SUSER_SNAME();

-- ALTER LOGIN admin WITH DEFAULT_DATABASE = assignment;

-- Get a list of tables and views in the current database
SELECT *
FROM INFORMATION_SCHEMA.TABLES

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
        DECLARE @NUMCUST INT;
        SELECT @NUMCUST = COUNT(*) FROM CUSTOMER

        DELETE FROM CUSTOMER;
        RETURN @NUMCUST;
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
-- EXEC ADD_PRODUCT @PRODID = 1, @PRODNAME ='Too Low', @PPRICE = 500
-- EXEC ADD_PRODUCT @PRODID = 2, @PRODNAME ='Too Expensive', @PPRICE = 10000
-- EXEC ADD_PRODUCT @PRODID = 3, @PRODNAME ='Just Right', @PPRICE = 100
-- EXEC ADD_PRODUCT @PRODID = 3, @PRODNAME ='Just Right', @PPRICE = 100
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
        DECLARE @NUMPROD INT;
        SELECT @NUMPROD = COUNT(*) FROM PRODUCT

        DELETE FROM CUSTOMER;
        RETURN @NUMPROD;
    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH;
END;

GO

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


IF OBJECT_ID('GET_CUSTOMER_STRING') IS NOT NULL
DROP PROCEDURE GET_CUSTOMER_STRING;
GO

CREATE PROCEDURE GET_CUSTOMER_STRING @PCUSTID INT AS

 --------------- TODO: From here --------------- 
    SELECT * FROM CUSTOMER 
    WHERE CUSTID = @PCUSTID

BEGIN
    BEGIN TRY
        -- IF 
        SELECT * FROM CUSTOMER WHERE CUSTID = @PCUSTID
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