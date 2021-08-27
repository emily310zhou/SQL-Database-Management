set serveroutput on;

-- 1. ejz274: script to display count of all flights from San Antonio
declare
    count_flight_var    number;
begin 
    select count(*) 
    into count_flight_var
    from flight
    where departure_city = 'SAN';
    
    if count_flight_var > 30 then
        dbms_output.put_line('The number of flights from San Antonio is greater than 30');
    else
        dbms_output.put_line('The number of flights from San Antonio is less than or equal to 30');
    end if;
end;
/


--2. ejz274: using dynamic sql to pull count of flights from an inputted city
declare
    count_flight_var    number;
    departure_city_code flight.departure_city%type;
begin 
    departure_city_code := &city_code;
    
    select count(*)
    into count_flight_var
    from flight
    where departure_city = departure_city_code;
    
    if count_flight_var > 30 then
        dbms_output.put_line('The number of flights from ' || departure_city_code || ' is greater than 30');
    else
        dbms_output.put_line('The number of flights from ' || departure_city_code || ' is less than or equal to 30');
    end if;
end;
/


--3. ejz274: script to insert a new flight into flights table
begin
    insert into flight
    values (default,165,'20-APR-20','HOU','ABQ',100037);
    dbms_output.put_line('1 row inserted into the flight table.');
    commit;
exception
    when others then
        dbms_output.put_line('Row was not inserted. Unexpected exception occurred');  
end;
/


--4. ejz274: using bulk collect to capture list of all passengers on flight_id 25
declare
    type  seat_table  is table of varchar2(4);
    seats             seat_table;
begin  
    select seat_assignment
    bulk collect into seats
    from pass_resv_flight_linking
    where flight_id = 25
    order by passenger_id asc;
    
    for i in 1..seats.count loop
        dbms_output.put_line('Passenger ' || i || ':' || seats(i));
    end loop;

end;
/

--5. ejz274: rewrite Q1 as a function that returns count of flights for each flight number
create or replace function count_flights
(   
    flight_num_param    flight.flight_number%type
)
return number
as
count_flight_var    number;
begin 
    select count(flight_number) 
    into count_flight_var
    from flight
    where flight_number = flight_num_param;
    
    return count_flight_var;
end;
/

-- select test for Q5
select distinct flight_number, count_flights(flight_number) as count_of_flights
from flight;

-- EXTRA CREDIT: select statement without the function
select flight_number, count(*) as count_of_flights
from flight
group by flight_number;

select count()
from flight
where flight_number = 165;



--6. ejz274: stored procedure that update employees
create or replace procedure update_employee_mailing
(
    id_param                employee.employee_id%type,
    address_param           employee.mailing_address%type,
    city_param              employee.mailing_city%type,
    state_param             employee.mailing_state%type,
    zip_param               employee.mailing_zip%type
)
as
begin
    update employee
    set mailing_address = address_param,
        mailing_city = city_param, 
        mailing_state = state_param,
        mailing_zip = zip_param
    where employee_id = id_param;
    
    commit;
exception
    when others then
        rollback;
end;
/

-- script to update info for employee 100010
begin
    update_employee_mailing(100010,'1234 Happy Street','Austin','TX','78708');
end;
/

--select statement to check if procedure and test script work
select *
from employee
where employee_id = 100010;

    
--7. ejz274: named procedure to insert new flight
create or replace procedure insert_flight
(
    flight_num_param        flight.flight_number%type,
    depart_datetime_param   flight.departure_datetime%type,
    depart_city_param       flight.departure_city%type,
    arrive_city_param       flight.arrival_city%type,
    assigned_employee_param flight.assigned_employee%type,
    flight_id_param         flight.flight_id%type   default flight_id_seq.nextval
)
as
begin 
    insert into flight
    values (flight_id_param,flight_num_param,depart_datetime_param,depart_city_param,arrive_city_param,assigned_employee_param);
    dbms_output.put_line('1 row inserted into the flight table.');
    commit;
exception
    when dup_val_on_index then 
        dbms_output.put_line('You have tried to insert a duplicate value');
    when others then
        dbms_output.put_line('Row was not inserted. Unexpected exception occurred');  
        rollback;
end;
/

-- CALL statements to test Q7
call insert_flight(100,777,'26-MAY-20','PHX','DAL',100023);
call insert_flight(834,'21-OCT-20','DEN','LAS',100019);


--8. ejz274: function to retrieve number of miles from frequent flyer table
create or replace function ff_miles_lookup
(
    passenger_id_param      frequent_flyer_profile.passenger_id%type
)
return number
as
    miles_balance_var       number;
begin
    select miles_balance
    into miles_balance_var
    from frequent_flyer_profile
    where passenger_id = passenger_id_param;
    
    return miles_balance_var;
end;
/

-- select statement to test Q8
select first_name, last_name, ff_miles_lookup(passenger_id) as passenger_miles
from passenger;
