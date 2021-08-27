-------- DROP TABLES SECTION --------------
-- EMILY ZHOU, EJZ274 : THIS SECTION DELETES ALL EXISTING TABLES
DROP TABLE pass_resv_flight_linking;
DROP TABLE flight;
DROP TABLE passenger_payment;
DROP TABLE frequent_flyer_profile;
DROP TABLE passenger;
DROP TABLE reservation;
DROP TABLE employee;

COMMIT;

---- DROP SEQUENCES ---------------
-- EMILY ZHOU, EJZ274: THIS SECTION DELETES ALL EXISTING SEQUENCES
DROP SEQUENCE flight_id_seq;
DROP SEQUENCE passenger_id_seq;
DROP SEQUENCE reservation_id_seq;
DROP SEQUENCE payment_id_seq;
DROP SEQUENCE employee_id_seq;

COMMIT;

---- CREATE SEQUENCES ---------------
-- EMILY ZHOU, EJZ274: THIS SECTION CREATES SEQUENCES TO AUTO-INCREMENT ID NUMBERS
CREATE SEQUENCE flight_id_seq;
CREATE SEQUENCE passenger_id_seq;
CREATE SEQUENCE reservation_id_seq;
CREATE SEQUENCE payment_id_seq;
CREATE SEQUENCE employee_id_seq
START WITH 100001;

COMMIT;


---- CREATE TABLES -----------------
-- EMILY ZHOU, EJZ274: THIS SECTION CREATES THE NECESSARY TABLES, INCLUDING ITS PKs,FKs, AND CONSTRAINTS
CREATE TABLE passenger
(
    passenger_id            NUMBER(30)         DEFAULT passenger_id_seq.nextval CONSTRAINT passenger_pk PRIMARY KEY,
    first_name              VARCHAR(20)        NOT NULL,
    middle_name             VARCHAR(20),
    last_name               VARCHAR(20)        NOT NULL,
    email                   VARCHAR(30)        NOT NULL       UNIQUE,
    gender                  CHAR(1)            NOT NULL,
    country_of_residence    VARCHAR(20)        NOT NULL,
    state_of_residence      CHAR(2)            NOT NULL,
    mailing_address_1       VARCHAR(30)        NOT NULL,
    mailing_address_2       VARCHAR(30),
    mailing_city            VARCHAR(30)        NOT NULL,
    mailing_state           CHAR(2)            NOT NULL,
    mailing_zip             CHAR(5)            NOT NULL,
    primary_phone           CHAR(12)           NOT NULL,
    secondary_phone         CHAR(12),
    CONSTRAINT email_length_check   CHECK(length(email) >7)
);

CREATE TABLE reservation
(
    reservation_ID          NUMBER(30)      DEFAULT reservation_id_seq.NEXTVAL CONSTRAINT reservation_pk PRIMARY KEY,
    confirmation_number     VARCHAR(30)     NOT NULL           UNIQUE,
    date_booked             DATE            DEFAULT SYSDATE,
    trip_contact_email      VARCHAR(30)     NOT NULL,
    trip_contact_phone      CHAR(12)        NOT NULL
);

CREATE TABLE employee
(   
    employee_id             NUMBER(20)      DEFAULT employee_id_seq.NEXTVAL CONSTRAINT employee_pk PRIMARY KEY,
    first_name              VARCHAR(20)     NOT NULL,
    last_name               VARCHAR(20)     NOT NULL,
    birthday                DATE            NOT NULL,
    tax_id_number           VARCHAR(20)     NOT NULL           UNIQUE,
    mailing_address         VARCHAR(30)     NOT NULL,
    mailing_city            VARCHAR(30)     NOT NULL,
    mailing_state           CHAR(2)         NOT NULL,
    mailing_zip             CHAR(5)         NOT NULL,
    emp_level               CHAR(1)         NOT NULL
    CONSTRAINT emp_level_check    CHECK(emp_level in (1,2,3))
);

CREATE TABLE flight
(
    flight_ID               NUMBER(20)      DEFAULT flight_id_seq.NEXTVAL CONSTRAINT flight_pk PRIMARY KEY,
    flight_number           VARCHAR(20)     NOT NULL,
    departure_datetime      DATE            NOT NULL,
    departure_city          CHAR(3)         NOT NULL,
    arrival_city            CHAR(3)         NOT NULL,
    assigned_employee       NUMBER(20)      NOT NULL    CONSTRAINT flight_fk REFERENCES employee (employee_id)
);

CREATE TABLE passenger_payment
(
    payment_ID              NUMBER(20)      DEFAULT payment_id_seq.NEXTVAL CONSTRAINT pass_pay_pk PRIMARY KEY,
    passenger_id            NUMBER(20)      NOT NULL    CONSTRAINT pass_pay_fk REFERENCES passenger (passenger_id),
    cardholder_first_name   VARCHAR(30)     NOT NULL,
    cardholder_mid_name     VARCHAR(30)     NOT NULL,
    cardholder_last_name    VARCHAR(30)     NOT NULL,
    card_type               VARCHAR(30)     NOT NULL, 
    card_number             VARCHAR(30)     NOT NULL,
    expiration_date         DATE            NOT NULL,
    CC_ID                   VARCHAR(5)      NOT NULL,
    billing_address         VARCHAR(30)     NOT NULL,
    billing_city            VARCHAR(30)     NOT NULL,
    billing_state           CHAR(2)         NOT NULL,
    billing_zip             CHAR(5)         NOT NULL
);

CREATE TABLE frequent_flyer_profile
(
    passenger_id            NUMBER(20),
    frequent_flyer_id       VARCHAR(7)        NOT NULL         UNIQUE,
    -- according to question @103 on piazza, tuttle said that ff_id will
    -- store a 7 character ID comprised of numbers and letters, thus it would not be a number
    flyer_password          VARCHAR(20)        NOT NULL,
    flyer_level             VARCHAR(20)        NOT NULL,
    miles_balance           NUMBER(20)         DEFAULT 5000,
    CONSTRAINT frequent_flyer_pk    PRIMARY KEY (passenger_id),
    CONSTRAINT frequent_flyer_fk    FOREIGN KEY (passenger_id) REFERENCES passenger (passenger_id),
    CONSTRAINT level_check  CHECK (flyer_level in ('B','S','G','P'))
);

CREATE TABLE pass_resv_flight_linking
(
    passenger_id            NUMBER(20),
    reservation_id          NUMBER(20)         NOT NULL,
    flight_id               NUMBER(20)         NOT NULL,
    seat_assignment         VARCHAR(5),
    ticket_number           VARCHAR(10),
    checked_in_flag         CHAR(1)            NOT NUll,
    boarded_flag            CHAR(1)            NOT NULL,
    CONSTRAINT pass_resv_flight_pk   PRIMARY KEY (passenger_id, reservation_id, flight_id),
    CONSTRAINT pass_resv_fligtt_fk1  FOREIGN KEY (passenger_id) REFERENCES passenger (passenger_id),
    CONSTRAINT pass_resv_flight_fk2  FOREIGN KEY (reservation_id) REFERENCES reservation (reservation_id),
    CONSTRAINT pass_resv_flight_fk3  FOREIGN KEY (flight_id)    REFERENCES flight (flight_id)
);

COMMIT;

----- INSERT DATA ------------------
-- EMILY ZHOU, EJZ274: THIS SECTION SEEDS THE CREATED TABLEs WITH DATA, SUCH AS EMPLOYEES, FLIGHTS, PASSENGERS,
-- PAYMENT, AND RESERVATIONS

--- INSERT EMPLOYEES -----------
-- EMILY ZHOU, EJZ274: LINES BELOW CREATE EMPLOYEES IN THE EMPLOYEE TABLE
INSERT INTO employee
VALUES (DEFAULT,'Anna','Lee','10-MAR-1990','624-75-1246','123 Easy Street','Houston',
'TX','77025','1');

INSERT INTO employee
VALUES (DEFAULT,'Bob','Smith','24-AUG-1980','242-74-1234','4572 Sesame Street','Austin',
'TX','78705','2');

INSERT INTO employee
VALUES (DEFAULT,'Sara','Jones','04-JAN-1978','231-53-2467','234 Cool Street','Dallas',
'TX','73423','1');

INSERT INTO employee
VALUES (DEFAULT,'Max','Waller','13-FEB-1970','234-64-1678','4578 Buffalo Street','Houston',
'TX','77005','3');

INSERT INTO employee 
VALUES (DEFAULT,'Faith','Millern','28-OCT-1989','456-31-7089','303 East 21st Street','Austin',
'TX','78795','3');

INSERT INTO employee 
VALUES(DEFAULT,'Jared','Lee','18-NOV-1995','252-47-2367','2950 Lazy Street','Laredo',
'TX','74520','2');

COMMIT;

----- INSERT FLIGHTS -------------
-- EMILY ZHOU, EJZ274: LINES BELOW CREATE FLIGHTS IN THE FLIGHT TABLE
-- FOR JUN 1 2020 ------
INSERT INTO flight
VALUES (DEFAULT,'231',TO_DATE('01-JUN-2020 08:00:00','DD-MON-YYYY HH:MI:SS'),'SAT','ELP',100001);

INSERT INTO flight
VALUES (DEFAULT,'232',TO_DATE('01-JUN-2020 11:00:00','DD-MON-YYYY HH:MI:SS'),'ELP','SAN',100002);

INSERT INTO flight
VALUES (DEFAULT,'451',TO_DATE('01-JUN-2020 11:00:00','DD-MON-YYYY HH:MI:SS'),'SAN','ELP',100003);

INSERT INTO flight
VALUES (DEFAULT, '452',TO_DATE('01-JUN-2020 11:00:00','DD-MON-YYYY HH:MI:SS'),'ELP','SAT',100001);

---- FOR JUN 2 2020 ------
INSERT INTO flight
VALUES (DEFAULT, '231',TO_DATE('02-JUN-2020 11:00:00','DD-MON-YYYY HH:MI:SS'), 'SAT','ELP',100004);

INSERT INTO flight
VALUES (DEFAULT, '232',TO_DATE('02-JUN-2020 11:00:00','DD-MON-YYYY HH:MI:SS'),'ELP','SAN',100005);

INSERT INTO flight
VALUES (DEFAULT,'451',TO_DATE('02-JUN-2020 11:00:00','DD-MON-YYYY HH:MI:SS'),'SAN','ELP',100006);

INSERT INTO flight
VALUES (DEFAULT, '452',TO_DATE('02-JUN-2020 11:00:00','DD-MON-YYYY HH:MI:SS'),'ELP','SAT',100004);

COMMIT;

------ INSERT PASSENGERS AND FREQUENT FLYER PROFILE -------- 
-- EMILY ZHOU, EJZ274: LINES BELOW CREATE NEW PASSENGERS AND THEIR FREQUENT FLYER PROFILE 
INSERT INTO passenger
VALUES (DEFAULT, 'Emily','Jueyu','Zhou','ejz274@utexas.edu','F','USA','TX','303 East 21st','#G335',
'Austin','TX','78705','832-217-2903','713-661-6968');

INSERT INTO passenger 
VALUES (DEFAULT,'Jenny','Jueying','Zhou','jjz123@utexas.edu','F','USA','TX','2231 Saulnier St','#3421',
'Houston','TX','77923','832-341-5023','218-225-7628');

INSERT INTO frequent_flyer_profile
VALUES (1,'AS125FG','helloworld','B',7000);

INSERT INTO frequent_flyer_profile
VALUES (2,'FGH23HG','goodbyeworld','G',15000);

COMMIT;

---- INSERT PAYMENT INFORMATION --------
-- EMILY ZHOU, EJZ274: LINES BELOW CREATE NEW PAYMENT OPTIONS OF PASSENGERS
INSERT INTO passenger_payment
VALUES (DEFAULT,1,'Emily','Jueyu','Zhou','Visa','1234567898765432','08-AUG-2020',
'273','3456 Main Street','Houston','TX','70342');

INSERT INTO passenger_payment
VALUES (DEFAULT,1,'Emily','Jueyu','Zhou','American Express','3456753498651234','10-OCT-2022',
'754','303 East 21st #G335','Austin','TX','78705');

INSERT INTO passenger_payment
VALUES(DEFAULT,2,'Jenny','Jueying','Zhou','Master Card','5555342538967182','22-JAN-2022','431','2231 Saulnier St #3421',
'Houston','TX','77923');

COMMIT;

----- INSERT RESERVATION FOR PASSENGERS --------
-- EMILY ZHOU, EJZ274: LINES BELOW CREATE A RESERVATION FOR PASSENGERS AND LINKS PASSENGERS, FLIGHTS, AND RESERVATION TOGETHER
INSERT INTO reservation 
VALUES (DEFAULT,'523467835',DEFAULT,'emily310zhou@hotmail.com','832-217-6902');

-- PASSENGER 1 DEPARTURE 
INSERT INTO pass_resv_flight_linking
VALUES (1,1,1,'12A',NULL,'N','N');

-- PASSENGER 1 DEPARTURE CONNECTION
INSERT INTO pass_resv_flight_linking
VALUES (1,1,2,'10C',NULL,'N','N');

-- PASSENGER 2 DEPARTURE
INSERT INTO pass_resv_flight_linking
VALUES (2,1,1,'12B',NULL,'N','N');

-- PASSENGER 2 DEPARTURE CONNECTION
INSERT INTO pass_resv_flight_linking
VALUES (2,1,2,'10B',NULL,'N','N');

-- PASSENGER 1 DEPARTURE
INSERT INTO pass_resv_flight_linking
VALUES (1,1,7,'3A',NULL,'N','N');

-- PASSENGER 1 DEPARTURE CONNECTION
INSERT INTO pass_resv_flight_linking
VALUES (1,1,8,'14A',NULL,'N','N');

-- PASSENGER 2 DEPARTURE 
INSERT INTO pass_resv_flight_linking
VALUES (2,1,7,'3B',NULL,'N','N');

-- PASSENGER 2 DEPATRUE CONNECTION
INSERT INTO pass_resv_flight_linking
VALUES (2,1,8,'14B',NULL,'N','N');

COMMIT;

----- CREATE INDEX -----------------
-- EMILY ZHOU, EJZ274: THIS SECTION CREATES INDICES FOR FKs and COLUMNS USED COMMONLY IN SEARCH TO INCREASE SEARCH EFFICIENCY
CREATE INDEX passpayment_passenger_id_ix
ON passenger_payment (passenger_id);

CREATE INDEX flight_assigned_emp_ix
ON flight (assigned_employee);

CREATE INDEX passenger_last_name_ix
ON passenger (last_name);

CREATE INDEX employee_last_name_ix
ON employee (last_name);

COMMIT;

    




    
    
    
    