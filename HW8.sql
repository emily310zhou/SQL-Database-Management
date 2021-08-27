-- EJZ274: CREATE DATA WAREHOUSE TABLE FOR PASSENGERS AND CLIENTS
CREATE TABLE client_dw
(
    data_source CHAR(4)         NOT NULL,
    dw_id       NUMBER          NOT NULL,
    first_name  VARCHAR2(50)    NOT NULL,
    last_name   VARCHAR2(50)    NOT NULL,
    email       VARCHAR2(50)    NOT NULL,
    zip_code    CHAR(5)         NOT NULL,
    phone       CHAR(12)        NOT NULL, 
    CONSTRAINT  client_dw_pk    PRIMARY KEY (data_source,dw_id)
);

-- EJZ274: VIEWS STATEMENTS THAT FORMAT DATA FROM PASSENGERS AND CLIENTS
CREATE OR REPLACE VIEW passenger_view AS
SELECT 'PASS' as data_source, passenger_id, first_name, last_name, email, mailing_zip as zip_code, primary_phone as phone
FROM passenger;
    
CREATE OR REPLACE VIEW prospective_view AS
SELECT 'PROS' as data_source, prospective_id, pc_first_name as first_name, pc_last_name as last_name, email, zip_code,
substr(phone,1,3) || '-' || substr(phone,4,3) || '-' || substr(phone,7) as phone
FROM prospective_client; 


--EJZ274: PROCEDURE TO EXECUTE INSERTS AND UPDATES
CREATE OR REPLACE PROCEDURE client_etl_proc
AS
BEGIN
    INSERT INTO client_dw
    SELECT pv.data_source, pv.passenger_id, pv.first_name, pv.last_name, pv.email, pv.zip_code, pv.phone
    FROM passenger_view pv LEFT JOIN client_dw cdw on pv.passenger_id = cdw.dw_id and pv.data_source = cdw.data_source
    WHERE cdw.dw_id IS NULL and cdw.data_source IS NULL;

    INSERT INTO client_dw
    SELECT prv.data_source, prv.prospective_id, prv.first_name, prv.last_name, prv.email, prv.zip_code, prv.phone
    FROM prospective_view prv LEFT JOIN client_dw cdw on prv.prospective_id = cdw.dw_id and prv.data_source = cdw.data_source 
    WHERE cdw.dw_id IS NULL and cdw.data_source IS NULL;

    MERGE INTO client_dw cdw
    USING  passenger_view pv 
    ON (cdw.dw_id = pv.passenger_id AND cdw.data_source = pv.data_source)
    WHEN MATCHED THEN
    UPDATE SET cdw.first_name = pv.first_name, 
               cdw.last_name = pv.last_name, 
               cdw.email = pv.email, 
               cdw.zip_code = pv.zip_code,
               cdw.phone = pv.phone; 
               
    MERGE INTO client_dw cdw
    USING  prospective_view prv 
    ON (cdw.dw_id = prv.prospective_id AND cdw.data_source = prv.data_source)
    WHEN MATCHED THEN
    UPDATE SET cdw.first_name = prv.first_name, 
               cdw.last_name = prv.last_name, 
               cdw.email = prv.email, 
               cdw.zip_code = prv.zip_code,
               cdw.phone = prv.phone; 
    COMMIT;
    
END;
/



-------------- TESTING ETL --------------------

---- procedure call 
--CALL client_etl_proc();

---- drop statements 
--DROP TABLE client_dw;
--DROP VIEW passenger_view;
--DROP VIEW prospective_view;
--DROP PROCEDURE client_etl_proc;

---- confirm data from source table is in client_dw
--SELECT first_name, last_name, email, mailing_zip, primary_phone
--FROM passenger
--    MINUS
--SELECT first_name, last_name, email, zip_code, phone
--FROM client_dw
--WHERE data_source = 'PASS';

---- confirm data from source table in client_dw
--SELECT pc_first_name, pc_last_name, email, zip_code, substr(phone,1,3) || '-' || substr(phone,4,3) || '-' || substr(phone,7) as phone
--FROM prospective_client
--    MINUS
--SELECT first_name, last_name, email, zip_code, phone
--FROM client_dw
--WHERE data_source = 'PROS';

---- insert statements 
--INSERT INTO PASSENGER (PASSENGER_ID, FIRST_NAME, MIDDLE_NAME, LAST_NAME, EMAIL, GENDER, COUNTRY_OF_RESIDENCE, STATE_OF_RESIDENCE, MAILING_ADDRESS_1, MAILING_ADDRESS_2, MAILING_CITY, MAILING_STATE, MAILING_ZIP, PRIMARY_PHONE, SECONDARY_PHONE) 
--VALUES (21, 'Emily', 'J', 'Zhou', 'ejz@pmail.com', 'F', 'United States', 'TX', '4059 Leeshire Dr.', NULL, 'Houston', 'TX', '77025', '832-217-6902', NULL);

--INSERT INTO Prospective_Client (PROSPECTIVE_ID, PC_FIRST_NAME, PC_LAST_NAME, EMAIL, ZIP_CODE, PHONE)
--VALUES (24, 'Jenny', 'Zhou', 'jenz@pmail.com', '23452', '2815456693');

---- update statements 
--UPDATE passenger
--SET first_name = 'Xinhui'
--where passenger_id = 21;

--UPDATE prospective_client
--SET pc_first_name = 'Ge'
--WHERE prospective_id = 24;
