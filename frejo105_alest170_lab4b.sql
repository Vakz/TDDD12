DROP TABLE IF EXISTS Booking CASCADE;
DROP TABLE IF EXISTS PaymentInfo CASCADE;
DROP TABLE IF EXISTS OnReservation CASCADE;
DROP TABLE IF EXISTS Reservation CASCADE;
DROP TABLE IF EXISTS Flight CASCADE;
DROP TABLE IF EXISTS WeekSchedule CASCADE;
DROP TABLE IF EXISTS ProfitFactor CASCADE;
DROP TABLE IF EXISTS Day CASCADE;
DROP TABLE IF EXISTS Route CASCADE;
DROP TABLE IF EXISTS Destination CASCADE;
DROP TABLE IF EXISTS Contact CASCADE;
DROP TABLE IF EXISTS Passenger CASCADE;
DROP FUNCTION IF EXISTS calculatePrice;
DROP FUNCTION IF EXISTS calculateFreeSeats;
DROP FUNCTION IF EXISTS generateTicketNr;
DROP PROCEDURE IF EXISTS addYear;
DROP PROCEDURE IF EXISTS addDay;
DROP PROCEDURE IF EXISTS addDestination;
DROP PROCEDURE IF EXISTS addRoute;
DROP PROCEDURE IF EXISTS addFlight;
DROP TRIGGER IF EXISTS ticketTrigger;
DROP PROCEDURE IF EXISTS addReservation;
DROP PROCEDURE IF EXISTS addPassenger;
DROP PROCEDURE IF EXISTS addContact;
DROP PROCEDURE IF EXISTS addPayment;
DROP VIEW IF EXISTS allFlights;

CREATE TABLE Passenger(
	passnr Integer PRIMARY KEY,
    name VARCHAR(30) NOT NULL
);

CREATE TABLE Contact (
	passnr Integer PRIMARY KEY,
    email varchar(30) NOT NULL,
    phone BIGINT NOT NULL,

    CONSTRAINT FK_Contact_Passenger
    FOREIGN KEY (passnr) REFERENCES Passenger(passnr)
);

CREATE TABLE Destination (
	airportId varchar(3) PRIMARY KEY,
    name varchar(30) NOT NULL,
    country varchar(30) NOT NULL
);

CREATE TABLE Route (
	to_destination varchar(3),
    from_destination varchar(3),
    price Double NOT NULL,
    year Integer NOT NULL,

    CONSTRAINT PK_Route PRIMARY KEY (to_destination, from_destination, year),

    CONSTRAINT FK_Route_Destination_To
    FOREIGN KEY (to_destination) REFERENCES Destination(airportId),

    CONSTRAINT FK_Route_Destination_From
    FOREIGN KEY (from_destination) REFERENCES Destination(airportId)
);

CREATE TABLE Day (
	day ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL,
    factor Double NOT NULL,
    year Integer,

    CONSTRAINT PK_Day PRIMARY KEY (day, year)
);

CREATE TABLE ProfitFactor(
	year Integer PRIMARY KEY,
    factor double NOT NULL
);

CREATE TABLE WeekSchedule (
	id Integer PRIMARY KEY AUTO_INCREMENT,
    to_destination varchar(3) NOT NULL,
    from_destination varchar(3) NOT NULL,
    year Integer NOT NULL,
    day ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL,
    departure_time time NOT NULL,

    CONSTRAINT FK_WeekSchedule_Day
    FOREIGN KEY (day,year) REFERENCES Day(day,year),

    CONSTRAINT FK_WeekSchedule_Route
    FOREIGN KEY (to_destination,from_destination,year) REFERENCES Route(to_destination, from_destination, year),

    CONSTRAINT FK_WeekSchedule_ProfitFactor
    FOREIGN KEY (year) REFERENCES ProfitFactor(year)
);

CREATE TABLE Flight(
	flightnr Integer PRIMARY KEY AUTO_INCREMENT,
    schedule_id Integer NOT NULL,
    week Integer NOT NULL CHECK (week > 0 and week <= 52),

    CONSTRAINT FK_Flight_WeekSchedule
    FOREIGN KEY (schedule_id) REFERENCES WeekSchedule(id)
);

CREATE TABLE Reservation(
	id Integer PRIMARY KEY AUTO_INCREMENT,
    flightnr Integer NOT NULL,
    contact Integer,

    CONSTRAINT FK_Reservation_Flight
    FOREIGN KEY (flightnr) REFERENCES Flight(flightnr),

    CONSTRAINT FK_Reservation_Contant
    FOREIGN KEY (contact) REFERENCES Contact(passnr)
);

CREATE TABLE OnReservation(
	reservationnr Integer NOT NULL,
    passnr Integer NOT NULL,
    ticketnr Integer UNIQUE,

    CONSTRAINT FK_OnReservation_Reservation
    FOREIGN KEY (reservationnr) REFERENCES Reservation(id),

    CONSTRAINT FK_OnReservation_Passenger
    FOREIGN KEY (passnr) REFERENCES Passenger(passnr),

    CONSTRAINT PK_OnReservation
    PRIMARY KEY (reservationnr, passnr)
);

CREATE TABLE PaymentInfo(
	cardnr BIGINT PRIMARY KEY,
    name VARCHAR(30) NOT NULL
);

CREATE TABLE Booking(
	reservationnr Integer PRIMARY KEY,
    cardnr BIGINT NOT NULL,
    amount Integer NOT NULL,

    CONSTRAINT FK_Booking_Reservation
    FOREIGN KEY (reservationnr) REFERENCES Reservation(id),

    CONSTRAINT FK_Booking_PaymentInfo
    FOREIGN KEY (cardnr) REFERENCES PaymentInfo(cardnr)
);

delimiter //

CREATE FUNCTION calculateFreeSeats(flight Integer)
RETURNS Integer
BEGIN
	DECLARE seats Integer;

	SELECT COUNT(*) INTO seats FROM OnReservation
    WHERE reservationnr IN (SELECT id FROM Reservation WHERE Reservation.flightnr = flight) AND
    reservationnr IN (SELECT reservationnr FROM Booking AS b1);

    RETURN 40 - seats;
END;
//

CREATE FUNCTION calculatePrice(flight Integer)
RETURNS Double
BEGIN
	DECLARE scheduleid Integer;
	DECLARE routeprice Double;
    DECLARE dayfactor Double;
    DECLARE yearfactor Double;
    DECLARE seatfactor Double;

    SET seatfactor = (40 - calculateFreeSeats(flight) + 1) / 40;

    SELECT schedule_id INTO scheduleid FROM Flight WHERE Flight.flightnr = flight;

    SELECT price INTO routeprice FROM Route
    INNER JOIN WeekSchedule ON Route.from_destination = WeekSchedule.from_destination AND Route.to_destination = WeekSchedule.to_destination AND WeekSchedule.id = scheduleid AND WeekSchedule.year = Route.year;

    SELECT factor INTO dayfactor FROM Day
    INNER JOIN WeekSchedule ON WeekSchedule.id = scheduleid AND WeekSchedule.day = Day.day AND WeekSchedule.year = Day.year;

    SELECT factor INTO yearfactor FROM ProfitFactor
    INNER JOIN WeekSchedule ON WeekSchedule.year = ProfitFactor.year AND WeekSchedule.id = scheduleid;

    RETURN routeprice * dayfactor * yearfactor * seatfactor;

END;
//

CREATE PROCEDURE addYear(year Integer, factor Double)
BEGIN
	INSERT INTO ProfitFactor(year, factor) VALUES (year, factor);
END;
//

CREATE PROCEDURE addDay(year Integer, day varchar(10), factor Double)
BEGIN
	INSERT INTO Day(day, year, factor) VALUES (LCASE(day), year, factor);
END;
//

CREATE PROCEDURE addDestination(airport_code varchar(3), name varchar(30), country varchar(30))
BEGIN
	INSERT INTO Destination(airportId, name, country) VALUES (airport_code, name, country);
END;
//

CREATE PROCEDURE addRoute(departure_airport_code varchar(3), arrival_airport_code varchar(3), year Integer, routeprice Double)
BEGIN
	INSERT INTO Route(from_destination, to_destination, year, price) VALUES (departure_airport_code, arrival_airport_code, year, routeprice);
END;
//
CREATE PROCEDURE addFlight(departure_airport_code varchar(3), arrival_airport_code varchar(3), year Integer, day varchar(10), departure_time Time)
BEGIN
	DECLARE scheduleid Integer;
    DECLARE counter Integer DEFAULT 1;
    DECLARE weeks Integer Default 52;
	INSERT INTO WeekSchedule(to_destination, from_destination, year, day, departure_time) VALUES (arrival_airport_code, departure_airport_code, year, day, departure_time);
    SELECT last_insert_id() into scheduleid;

    WHILE counter <= weeks DO
		INSERT INTO Flight (schedule_id, week) VALUES (scheduleid, counter);
        SET counter = counter + 1;
    END WHILE;
END;
//

CREATE FUNCTION generateTicketNr()
RETURNS Integer
BEGIN
	DECLARE ID Integer;
	LOOP
		SET ID = FLOOR(RAND()*1000000000);
        IF NOT EXISTS (SELECT ticketnr FROM OnReservation WHERE ticketnr = ID) THEN
			RETURN ID;
        END IF;
    END LOOP;
END;
//

CREATE TRIGGER ticketTrigger AFTER INSERT ON Booking FOR EACH ROW
BEGIN
    UPDATE OnReservation
    SET ticketnr = generateTicketNr()
    WHERE reservationnr = NEW.reservationnr;
END;
//

CREATE PROCEDURE addReservation(departure_airport_code varchar(3), arrival_airport_code varchar(3), year Integer, week Integer, day varchar(10), time Time, number_of_passengers Integer, OUT output_reservation_number Integer)
BEGIN
	DECLARE scheduleid Integer;
    DECLARE flight Integer;

    SELECT id INTO scheduleid FROM WeekSchedule
    WHERE WeekSchedule.from_destination = departure_airport_code AND WeekSchedule.to_destination = arrival_airport_code AND WeekSchedule.year = year
    AND WeekSchedule.day = day AND WeekSchedule.departure_time = time;

    SELECT flightnr INTO flight FROM Flight WHERE Flight.schedule_id = scheduleid AND Flight.week = week;

    IF scheduleid IS NULL OR flight IS NULL THEN
		SELECT "There exist no flight for the given route, date and time" AS Message;
    ELSEIF number_of_passengers > calculateFreeSeats(flight) THEN
		SELECT "There are not enough seats available on the chosen flight" AS Message;
    ELSE
		INSERT INTO Reservation (flightnr) VALUES (flight);
        SET output_reservation_number = last_insert_id();
    END IF;
END;
//

CREATE PROCEDURE addPassenger(reservation_nr Integer, passport_number Integer, name varchar(30))
BEGIN

	INSERT IGNORE INTO Passenger (passnr, name) VALUES (passport_number, name);

    IF NOT EXISTS (SELECT * FROM Reservation WHERE id = reservation_nr) THEN
		SELECT "The given reservation number does not exist" AS Message;
	ELSEIF EXISTS (SELECT * FROM Booking WHERE reservationnr = reservation_nr) THEN
		SELECT "The booking has already been payed and no futher passengers can be added" AS Message;
	ELSE
		INSERT INTO OnReservation (reservationnr, passnr) VALUES (reservation_nr, passport_number);
    END IF;
END;
//

CREATE PROCEDURE addContact(reservation_nr Integer, passport_number Integer, email varchar(30), phone BIGINT)
BEGIN
	IF NOT EXISTS (SELECT * FROM Reservation WHERE id = reservation_nr) THEN
		SELECT "The given reservation number does not exist" AS Message;
	ELSEIF NOT EXISTS (SELECT * FROM OnReservation WHERE OnReservation.reservationnr = reservation_nr AND OnReservation.passnr = passport_number) THEN
		SELECT "The person is not a passenger of the reservation" AS Message;
	ELSE
		INSERT IGNORE INTO Contact(passnr, email, phone) VALUES (passport_number, email, phone);
        UPDATE Reservation SET contact = passport_number WHERE Reservation.id = reservation_nr;
    END IF;
END;
//

CREATE PROCEDURE addPayment(reservation_nr Integer, cardholder_name varchar(30), credit_card_number BIGINT)
BEGIN
	DECLARE passengers Integer;
	DECLARE flight Integer;

	IF NOT EXISTS (SELECT * FROM Reservation WHERE id = reservation_nr) THEN
		SELECT "The given reservation number does not exist" AS Message;
	ELSEIF ISNULL((SELECT contact FROM Reservation WHERE id = reservation_nr)) THEN
		SELECT "The reservation has no contact yet" AS Message;
	ELSEIF EXISTS (SELECT * FROM Booking WHERE reservationnr = reservation_nr) THEN
		SELECT "The booking has already been payed" AS Message;
	ELSE

		INSERT IGNORE INTO PaymentInfo (cardnr, name) VALUES (credit_card_number, cardholder_name);

		SELECT flightnr INTO flight FROM Reservation WHERE Reservation.id = reservation_nr;
		SELECT COUNT(*) INTO passengers FROM OnReservation WHERE OnReservation.reservationnr = reservation_nr;

		IF passengers > calculateFreeSeats(flight) THEN
			DELETE FROM OnReservation WHERE reservationnr = reservation_nr;
			DELETE FROM Reservation WHERE id = reservation_nr;
			SELECT "There are not enough seats available on the flight anymore, deleting reservation" as Message;
		ELSE
			INSERT INTO Booking (reservationnr, cardnr, amount) VALUES (reservation_nr, credit_card_number, calculatePrice(flight));
		END IF;
    END IF;
END;
//

delimiter ;

CREATE VIEW allFlights AS
SELECT f.name AS departure_city_name, t.name AS destination_city_name, WeekSchedule.departure_time AS departure_time, WeekSchedule.day AS departure_day, Flight.week AS departure_week, WeekSchedule.year AS departure_year, calculateFreeSeats(Flight.flightnr) AS nr_of_free_seats, calculatePrice(Flight.flightnr) AS current_price_per_seat
FROM Flight
INNER JOIN WeekSchedule ON Flight.schedule_id = WeekSchedule.id
INNER JOIN Route ON WeekSchedule.to_destination = Route.to_destination AND WeekSchedule.from_destination = Route.from_destination AND WeekSchedule.year = Route.year
INNER JOIN Destination AS t ON Route.to_destination = t.airportId
INNER JOIN Destination AS f ON Route.from_destination = f.airportId;

/* ------------------------------------- THEORY QUESTIONS ----------------------------------------
-- 8a
The basic thing to do would be to encrypt the credit card numbers, and keep encryption keys separate. That way, it would require a higher level of access
in order to get the keys. The second thing to do would be to use more than one "user" to access the database, having a separate login for payment information.

-- 8b
The major reason is so that the client cannot change the query. If, on the client side, there is the statement "SELECT * FROM table", it would be simple for the user to change it to "DROP TABLE table".
The second big reason is that it gives access control. Through procedures, we can be specific in what information the client can access. It would, for example, restrict the user to only insert data into
tables which can be accessed through the correct procedures, and update data in a controlled way.
The third reason is that we can verify what is put into the database. While we can do simple verifications like having an integer be within a certain range with a CHECK constraint,
with a procedure we can do more complex verifications, such as only allowing bookings on a plane if there are free seats.


-- 9a
Added reservation, received ID with 3

-- 9b
Reservation is not visible in session B. This should be because the the reservation is not actually "added", from the point of view of other sessions, until after the transaction has been commited.

-- 9c
Session B gets locked. This is because the tuple is write-locked until the transaction is commited (isolation of transactions). Eventually, the query times out.

-- 10a
No overbooking occured. One session (Session A, in our case, which was started last), was denied. This was because when session A was trying to pay, session B had already booked 21 seats, and so not enough seats
were available for session A.

-- 10b
Yes. If both session have passed the last IF, on line 316, before either sessions have payed, then overbooking will occur.

-- 10c
Adding a SELECT sleep(5); inside the ELSE, on row 320, will cause overbooking.

-- 10d
This worked:
LOCK TABLES Booking WRITE, Booking AS b1 READ, OnReservation WRITE, Reservation WRITE, PaymentInfo WRITE, WeekSchedule READ, Day READ, Route READ, ProfitFactor READ, Flight READ;
CALL addPayment (@a, "Sauron",7878787878);
UNLOCK TABLES;

The reason for the Booking AS b1 READ is because the subquery in calculateFreeSeats creates a temporary table, which must be locked.

-- SECONDARY INDEX
As foreign keys are already indexed, we feel that the most useful index would be for week in Flight. This could possibly be used to search for
"last minute" Flights, and could also be used in order to check whats available for specific dates, such as during someones vacation.

ALTER TABLE Flight ADD INDEX (week);

*/
