# Restaurant Reservations

Ruby on Rails API only project for Resturant reservations

Ruby version: 2.7.3
Rails version: 6.1.3.2

These APIs lets you reserve tables at restaurants, add different role users, and perform role based restricted activites. And has business logic appiled on reservations and tables based on a criteria.

#### How to run? This project is completely containarized, just use below, if you have docker:

1. Docker Compose:
  ```
  $ docker-compose up 
  ```
  ```
You can use postman collection to test and validate the APIs documentation

**Follow below steps for Admin API Calls**

1) Admin Login

2) Admin Can see all tables

3) Add a new table

4) Delete a table, but cannot delete a table if it has Reservation

5) Admin can see all tables, with pagination page by page and sort ascending or descending

6) Admin can see list of reservations for today and as well as in the past and future dates

7) Admin can add a reservation only for future time with selecting 
table based on number of customers, the table should have enough number of seats, Admin cannot reserve if there is a reservation on the time slot already

8) Admin can delete reservations only of the past, not of the future

9) Admin can add more users, Admin can add new admins and also add new employees

**Follow below steps for Employee API calls**

1) Employee Login

2) Employee can see list of reservations ONLY for today with Pagination page by page

3) Employee can add a reservation only for future time with selecting 
table based on number of customers, the table should have enough number of seats, Admin cannot reserve if there is a reservation on the time slot already

4) Employee can delete reservations only of the past, not of the future
