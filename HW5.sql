--1. ejz274: pull dates from dual table using different formatting elements
SELECT sysdate,
       to_char(sysdate, 'YEAR') AS year_caps,
       to_char(SYSDATE,'DAY')||' '|| trim(to_char(sysdate, 'MONTH')) AS day_month,
       to_char(SYSDATE,'HH') AS NEAREST_HOUR,
       round(to_date('31-DEC-20') - SYSDATE,2) AS DAYS_UNTIL_END_OF_YEAR,
       TO_CHAR(SYSDATE, 'mon day YYYY') AS MON_DAY_YEAR
FROM dual;

--2. ejz274: displays flight number and departure itinerary 
SELECT flight_id,
       flight_number,
       'Leaving on ' || to_char(departure_datetime, 'Day, Mon DD, YYYY') AS departue_day,
       'Leaving from ' || CASE departure_city
                            WHEN 'SAN'   THEN 'San Diego'
                            WHEN 'HOU'   THEN 'Houston'
                            WHEN 'ABQ'   THEN 'Albaquerque'
                            WHEN 'SAT'   THEN 'San Antonio'
                            WHEN 'LAS'   THEN 'Las Vegas'
                            WHEN 'DEN'   THEN 'Denver'
                            WHEN 'PHX'   THEN 'Phoenix'
                            WHEN 'DAL'   THEN 'Dallas'
                          END AS departure_plan
FROM flight
ORDER BY departure_city ASC;

--3. EJZ274: DISPLAYS PASSENGER NAMES AND UPCOMING SEAT ASSIGNMENTS
SELECT substr(first_name, 1, 1) || '. '|| upper(last_name) AS passenger_name,
    nvl(seat_assignment, 'Need to add') AS upcoming_seat_assignment
FROM passenger p JOIN pass_resv_flight_linking prfl ON p.passenger_id = prfl.passenger_id
ORDER BY last_name;

--4. EJZ274: DISPLAYS FREQUENT FLYER AND THEIR FREE FLIGHTS
SELECT lower(frequent_flyer_id) AS ff_id,
       to_char(trunc(miles_balance / 100), '$9999') AS point_in_dollars,
       to_char(round(((miles_balance / 100) / 600) * 100), '999') || '%' AS fullfreeflight_percent
FROM frequent_flyer_profile
ORDER BY fullfreeflight_percent DESC;

--5. EJZ274: RETURNS PASSENGER BILLING INFORMATION
SELECT cardholder_last_name,
       length(billing_address) AS billing_address_length,
       round(expiration_date - sysdate) AS days_until_card_expiration
FROM passenger_payment
WHERE expiration_date < sysdate;

--6. EJZ274: RETURNS PASSENGER CARD PAYMENT INFO
SELECT cardholder_last_name,
       substr(billing_address, 1, instr(billing_address, ' ') - 1) AS street_num,
       substr(billing_address, instr(billing_address, ' ') + 1) AS street_name,
       nvl2(cardholder_mid_name, 'Does list', 'None listed') AS mid_name_listed,
       billing_city,
       billing_state,
       billing_zip
FROM passenger_payment;

--7. EJZ274: RETURNS DISTINCT INFO ABOUT PASSENGER PAYMENT
SELECT DISTINCT first_name,
                last_name,
                '****-****-****-' || substr(cardnumber, 13) AS redacted_card_num
FROM passenger p JOIN passenger_payment pp ON p.passenger_id = pp.passenger_id
WHERE length(cardnumber) <> 15
ORDER BY last_name;

--8. EJZ274: RETURNS FF PROFILE AND CUSTOMER TIER INFO USING CASE FUNCTION
SELECT CASE
            WHEN miles_balance > 75000 THEN '1-TOP-TIER'
            WHEN miles_balance BETWEEN 25000 AND 75000 THEN '2-MID-TIER'
            WHEN miles_balance < 25000 THEN '3-LOWER-TIER'
       END AS customer_tier,
       frequent_flyer_id,
       ff_level,
       miles_balance
FROM frequent_flyer_profile
ORDER BY miles_balance DESC;

--9. EJZ274: RETURNS FREQUENT FLYERS PROFILES
SELECT first_name,
       last_name,
       frequent_flyer_id,
       email,
       miles_balance,
       RANK() OVER(ORDER BY miles_balance DESC) AS passenger_rank
FROM passenger p JOIN frequent_flyer_profile ffp ON p.passenger_id = ffp.passenger_id;
   

--10. EJZ274: RETURNS FREQUENT FLYERS PROFILES USING ROW_NUMBER()
SELECT  *
FROM ( SELECT ROW_NUMBER() OVER(ORDER BY miles_balance DESC) AS row_number,
              first_name,
              last_name,
              frequent_flyer_id,
              email,
              miles_balance
        FROM passenger p JOIN frequent_flyer_profile ffp ON p.passenger_id = ffp.passenger_id
     )  
WHERE row_number = 4;