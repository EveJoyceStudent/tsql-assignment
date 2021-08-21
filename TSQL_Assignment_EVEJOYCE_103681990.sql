-- USE assignment;
-- ALTER LOGIN admin WITH DEFAULT_DATABASE = assignment;

-- SELECT sp.name
--     , sp.default_database_name
-- FROM sys.server_principals sp
-- WHERE sp.name = SUSER_SNAME();

-- SELECT *
-- FROM INFORMATION_SCHEMA.TABLES

GO

-- SPEC01 ADD_CUSTOMER	Stored Procedure - Add a new customer to Customer table.
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


-- SPEC02 DELETE_ALL_CUSTOMERS	Stored Procedure (returns Int) - Delete all customers from Customer table.
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


-- SPEC03 ADD_PRODUCT - Add a new product to Product table.
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


-- SPEC04 DELETE_ALL_PRODUCTS	(returns Int) - Delete all products from Product table.
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


-- SPEC05 GET_CUSTOMER_STRING - Get one customers details from customer table
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
-- BEGIN
--     DECLARE @OUTPUTVALUE NVARCHAR(100);
--     EXEC GET_CUSTOMER_STRING @pcustid=1, @preturnstring = @OUTPUTVALUE OUTPUT;
--     PRINT (@OUTPUTVALUE);
-- END


-- SPEC06 UPD_CUST_SALESYTD - Update one customer's sales_ytd value in the customer table
-- Parameters
-- pcustid      Int         Customer Id
-- pamt     	Money       Change Amount
-- Requirements	Change one customer's SALES_YTD value by the pamt value. 

-- Exceptions
-- 	No rows updated	                        50070.  Customer ID not found
-- 	pamt outside range:-999.99 to 999.99	50080.  Amount out of range
-- 	Other	                                50000.  Use value of error_message()

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

---- testing ----
-- DELETE FROM CUSTOMER
-- SELECT * FROM CUSTOMER
-- EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude1';
-- EXEC ADD_CUSTOMER @pcustid = 2, @pcustname = 'testdude2';
-- EXEC ADD_CUSTOMER @pcustid = 3, @pcustname = 'testdude3';
-- SELECT * FROM CUSTOMER

-- EXEC UPD_CUST_SALESYTD @pcustid = 1, @PAMT = 100;
-- EXEC UPD_CUST_SALESYTD @pcustid = 2, @PAMT = 1000;
-- EXEC UPD_CUST_SALESYTD @pcustid = 2, @PAMT = -1000;
-- EXEC UPD_CUST_SALESYTD @pcustid = 3, @PAMT = 0;
-- EXEC UPD_CUST_SALESYTD @pcustid = 4, @PAMT = 100;
-- SELECT * FROM CUSTOMER


-- SPEC07 GET_PROD_STRING - Get one products details from product table
-- Parameters
-- 	pprodid         Int             Product Id
-- 	pReturnString	NVARCHAR(1000)	OUT Parameter
-- Requirements	Assign a string to the OUT parameter using the format:
-- "Prodid: 999  Name:XXXXXXXXXXXXXXXXXXXX  Price 999.99 SalesYTD:99999.99"

-- Exceptions
-- 	No matching product id found	50090.  Product ID not found
-- 	Other	                        50000.  Use value of error_message()

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
-- BEGIN
--     DECLARE @OUTPUTVALUE NVARCHAR(100);
--     EXEC GET_PROD_STRING @PRODID=2000, @preturnstring = @OUTPUTVALUE OUTPUT;
--     PRINT (@OUTPUTVALUE);
-- END
-- GO


-- SPEC08 UPD_PROD_SALESYTD - Update one product's sales_ytd value in the product table
-- Parameters
-- 	pprodid         Int     Product Id
-- 	pamt            Money	Change Amount
-- Requirements	Change one product's SALES_YTD value by the pamt value. 
-- Exceptions
-- 	No rows updated             50100. Product ID not found
-- 	pamt outside range:
--      -999.99 to 999.99   	50110. Amount out of range
-- 	Other                       50000. Use value of error_message()

IF OBJECT_ID('UPD_PROD_SALESYTD') IS NOT NULL
DROP PROCEDURE UPD_PROD_SALESYTD;
GO

CREATE PROCEDURE UPD_PROD_SALESYTD @pprodid INT, @PAMT MONEY AS
BEGIN
    BEGIN TRY

    IF @PAMT<-999.99 OR @PAMT>999.99
        THROW 50110, 'Amount out of range', 1

    -- SELECT SALES_YTD
    UPDATE PRODUCT
    SET SALES_YTD += @PAMT
    WHERE PRODID = @pprodid

    IF @@ROWCOUNT = 0
    THROW 50100, 'Product ID not found', 1

    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() in (50110, 50100)
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
-- DELETE FROM PRODUCT
-- SELECT * FROM PRODUCT
-- EXEC ADD_PRODUCT @PRODID = 2001, @PRODNAME ='Just Right 1', @PPRICE = 100
-- EXEC ADD_PRODUCT @PRODID = 2002, @PRODNAME ='Just Right 2', @PPRICE = 200
-- EXEC ADD_PRODUCT @PRODID = 2003, @PRODNAME ='Just Right 3', @PPRICE = 300
-- SELECT * FROM PRODUCT

-- EXEC UPD_PROD_SALESYTD @pprodid = 2001, @PAMT = 100;
-- EXEC UPD_PROD_SALESYTD @pprodid = 2002, @PAMT = -1000;
-- EXEC UPD_PROD_SALESYTD @pprodid = 2002, @PAMT = 1000;
-- EXEC UPD_PROD_SALESYTD @pprodid = 2003, @PAMT = 0;
-- EXEC UPD_PROD_SALESYTD @pprodid = 2004, @PAMT = 100;
-- SELECT * FROM PRODUCT


-- SPEC09 UPD_CUSTOMER_STATUS - Update one customer's status value in the customer table
-- Parameters
-- 	pcustid            	Int	Customer Id
-- 	pstatus	Nvarchar	New status
-- Requirements	Change one customer's status value. 
-- Exceptions
-- 	No rows updated	            50120. Customer ID not found
-- 	Invalid status 
-- (not either OK or SUSPEND)	50130. Invalid Status value
-- 	Other	                    50000.  Use value of error_message()

IF OBJECT_ID('UPD_CUSTOMER_STATUS') IS NOT NULL
DROP PROCEDURE UPD_CUSTOMER_STATUS;
GO

CREATE PROCEDURE UPD_CUSTOMER_STATUS @pcustid INT, @pstatus NVARCHAR(7) AS
BEGIN
    BEGIN TRY

    IF @pstatus not in ('OK', 'SUSPEND')
        THROW 50130, 'Invalid Status value', 1

    UPDATE CUSTOMER
    SET STATUS = @pstatus
    WHERE CUSTID = @pcustid

    IF @@ROWCOUNT = 0
    THROW 50120, 'Customer ID not found', 1

    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() in (50130, 50120)
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
-- DELETE FROM CUSTOMER
-- SELECT * FROM CUSTOMER
-- EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude1';
-- EXEC ADD_CUSTOMER @pcustid = 2, @pcustname = 'testdude2';
-- EXEC ADD_CUSTOMER @pcustid = 3, @pcustname = 'testdude3';
-- SELECT * FROM CUSTOMER

-- EXEC UPD_CUSTOMER_STATUS @pcustid = 1, @pstatus = 'OK';
-- EXEC UPD_CUSTOMER_STATUS @pcustid = 2, @pstatus = 'SUSPEND';
-- SELECT * FROM CUSTOMER

-- EXEC UPD_CUSTOMER_STATUS @pcustid = 2, @pstatus = 'BAD';
-- EXEC UPD_CUSTOMER_STATUS @pcustid = 3, @pstatus = '';
-- EXEC UPD_CUSTOMER_STATUS @pcustid = 4, @pstatus = 'OK';


-- SPEC10 ADD_SIMPLE_SALE - Update one customer's status value in the customer table
-- Parameters
-- 	pcustid         Int	Customer Id
-- 	pprodid         Int	Product Id
-- 	pqty	        Int	Sale Qty
-- Requirements	Check if customer status is 'OK'. If not raise an exception.
-- Check if quantity value is valid. If not raise an exception.
-- Update both the Customer and Product SalesYTD values 
-- Note: The YTD values must be increased by pqty * the product price
-- Calls UPD_CUST_SALES_YTD  and UPD_PROD_SALES_YTD
-- Exceptions
-- 	Sale Quantity range 1 - 999	    50140. Sale Quantity outside valid range
-- 	Invalid customer status 
-- (status is not 'OK')	            50150. Customer status is not OK
-- 	No matching customer id found	50160. Customer ID not found
-- 	No matching product id found	50170. Product ID not found
-- 	Other	                        50000.  Use value of error_message()

IF OBJECT_ID('ADD_SIMPLE_SALE') IS NOT NULL
DROP PROCEDURE ADD_SIMPLE_SALE;
GO

CREATE PROCEDURE ADD_SIMPLE_SALE @pcustid INT, @pprodid INT, @pqty INT AS
BEGIN
    BEGIN TRY

    DECLARE @custstatus NVARCHAR(7);

    SELECT @custstatus = STATUS
    FROM CUSTOMER
    WHERE CUSTID = @pcustid
    IF @@ROWCOUNT = 0
        THROW 50160, 'Customer ID not found', 1

    IF (@custstatus NOT IN ('OK'))
        THROW 50150, 'Customer status is not OK', 1

    IF @pqty<1 OR @pqty>999
        THROW 50140, 'Sale Quantity outside valid range', 1

    DECLARE @PRODSELLPRICE MONEY;
    SELECT @PRODSELLPRICE = SELLING_PRICE
    FROM PRODUCT
    WHERE PRODID = @pprodid
    IF @@ROWCOUNT = 0
        THROW 50170, 'Product ID not found', 1

    DECLARE @UPDATEAMT MONEY
    SET @UPDATEAMT = @PRODSELLPRICE*@PQTY;

    -- DECLARE @SALEIDFROMSEQ BIGINT;
    -- SELECT @SALEIDFROMSEQ = NEXT VALUE FOR SALE_SEQ;

    -- INSERT INTO SALE(SALEID, CUSTID, PRODID, QTY, PRICE, SALEDATE) 
    -- VALUES (@SALEIDFROMSEQ, @pcustid, @pprodid, @pqty, @PRODSELLPRICE, CAST( GETDATE() AS Date ));

    EXEC UPD_CUST_SALESYTD @pcustid = @pcustid, @PAMT = @UPDATEAMT
    EXEC UPD_PROD_SALESYTD @pprodid = @pprodid, @PAMT = @UPDATEAMT

    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() in (50150, 50160, 50140, 50170)
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
-- DELETE FROM SALE
-- DELETE FROM PRODUCT
-- EXEC ADD_PRODUCT @PRODID = 2001, @PRODNAME ='Just Right 1', @PPRICE = 10
-- SELECT * FROM PRODUCT

-- DELETE FROM CUSTOMER
-- EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude1';
-- EXEC ADD_CUSTOMER @pcustid = 2, @pcustname = 'testdude2';
-- EXEC UPD_CUSTOMER_STATUS @pcustid = 2, @pstatus = 'SUSPEND';
-- SELECT * FROM CUSTOMER

-- EXEC ADD_SIMPLE_SALE @pcustid = 1, @pprodid = 2001, @pqty = 10;
-- SELECT * FROM PRODUCT
-- SELECT * FROM CUSTOMER
-- SELECT * FROM SALE

-- EXEC ADD_SIMPLE_SALE @pcustid = 2, @pprodid = 2001, @pqty = 100;
-- EXEC ADD_SIMPLE_SALE @pcustid = 3, @pprodid = 2001, @pqty = 100;
-- EXEC ADD_SIMPLE_SALE @pcustid = 1, @pprodid = 2001, @pqty = 0;
-- EXEC ADD_SIMPLE_SALE @pcustid = 1, @pprodid = 2001, @pqty = 1000;
-- EXEC ADD_SIMPLE_SALE @pcustid = 1, @pprodid = 2002, @pqty = 100;


-- SPEC11 SUM_CUSTOMER_SALESYTD - Sum and return the SalesYTD value of all rows in the Customer table
-- Parameters
-- Requirements	Sum and return the SalesYTD value of all rows in the Customer table
-- Exceptions
-- 	Other	50000.  Use value of error_message()

IF OBJECT_ID('SUM_CUSTOMER_SALESYTD') IS NOT NULL
DROP PROCEDURE SUM_CUSTOMER_SALESYTD;
GO

CREATE PROCEDURE SUM_CUSTOMER_SALESYTD AS
BEGIN
    BEGIN TRY

    SELECT SUM(SALES_YTD)
    FROM CUSTOMER

    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH;
END;

GO

---- testing ----
-- DELETE FROM SALE

-- DELETE FROM PRODUCT
-- EXEC ADD_PRODUCT @PRODID = 2001, @PRODNAME ='Just Right 1', @PPRICE = 10
-- EXEC ADD_PRODUCT @PRODID = 2002, @PRODNAME ='Just Right 2', @PPRICE = 1
-- SELECT * FROM PRODUCT

-- DELETE FROM CUSTOMER
-- EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude1';
-- EXEC ADD_CUSTOMER @pcustid = 2, @pcustname = 'testdude2';
-- EXEC ADD_CUSTOMER @pcustid = 3, @pcustname = 'testdude3';
-- SELECT * FROM CUSTOMER

-- EXEC ADD_SIMPLE_SALE @pcustid = 1, @pprodid = 2001, @pqty = 10;
-- EXEC ADD_SIMPLE_SALE @pcustid = 2, @pprodid = 2001, @pqty = 1;
-- EXEC ADD_SIMPLE_SALE @pcustid = 2, @pprodid = 2002, @pqty = 5;
-- SELECT * FROM CUSTOMER
-- -- SELECT * FROM SALE

-- EXEC SUM_CUSTOMER_SALESYTD;

-- SPEC12 SUM_PRODUCT_SALESYTD - Sum and return the SalesYTD value of all rows in the Product table
-- Parameters
-- Requirements	Sum and return the SalesYTD value of all rows in the Product table
-- Exceptions
-- 	Other	50000.  Use value of error_message()

IF OBJECT_ID('SUM_PRODUCT_SALESYTD') IS NOT NULL
DROP PROCEDURE SUM_PRODUCT_SALESYTD;
GO

CREATE PROCEDURE SUM_PRODUCT_SALESYTD AS
BEGIN
    BEGIN TRY

    SELECT SUM(SALES_YTD)
    FROM PRODUCT

    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH;
END;
GO

---- testing ----
-- DELETE FROM SALE

-- DELETE FROM PRODUCT
-- EXEC ADD_PRODUCT @PRODID = 2001, @PRODNAME ='Just Right 1', @PPRICE = 10
-- EXEC ADD_PRODUCT @PRODID = 2002, @PRODNAME ='Just Right 2', @PPRICE = 1
-- SELECT * FROM PRODUCT

-- DELETE FROM CUSTOMER
-- EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude1';
-- EXEC ADD_CUSTOMER @pcustid = 2, @pcustname = 'testdude2';
-- EXEC ADD_CUSTOMER @pcustid = 3, @pcustname = 'testdude3';
-- SELECT * FROM CUSTOMER

-- EXEC ADD_SIMPLE_SALE @pcustid = 1, @pprodid = 2001, @pqty = 10;
-- EXEC ADD_SIMPLE_SALE @pcustid = 2, @pprodid = 2001, @pqty = 1;
-- EXEC ADD_SIMPLE_SALE @pcustid = 2, @pprodid = 2002, @pqty = 5;
-- SELECT * FROM CUSTOMER
-- -- SELECT * FROM SALE

-- EXEC SUM_PRODUCT_SALESYTD;


-- SPEC13 GET_ALL_CUSTOMERS - Get all customer details and return as a SYS_REFCURSOR
-- Parameters
-- 	POUTCUR	Cursor	Output parameter Cursor
-- Requirements	Get all customer details and assign to pOutCur
-- Exceptions
-- 	Other	50000.  Use value of error_message()

IF OBJECT_ID('GET_ALL_CUSTOMERS') IS NOT NULL
DROP PROCEDURE GET_ALL_CUSTOMERS;
GO

CREATE PROCEDURE GET_ALL_CUSTOMERS @POUTCUR CURSOR VARYING OUTPUT AS
BEGIN
    BEGIN TRY

        SET @POUTCUR = CURSOR FOR
            SELECT *
            FROM CUSTOMER

        OPEN @POUTCUR;

    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH;
END;
GO
--------------- testing --------------- 

-- DELETE FROM CUSTOMER
-- EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude1';
-- EXEC ADD_CUSTOMER @pcustid = 2, @pcustname = 'testdude2';
-- EXEC ADD_CUSTOMER @pcustid = 3, @pcustname = 'testdude3';

-- BEGIN
--     DECLARE @CUSTID INT, @CUSTNAME NVARCHAR(100), @SALES_YTD MONEY, @STATUS NVARCHAR(7);
--     DECLARE @OUTCUR AS CURSOR
--     EXEC GET_ALL_CUSTOMERS @POUTCUR = @OUTCUR OUTPUT;
--     FETCH NEXT FROM @OUTCUR INTO @CUSTID, @CUSTNAME, @SALES_YTD, @STATUS
--     WHILE @@FETCH_STATUS=0
--     BEGIN
--         PRINT CONCAT(@CUSTID, ' ', @CUSTNAME, ' ', @SALES_YTD, ' ', @STATUS)
--         FETCH NEXT FROM @OUTCUR INTO @CUSTID, @CUSTNAME, @SALES_YTD, @STATUS
--     END
    
--     CLOSE @OUTCUR;
--     DEALLOCATE @OUTCUR;
-- END


-- SPEC14 GET_ALL_PRODUCTS - Get all product details and assign to pOutCur
-- Parameters
-- 	POUTCUR	Cursor	Output parameter Cursor
-- Requirements	Get all product details and return as a SYS_REFCURSOR
-- Exceptions
-- 	Other	50000.  Use value of error_message()

IF OBJECT_ID('GET_ALL_PRODUCTS') IS NOT NULL
DROP PROCEDURE GET_ALL_PRODUCTS;
GO

CREATE PROCEDURE GET_ALL_PRODUCTS @POUTCUR CURSOR VARYING OUTPUT AS
BEGIN
    BEGIN TRY

        SET @POUTCUR = CURSOR FOR
            SELECT *
            FROM PRODUCT

        OPEN @POUTCUR;

    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH;
END;
GO

--------------- testing --------------- 
-- DELETE FROM PRODUCT
-- EXEC ADD_PRODUCT @PRODID = 2001, @PRODNAME ='Just Right 1', @PPRICE = 10
-- EXEC ADD_PRODUCT @PRODID = 2002, @PRODNAME ='Just Right 2', @PPRICE = 1
-- SELECT * FROM PRODUCT


-- BEGIN
--     DECLARE @PRODID INT, @PRODNAME NVARCHAR(100), @SELLING_PRICE MONEY, @SALES_YTD MONEY;
--     DECLARE @OUTCUR AS CURSOR
--     EXEC GET_ALL_PRODUCTS @POUTCUR = @OUTCUR OUTPUT;
--     FETCH NEXT FROM @OUTCUR INTO @PRODID, @PRODNAME, @SELLING_PRICE, @SALES_YTD
--     WHILE @@FETCH_STATUS=0
--     BEGIN
--         PRINT CONCAT(@PRODID, ' ', @PRODNAME, ' ', @SELLING_PRICE, ' ', @SALES_YTD)
--         FETCH NEXT FROM @OUTCUR INTO @PRODID, @PRODNAME, @SELLING_PRICE, @SALES_YTD
--     END
    
--     CLOSE @OUTCUR;
--     DEALLOCATE @OUTCUR;
-- END

-- SPEC15 ADD_LOCATION - Adds a new row to the location table
-- Parameters
-- 	ploccode	nvarchar	Location Code- format ‘locnn’    ‘nn’= int
-- 	pminqty	Int	Min qty
-- 	pmaxqty	Int	Max qty
-- Requirements	Add a new row to the location table
-- Exceptions
-- 	Duplicate primary key	        50180. Duplicate location ID
-- 	CHECK_LOCID_LENGTH check failed	50190. Location Code length invalid
-- 	CHECK_MINQTY_RANGE check failed	50200. Minimum Qty out of range
-- 	CHECK_MAXQTY_RANGE check failed	50210. Maximum Qty out of range
-- 	CHECK_MAXQTY_GREATER_MIXQTY check failed	
--                                  50220. Minimum Qty larger than Maximum Qty
-- 	Other	                        50000.  Use value of error_message()


IF OBJECT_ID('ADD_LOCATION') IS NOT NULL
DROP PROCEDURE ADD_LOCATION;
GO

CREATE PROCEDURE ADD_LOCATION @ploccode NVARCHAR(5), @pminqty INT, @pmaxqty INT AS
BEGIN
    BEGIN TRY

        IF LEN(@ploccode)!=5
            THROW 50190, 'Location Code length invalid', 1
        
        IF @pminqty < 0 OR @pminqty > 999
            THROW 50200, 'Minimum Qty out of range', 1

        IF @pmaxqty < 0 OR @pmaxqty > 999
            THROW 50210, 'Maximum Qty out of range', 1

        IF @pmaxqty < @pminqty
            THROW 50220, 'Minimum Qty larger than Maximum Qty', 1

        INSERT INTO LOCATION (LOCID, MINQTY, MAXQTY) 
        VALUES (@ploccode, @pminqty, @pmaxqty);

    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() = 2627
                THROW 50180, 'Duplicate location ID', 1
        if ERROR_NUMBER() in (50190, 50200, 50210, 50220)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;
END;
GO

--------------- testing --------------- 
-- DELETE FROM LOCATION
-- EXEC ADD_LOCATION @ploccode = 'loc01', @pminqty = 0, @pmaxqty = 999;
-- SELECT * FROM LOCATION

-- EXEC ADD_LOCATION @ploccode = 'loc01', @pminqty = 0, @pmaxqty = 999;
-- EXEC ADD_LOCATION @ploccode = 'loc1', @pminqty = 0, @pmaxqty = 999;
-- EXEC ADD_LOCATION @ploccode = 'loc02', @pminqty =-1000, @pmaxqty = 999;
-- EXEC ADD_LOCATION @ploccode = 'loc02', @pminqty =1000, @pmaxqty = 999;
-- EXEC ADD_LOCATION @ploccode = 'loc02', @pminqty =0, @pmaxqty = -1;
-- EXEC ADD_LOCATION @ploccode = 'loc02', @pminqty =0, @pmaxqty = 1000;
-- EXEC ADD_LOCATION @ploccode = 'loc02', @pminqty =1, @pmaxqty = 0;


-- SPEC16 ADD_COMPLEX_SALE - Adds a complex sale to the database
-- Parameters
-- 	pcustid         Int	Customer Id
-- 	pprodid         Int	Product Id
-- 	pqty	        Int	Sale Qty
-- 	pdate	        Nvarchar	Sale Date format yyyymmdd
-- Requirements	Check if customer status is 'OK'. If not raise an exception.
-- Check if quantity value is valid. If not raise an exception.
-- Check if date value is valid. If not raise an exception.
-- Insert a new row into the Sale table.
-- The saleid value must be obtained from the SALE_SEQ
-- Update both the Customer and Product SalesYTD values 
-- Note: The YTD values must be increased by pqty * the unit price
-- Calls UPD_CUST_SALES_YTD  and UPD_PROD_SALES_YTD
-- Exceptions
-- 	Sale Quantity range 1 - 999	    50230. Sale Quantity outside valid range
-- 	Invalid customer status 
-- (status is not 'OK')	            50240. Customer status is not OK
-- 	Invalid sale date 	            50250. Date not valid
-- 	No matching customer id found	50260. Customer ID not found
-- 	No matching product id found	50270. Product ID not found
-- 	Other	                        50000.  Use value of error_message()

IF OBJECT_ID('ADD_COMPLEX_SALE') IS NOT NULL
DROP PROCEDURE ADD_COMPLEX_SALE;
GO

CREATE PROCEDURE ADD_COMPLEX_SALE @pcustid INT, @pprodid INT, @pqty INT, @pdate NVARCHAR(8) AS
BEGIN
    BEGIN TRY

        DECLARE @custstatus NVARCHAR(7);

        SELECT @custstatus = STATUS
        FROM CUSTOMER
        WHERE CUSTID = @pcustid
        IF @@ROWCOUNT = 0
            THROW 50260, 'Customer ID not found', 1

        IF (@custstatus NOT IN ('OK'))
            THROW 50240, 'Customer status is not OK', 1

        IF @pqty<1 OR @pqty>999
            THROW 50230, 'Sale Quantity outside valid range', 1

        DECLARE @PRODSELLPRICE MONEY;
        SELECT @PRODSELLPRICE = SELLING_PRICE
        FROM PRODUCT
        WHERE PRODID = @pprodid
        IF @@ROWCOUNT = 0
            THROW 50270, 'Product ID not found', 1
        
        IF (ISDATE(@pdate) = 0)
            THROW 50250, 'Date not valid', 1

        DECLARE @SALEIDFROMSEQ BIGINT;
        SELECT @SALEIDFROMSEQ = NEXT VALUE FOR SALE_SEQ;

        INSERT INTO SALE(SALEID, CUSTID, PRODID, QTY, PRICE, SALEDATE) 
        VALUES (@SALEIDFROMSEQ, @pcustid, @pprodid, @pqty, @PRODSELLPRICE, CONVERT(DATE, @pdate, 112));

        DECLARE @UPDATEAMT MONEY
        SET @UPDATEAMT = @PRODSELLPRICE*@PQTY;

        EXEC UPD_CUST_SALESYTD @pcustid = @pcustid, @PAMT = @UPDATEAMT
        EXEC UPD_PROD_SALESYTD @pprodid = @pprodid, @PAMT = @UPDATEAMT

    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() in (50240, 50260, 50230, 50270, 50250)
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
-- DELETE FROM SALE
-- DELETE FROM PRODUCT
-- EXEC ADD_PRODUCT @PRODID = 2001, @PRODNAME ='Just Right 1', @PPRICE = 10
-- SELECT * FROM PRODUCT

-- DELETE FROM CUSTOMER
-- EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude1';
-- EXEC ADD_CUSTOMER @pcustid = 2, @pcustname = 'testdude2';
-- EXEC UPD_CUSTOMER_STATUS @pcustid = 2, @pstatus = 'SUSPEND';
-- SELECT * FROM CUSTOMER

-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2001, @pqty = 10, @pdate = '20210821';
-- SELECT * FROM PRODUCT
-- SELECT * FROM CUSTOMER
-- SELECT * FROM SALE

-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2001, @pqty = 100, @pdate = '2021082';
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2001, @pqty = 100, @pdate = '2021-08-21';
-- EXEC ADD_COMPLEX_SALE @pcustid = 2, @pprodid = 2001, @pqty = 100, @pdate = '20210821';
-- EXEC ADD_COMPLEX_SALE @pcustid = 3, @pprodid = 2001, @pqty = 100, @pdate = '20210821';
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2001, @pqty = 0, @pdate = '20210821';
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2001, @pqty = 1000, @pdate = '20210821';
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2002, @pqty = 100, @pdate = '20210821';


-- SPEC17 GET_ALLSALES - Get all customer details and return as a SYS_REFCURSOR
-- Parameters
-- 	POUTCUR	Cursor	Output parameter Cursor
-- Requirements	Get all complex sale details and assign to pOutCur
-- Exceptions
-- 	Other	50000.  Use value of error_message()

IF OBJECT_ID('GET_ALLSALES') IS NOT NULL
DROP PROCEDURE GET_ALLSALES;
GO

CREATE PROCEDURE GET_ALLSALES @POUTCUR CURSOR VARYING OUTPUT AS
BEGIN
    BEGIN TRY

        SET @POUTCUR = CURSOR FOR
            SELECT *
            FROM SALE

        OPEN @POUTCUR;

    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH;
END;
GO

--------------- testing --------------- 
-- DELETE FROM SALE
-- DELETE FROM PRODUCT
-- EXEC ADD_PRODUCT @PRODID = 2001, @PRODNAME ='Just Right 1', @PPRICE = 10

-- DELETE FROM CUSTOMER
-- EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude1';

-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2001, @pqty = 10, @pdate = '20210821';
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2001, @pqty = 10, @pdate = '20210811';
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2001, @pqty = 10, @pdate = '20200821';
-- SELECT * FROM PRODUCT
-- SELECT * FROM CUSTOMER
-- SELECT * FROM SALE

-- BEGIN
--     DECLARE @SALEID BIGINT, @CUSTID INT, @PRODID INT, @QTY INT, @PRICE MONEY, @SALEDATE DATE;
--     DECLARE @OUTCUR AS CURSOR
--     EXEC GET_ALLSALES @POUTCUR = @OUTCUR OUTPUT;
--     FETCH NEXT FROM @OUTCUR INTO @SALEID, @CUSTID, @PRODID, @QTY, @PRICE, @SALEDATE
--     WHILE @@FETCH_STATUS=0
--     BEGIN
--         PRINT CONCAT(@SALEID, ' ', @CUSTID, ' ', @PRODID, ' ', @QTY, ' ', @PRICE, ' ', @SALEDATE)
--         FETCH NEXT FROM @OUTCUR INTO @SALEID, @CUSTID, @PRODID, @QTY, @PRICE, @SALEDATE
--     END
    
--     CLOSE @OUTCUR;
--     DEALLOCATE @OUTCUR;
-- END


-- SPEC18 COUNT_PRODUCT_SALES - Count and return the int of sales with nn days of current date
-- Parameters
-- 	pdays	int	Count sales made within pdays of today's date
-- Requirements	Count and return the int of sales in the SALES table with nn days of current date
-- Exceptions
-- 	Other	50000.  Use value of error_message()

IF OBJECT_ID('COUNT_PRODUCT_SALES') IS NOT NULL
DROP PROCEDURE COUNT_PRODUCT_SALES;
GO

CREATE PROCEDURE COUNT_PRODUCT_SALES @pdays INT, @pcount INT OUTPUT AS
BEGIN
    BEGIN TRY

    SELECT COUNT(SALEID) FROM SALE
    WHERE SALEDATE>=(GETDATE()-@pdays)

    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH;
END;
GO

--------------- testing --------------- 
-- DELETE FROM SALE
-- DELETE FROM PRODUCT
-- EXEC ADD_PRODUCT @PRODID = 2001, @PRODNAME ='Just Right 1', @PPRICE = 10

-- DELETE FROM CUSTOMER
-- EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude1';

-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2001, @pqty = 10, @pdate = '20210821';
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2001, @pqty = 10, @pdate = '20210811';
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2001, @pqty = 10, @pdate = '20200821';
-- SELECT * FROM PRODUCT
-- SELECT * FROM CUSTOMER
-- SELECT * FROM SALE

-- BEGIN
--     DECLARE @OUTPUTVALUE INT;
--     EXEC COUNT_PRODUCT_SALES @pdays=0, @pcount = @OUTPUTVALUE OUTPUT;
--     PRINT (@OUTPUTVALUE);
--     EXEC COUNT_PRODUCT_SALES @pdays=1, @pcount = @OUTPUTVALUE OUTPUT;
--     PRINT (@OUTPUTVALUE);
--     EXEC COUNT_PRODUCT_SALES @pdays=11, @pcount = @OUTPUTVALUE OUTPUT;
--     PRINT (@OUTPUTVALUE);
--     EXEC COUNT_PRODUCT_SALES @pdays=1000, @pcount = @OUTPUTVALUE OUTPUT;
--     PRINT (@OUTPUTVALUE);
-- END
-- GO


-- SPEC19 DELETE_SALE - Delete a row from the SALE table
-- Parameters saleid out PARAM
-- Requirements	Determine the smallest saleid value in the SALE table.  (use Select MIN()…)
-- If the value is NULL raise a No Sale Rows Found exception.
-- Otherwise delete a row from the SALE table with the matching sale id
-- Calls UPD_CUST_SALES_YTD  and UPD_PROD_SALES_YTD so that the correct amount is subtracted from SALES_YTD.
-- You must calculate the amount using the PRICE in the SALE table multiplied by the QTY
-- This function must return the SaleID value of the Sale row that was deleted.
-- (It is a bit unrealistic to delete a row with the smallest saleid. Normally you would ask a user to enter a sale id value. However this is difficult to do when testing with an anonymous block. So we will settle for smallest saleid in this assignment).
-- Exceptions
-- 	No Sale Rows Found	50280. No Sale Rows Found
-- 	Other	            50000.  Use value of error_message()

IF OBJECT_ID('DELETE_SALE') IS NOT NULL
DROP PROCEDURE DELETE_SALE;
GO

CREATE PROCEDURE DELETE_SALE @saleid BIGINT OUTPUT AS
BEGIN
    BEGIN TRY
        DECLARE @salepcustid INT, @salepprodid INT, @UPDATEAMT INT;

        SELECT @saleid = MIN(SALEID) FROM SALE
        IF @saleid IS NULL
            THROW 50280, 'No Sale Rows Found', 1
        
        SELECT @salepcustid = CUSTID FROM SALE
        WHERE SALEID = @saleid;
        SELECT @salepprodid = PRODID FROM SALE
        WHERE SALEID = @saleid;
        SELECT @UPDATEAMT = QTY*PRICE FROM SALE
        WHERE SALEID = @saleid;
        
        EXEC UPD_CUST_SALESYTD @pcustid = @salepcustid, @PAMT = @UPDATEAMT
        EXEC UPD_PROD_SALESYTD @pprodid = @salepprodid, @PAMT = @UPDATEAMT

        DELETE FROM SALE
        WHERE SALEID = @saleid;

    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() in (50280)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;
END;
GO

--------------- testing --------------- 
-- DELETE FROM SALE
-- DELETE FROM PRODUCT
-- EXEC ADD_PRODUCT @PRODID = 2001, @PRODNAME ='Just Right 1', @PPRICE = 10

-- DELETE FROM CUSTOMER
-- EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude1';

-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2001, @pqty = 10, @pdate = '20210821';
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2001, @pqty = 10, @pdate = '20210811';
-- SELECT * FROM PRODUCT
-- SELECT * FROM CUSTOMER
-- SELECT * FROM SALE

-- BEGIN
--     DECLARE @OUTPUTVALUE BIGINT;
--     EXEC DELETE_SALE @saleid = @OUTPUTVALUE OUTPUT;
--     PRINT (@OUTPUTVALUE);
-- END
-- GO

-- BEGIN
--     DECLARE @OUTPUTVALUE BIGINT;
--     EXEC DELETE_SALE @saleid = @OUTPUTVALUE OUTPUT;
--     PRINT (@OUTPUTVALUE);
-- END
-- GO

-- SELECT * FROM SALE

-- BEGIN
--     DECLARE @OUTPUTVALUE BIGINT;
--     EXEC DELETE_SALE @saleid = @OUTPUTVALUE OUTPUT;
--     PRINT (@OUTPUTVALUE);
-- END
-- GO


-- SPEC20 DELETE_ALL_SALES - Delete a row from the SALE table
-- Parameters NONE
-- Requirements	Delete all rows in the SALE table 
-- Set the Sales_YTD value to zero for all rows in the Customer and Product tables
-- Exceptions
-- 	Other	50000.  Use value of error_message()

IF OBJECT_ID('DELETE_ALL_SALES') IS NOT NULL
DROP PROCEDURE DELETE_ALL_SALES;
GO

CREATE PROCEDURE DELETE_ALL_SALES AS
BEGIN
    BEGIN TRY

        DELETE FROM SALE

        UPDATE CUSTOMER
        SET SALES_YTD=0;
        UPDATE PRODUCT
        SET SALES_YTD=0;        

    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH;
END;
GO

--------------- testing --------------- 
-- DELETE FROM SALE
-- DELETE FROM PRODUCT
-- EXEC ADD_PRODUCT @PRODID = 2001, @PRODNAME ='Just Right 1', @PPRICE = 10

-- DELETE FROM CUSTOMER
-- EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude1';

-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2001, @pqty = 10, @pdate = '20210821';
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2001, @pqty = 10, @pdate = '20210811';
-- SELECT * FROM PRODUCT
-- SELECT * FROM CUSTOMER
-- SELECT * FROM SALE

-- EXEC DELETE_ALL_SALES;
-- SELECT * FROM PRODUCT
-- SELECT * FROM CUSTOMER
-- SELECT * FROM SALE


-- SPEC21 DELETE_CUSTOMER - Delete a row from the Customer table
-- Parameters
-- 	pCustid	int	Customer Id
-- Requirements	Delete a customer with a matching customer id
-- If ComplexSales exist for the customer, replace the default error code with a custom made exception to handle this error & raise the exception below
-- Exceptions
-- 	No matching customer id found	        50290. Customer ID not found
-- 	Customer has child complexsales rows	50300. Customer cannot be deleted as sales exist
-- 	Other	                                50000.  Use value of error_message()

IF OBJECT_ID('DELETE_CUSTOMER') IS NOT NULL
DROP PROCEDURE DELETE_CUSTOMER;
GO

CREATE PROCEDURE DELETE_CUSTOMER @pCustid INT AS
BEGIN
    BEGIN TRY

        DELETE FROM CUSTOMER
        WHERE CUSTID = @pCustid
        IF @@ROWCOUNT = 0
            THROW 50290, 'Customer ID not found', 1

    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() = 547
            THROW 50300, 'Customer cannot be deleted as sales exist', 1
        ELSE if ERROR_NUMBER() in (50290)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;
END;
GO
--------------- testing --------------- 

-- DELETE FROM SALE
-- DELETE FROM PRODUCT
-- EXEC ADD_PRODUCT @PRODID = 2001, @PRODNAME ='Just Right 1', @PPRICE = 10

-- DELETE FROM CUSTOMER
-- EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude1';

-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2001, @pqty = 10, @pdate = '20210821';
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2001, @pqty = 10, @pdate = '20210811';
-- SELECT * FROM PRODUCT
-- SELECT * FROM CUSTOMER
-- SELECT * FROM SALE

-- DELETE FROM CUSTOMER
--     WHERE CUSTID =1

-- EXEC DELETE_CUSTOMER @pCustid = 1;

-- EXEC DELETE_ALL_SALES;

-- EXEC DELETE_CUSTOMER @pCustid = 1;

-- SELECT * FROM CUSTOMER

-- EXEC DELETE_CUSTOMER @pCustid = 1;


-- SPEC22 DELETE_PRODUCT - Delete a row from the Product table
-- Parameters
-- 	pProdid	int	Product Id
-- Requirements	Delete a product with a matching Product id
-- If ComplexSales exist for the customer, Oracle would normally generate a 'Child Record Found' error (error code -2292). Instead,
-- Create a custom made exception to handle this error & raise the exception below
-- Exceptions
-- 	No matching Product id found	    50310. Product ID not found
-- 	Product has child complexsales rows	50320. Product cannot be deleted as sales exist
-- 	Other	                            50000.  Use value of error_message()

IF OBJECT_ID('DELETE_PRODUCT') IS NOT NULL
DROP PROCEDURE DELETE_PRODUCT;
GO

CREATE PROCEDURE DELETE_PRODUCT @pProdid INT AS
BEGIN
    BEGIN TRY

        DELETE FROM PRODUCT
        WHERE PRODID = @pProdid
        IF @@ROWCOUNT = 0
            THROW 50310, 'Product ID not found', 1

    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() = 547
            THROW 50320, 'Product cannot be deleted as sales exist', 1
        ELSE if ERROR_NUMBER() in (50310)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;
END;
GO
--------------- testing --------------- 

-- DELETE FROM SALE
-- DELETE FROM PRODUCT
-- EXEC ADD_PRODUCT @PRODID = 2001, @PRODNAME ='Just Right 1', @PPRICE = 10

-- DELETE FROM CUSTOMER
-- EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude1';

-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2001, @pqty = 10, @pdate = '20210821';
-- EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2001, @pqty = 10, @pdate = '20210811';
-- SELECT * FROM PRODUCT
-- SELECT * FROM CUSTOMER
-- SELECT * FROM SALE

-- EXEC DELETE_PRODUCT @pProdid = 2001;

-- EXEC DELETE_ALL_SALES;

-- EXEC DELETE_PRODUCT @pProdid = 2001;

-- SELECT * FROM PRODUCT

-- EXEC DELETE_PRODUCT @pProdid = 2001;