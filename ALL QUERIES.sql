CREATE DATABASE SON_HAZIRLIKLAR;
USE SON_HAZIRLIKLAR;

#DROP DATABASE SON_HAZIRLIKLAR;
CREATE TABLE AIRPORT (
    Airport_code VARCHAR(3) NOT NULL,
    Airport_name VARCHAR(30) NOT NULL,
    City VARCHAR(20) NOT NULL,
    State VARCHAR (20) NOT NULL ,
    PRIMARY KEY (Airport_code)
);

CREATE TABLE AIRLINE(
    Airline_id INT unsigned NOT NULL,
    Airline_name VARCHAR(20) NOT NULL,
    Address VARCHAR(50) NOT NULL,
    Number_of_airplanes INT UNSIGNED NOT NULL DEFAULT 0,
    Airline_code VARCHAR(3) NOT NULL UNIQUE ,
    PRIMARY KEY (Airline_id)
);

CREATE TABLE FACTORY(
    Factory_id INT UNSIGNED NOT NULL ,
    Factory_name VARCHAR(20) NOT NULL UNIQUE,
    Address VARCHAR(50) NOT NULL,
    PRIMARY KEY (Factory_id)
);

CREATE TABLE AIRPLANE_TYPE (
    Airplane_type_name VARCHAR(30) NOT NULL,
    Max_seats INT UNSIGNED NOT NULL,
    Company_name VARCHAR (20) NOT NULL ,
    PRIMARY KEY (Airplane_type_name),
    FOREIGN KEY (Company_name) REFERENCES  FACTORY (Factory_name) ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (Max_seats <= 615 AND Max_seats >= 1)
);

CREATE TABLE AIRPLANE (
    Airplane_id VARCHAR(6) NOT NULL,
    Total_number_of_seats INT UNSIGNED NOT NULL,
    Airplane_type VARCHAR(20) NOT NULL,
    Airline_code VARCHAR(3) , 
    PRIMARY KEY (Airplane_id),
    FOREIGN KEY (Airplane_type) REFERENCES AIRPLANE_TYPE (Airplane_type_name) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Airline_code) REFERENCES AIRLINE (Airline_code) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE CAN_LAND (
    Airplane_type_name VARCHAR(30) NOT NULL,
    Airport_code VARCHAR(3) NOT NULL, 
    PRIMARY KEY (Airplane_type_name,Airport_code),
    FOREIGN KEY (Airplane_type_name) REFERENCES AIRPLANE_TYPE (Airplane_type_name) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Airport_code) REFERENCES AIRPORT (Airport_code) ON DELETE CASCADE ON UPDATE CASCADE
);
#drop table flight;
CREATE TABLE FLIGHT (
    Flight_number VARCHAR(6) NOT NULL,
    Airline_code VARCHAR(3) NOT NULL,
    Weekdays VARCHAR(20) NOT NULL,
    PRIMARY KEY (Flight_number),
    FOREIGN KEY (Airline_code) REFERENCES AIRLINE (Airline_code) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE FLIGHT_LEG(
    Flight_number VARCHAR(6) NOT NULL,
    Leg_number INT UNSIGNED NOT NULL,
    Departure_airport_code VARCHAR(3) NOT NULL,
    Arrival_airport_code VARCHAR(3) NOT NULL,
    Scheduled_departure_time DATETIME NOT NULL,
    Scheduled_arrive_time DATETIME NOT NULL,
    Mileage INT UNSIGNED NOT NULL ,
    PRIMARY KEY (Flight_number, Leg_number),
    FOREIGN KEY (Flight_number) REFERENCES FLIGHT (Flight_number) ON DELETE CASCADE ON UPDATE CASCADE, 
    FOREIGN KEY (Arrival_airport_code) REFERENCES AIRPORT (Airport_code) ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (Departure_airport_code) REFERENCES AIRPORT (Airport_code) ON DELETE RESTRICT ON UPDATE RESTRICT
);
#drop table flight;
CREATE TABLE LEG_INSTANCE(
    Flight_number VARCHAR(6) NOT NULL,
    Leg_number INT UNSIGNED NOT NULL,
    Flight_date DATE NOT NULL,
    Departure_airport_code VARCHAR(3) NOT NULL DEFAULT "",
    Arrival_airport_code VARCHAR(3) NOT NULL DEFAULT "",
    Departure_time DATETIME NOT NULL,
    Arrive_time DATETIME NOT NULL,
    Airplane_id VARCHAR(6) NOT NULL,
    Number_of_available_seats INT UNSIGNED NOT NULL DEFAULT 1,
    PRIMARY KEY (Flight_number, Leg_number,Flight_date),
    FOREIGN KEY (Flight_number,Leg_number) REFERENCES FLIGHT_LEG (Flight_number,Leg_number) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Arrival_airport_code) REFERENCES AIRPORT (Airport_code) ON UPDATE RESTRICT ON DELETE RESTRICT ,
    FOREIGN KEY (Departure_airport_code) REFERENCES AIRPORT (Airport_code) ON UPDATE RESTRICT ON DELETE RESTRICT  ,
    FOREIGN KEY (Airplane_id) REFERENCES AIRPLANE (Airplane_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE FARE (
    Flight_number VARCHAR(6) NOT NULL,
    Fare_code VARCHAR(1) NOT NULL,
    Amount DOUBLE NOT NULL,
    Restrictions VARCHAR(100) NOT NULL,
    PRIMARY KEY (Flight_number,Fare_code),
    FOREIGN KEY (Flight_number) REFERENCES FLIGHT(Flight_number) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE CUSTOMER(
    Passport_number VARCHAR(10) NOT NULL,
    Customer_name VARCHAR (30) NOT NULL,
    Customer_phone VARCHAR (20) NOT NULL,
    Email VARCHAR(35) NOT NULL,
    Address VARCHAR(100) NOT NULL,
    Country VARCHAR(20) NOT NULL,
    PRIMARY KEY (Passport_number)
);
CREATE TABLE SEAT_RESERVATION(
    Flight_number VARCHAR(6) NOT NULL,
    Leg_number INT UNSIGNED NOT NULL,
    Flight_date DATE NOT NULL,
    Seat_number varchar(5) NOT NULL,
    Passport_number varchar(9) NOT NULL,
    PRIMARY KEY (Flight_number,Leg_number,Flight_date,Seat_number),
    FOREIGN KEY (Flight_number,Leg_number,Flight_date) REFERENCES LEG_INSTANCE(Flight_number,Leg_number,Flight_date) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Passport_number) REFERENCES CUSTOMER(Passport_number) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE CHECKED_IN(
    Flight_number VARCHAR(6) NOT NULL,
    Leg_number INT UNSIGNED NOT NULL,
    Flight_date DATE NOT NULL,
    Seat_number varchar(5) NOT NULL,
    Passport_number varchar(9) NOT NULL,
    Departure_airport_code VARCHAR(3) NOT NULL DEFAULT "",
    Arrival_airport_code VARCHAR(3) NOT NULL,
    Departure_time DATETIME NOT NULL,
    Arrival_time DATETIME NOT NULL,
    Mileage INT UNSIGNED NOT NULL,
    PRIMARY KEY (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number),
    FOREIGN KEY (Flight_number,Leg_number,Flight_date) REFERENCES LEG_INSTANCE(Flight_number,Leg_number,Flight_date) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Passport_number) REFERENCES CUSTOMER(Passport_number) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Departure_airport_code) REFERENCES AIRPORT(Airport_code) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Arrival_airport_code) REFERENCES AIRPORT(Airport_code) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE FFC(
	Passport_number varchar(9) NOT NULL,
    Total_mileage_point INT NOT NULL DEFAULT 0,
    Segment varchar(3) DEFAULT "",
    PRIMARY KEY (Passport_number),
    FOREIGN KEY (Passport_number) REFERENCES CUSTOMER(Passport_number)
);



-- Uçuş tarihi şimdiki zamandan ileri bir tarihte olmalı.

DELIMITER $$
CREATE TRIGGER date_check
BEFORE INSERT ON LEG_INSTANCE
FOR EACH ROW
BEGIN
IF NEW.Flight_date <= CURDATE() AND DATE(NEW.Departure_time) <= NEW.Flight_date THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid date!';
END IF;
END$$
DELIMITER ;


--  Geçerli bir uçuş kaydı için kullanılacak uçak tipinin iki hava yolunda da
-- konaklayabilir olması gerekmektedir.

DELIMITER $$
CREATE TRIGGER can_land_check
BEFORE INSERT ON LEG_INSTANCE
FOR EACH ROW
BEGIN
DECLARE type_of_airplane VARCHAR(20);
SELECT Airplane_type
    INTO type_of_airplane
    FROM AIRPLANE WHERE Airplane_id = NEW.Airplane_id;
IF type_of_airplane NOT IN 
(SELECT Airplane_type_name FROM CAN_LAND WHERE Airport_code = NEW.Departure_airport_code)  or 
type_of_airplane NOT IN (SELECT Airplane_type_name FROM CAN_LAND WHERE Airport_code = NEW.Arrival_airport_code) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "The airplane is can't land at these airports!";
END IF;
END$$
DELIMITER ;


/* 3. Bir uçağın koltuk sayısı o uçağın tipindeki uçakların 
koltuk sayılarından büyük olamaz.*/

DELIMITER $$
CREATE TRIGGER airplane_type_max_seat_number_check
BEFORE INSERT ON AIRPLANE
FOR EACH ROW
BEGIN
	DECLARE max_seat INT;
    SELECT Max_seats
    INTO max_seat
    FROM AIRPLANE_TYPE WHERE Airplane_type_name = NEW.Airplane_type;
    IF NEW.Total_number_of_seats > max_seat THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid total seat number!';
	END IF;
END$$
DELIMITER ;

/*4. Müşteri check in yaptığında uçuşun kilometre bilgisini alarak FFC
tablosunundaki toplam mil puanını arttırır.*/

DELIMITER $$
CREATE TRIGGER update_mileage
    AFTER INSERT
    ON CHECKED_IN FOR EACH ROW
BEGIN
    DECLARE oldMilage INT;
    SELECT Total_mileage_point 
    INTO oldMilage
    FROM FFC WHERE Passport_number = NEW.Passport_number;
    UPDATE FFC SET Total_mileage_point = oldMilage + NEW.Mileage WHERE Passport_number = NEW.Passport_number;
END$$    
DELIMITER ;

/* 5. Check-in yapan müşterinin uçuş bilgilerini CHECKED_IN tablosuna ekliyoruz.*/

DELIMITER $$
CREATE TRIGGER get_flight_infos
    BEFORE INSERT
    ON CHECKED_IN FOR EACH ROW
BEGIN
   SET NEW.Departure_airport_code = (
   SELECT Departure_airport_code 
   from LEG_INSTANCE
   where Flight_number = NEW.Flight_number AND
    Leg_number = NEW.Leg_number AND
    Flight_date = NEW.Flight_date);
    
	SET NEW.Arrival_airport_code = (
   SELECT Arrival_airport_code 
   from LEG_INSTANCE 
   where Flight_number = NEW.Flight_number AND
    Leg_number = NEW.Leg_number AND
    Flight_date = NEW.Flight_date);
    
    SET NEW.Arrival_time = (
   SELECT Arrive_time 
   from LEG_INSTANCE 
   where Flight_number = NEW.Flight_number AND
    Leg_number = NEW.Leg_number AND
    Flight_date = NEW.Flight_date);
    SET NEW.Departure_time = (
   SELECT Departure_time 
   from LEG_INSTANCE 
   where Flight_number = NEW.Flight_number AND
    Leg_number = NEW.Leg_number AND
    Flight_date = NEW.Flight_date);
    SET NEW.Mileage = (
   SELECT Mileage 
   from FLIGHT_LEG 
   where Flight_number = NEW.Flight_number AND
    Leg_number = NEW.Leg_number );
END$$    
DELIMITER ;



/* 6. Müşteri rezervasyon yaptırmadan önce müsait koltuk durumuna bakılır. Eğer
uygun koltuk varsa uygun koltuk sayısı bir azaltılır yoksa hata mesajı verilir. */ 

DELIMITER $$
CREATE TRIGGER leg_instance_available_seat_number_check
BEFORE INSERT ON SEAT_RESERVATION
FOR EACH ROW
BEGIN
	DECLARE available_seat INT;
    SELECT Number_of_available_seats
    INTO available_seat
    FROM LEG_INSTANCE 
    WHERE 
    Flight_number = NEW.Flight_number AND
    Leg_number = NEW.Leg_number AND
    Flight_date = NEW.Flight_date;
    IF available_seat = 0 THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There is no available seat for this leg instance!';
    ELSE
    UPDATE LEG_INSTANCE SET  Number_of_available_seats = available_seat - 1
    WHERE 
    Flight_number = NEW.Flight_number AND
    Leg_number = NEW.Leg_number AND
    Flight_date = NEW.Flight_date;
	END IF;
END$$
DELIMITER ;


/* 7. Yapılan rezervasyon silindiğinde uçuştaki uygun koltuk sayısı 1 arttırılmalıdır. */ 

DELIMITER $$
CREATE TRIGGER after_reservation_delete
AFTER DELETE
ON SEAT_RESERVATION FOR EACH ROW
BEGIN
	DECLARE available_seat INT;
    SELECT Number_of_available_seats
    INTO available_seat
    FROM LEG_INSTANCE 
    WHERE 
    Flight_number = OLD.Flight_number AND
    Leg_number = OLD.Leg_number AND
    Flight_date = OLD.Flight_date;
    
    UPDATE LEG_INSTANCE SET  Number_of_available_seats = available_seat + 1
    WHERE 
    Flight_number = OLD.Flight_number AND
    Leg_number = OLD.Leg_number AND
    Flight_date = OLD.Flight_date;
	
END$$
DELIMITER ;


/* 8. Her müşteri eklendiğinde o müşteriye ait pasaport numarasıyla birlikte bir
FFC kaydı oluşturulur. */

DELIMITER $$
CREATE TRIGGER create_ffc
    AFTER INSERT
    ON CUSTOMER FOR EACH ROW
BEGIN
	INSERT INTO FFC (Passport_number) VALUES (NEW.Passport_number);
END$$    
DELIMITER ;

/* 9. Sisteme herhangi bir uçak kaydı eklendiğinde o uçağa ait şirketin uçak sayısı 1
arttırılmaktadır. */

DELIMITER $$
CREATE TRIGGER update_airplane_number
    AFTER INSERT
    ON AIRPLANE FOR EACH ROW
BEGIN
	DECLARE oldNumber INT;
    SELECT Number_of_airplanes
    INTO oldNumber
    FROM AIRLINE 
    WHERE 
    Airline_code = NEW.Airline_code;
	UPDATE AIRLINE SET Number_of_airplanes = oldNumber + 1 WHERE Airline_code = NEW.Airline_code;
END$$    
DELIMITER ;



/* 10. Bir şirkete bağlu uçak kaydı silindiğinde o şirketin toplam uçak sayısı 1
       azaltılmaktadır.*/ 

DELIMITER $$
CREATE TRIGGER update_airplane_number_2
    AFTER DELETE
    ON AIRPLANE FOR EACH ROW
BEGIN
	DECLARE oldNumber INT;
    SELECT Number_of_airplanes
    INTO oldNumber
    FROM AIRLINE 
    WHERE 
    Airline_code = OLD.Airline_code;
    IF oldNumber = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There is zero airplane at this airline!';
    ELSE
	UPDATE AIRLINE SET Number_of_airplanes = oldNumber - 1 WHERE Airline_code = OLD.Airline_code;
    END IF;
END$$    
DELIMITER ;


/* 11. LEG_INSTANCE tablosuna bir kayıt eklenmeden önce o uçuşa ait uygun
koltuk sayısına, uçuşu yapacak uçağın toplam koltuk sayısı atanır.*/

DELIMITER $$
CREATE TRIGGER number_of_seats 
BEFORE INSERT ON LEG_INSTANCE
FOR EACH ROW
BEGIN
	SET NEW.Number_of_available_seats = (SELECT Total_number_of_seats from AIRPLANE where Airplane_id= NEW.Airplane_id);
END$$
DELIMITER ;




ALTER TABLE LEG_INSTANCE
ADD Constraint Date_Check_LI
CHECK(Departure_time < Arrive_time);

ALTER TABLE FLIGHT_LEG
ADD Constraint Date_Check_FL
CHECK(Scheduled_departure_time  < Scheduled_arrive_time );

ALTER TABLE FARE
ADD Constraint Amount_Check
CHECK (Amount >= 0);

ALTER TABLE FARE
ADD Constraint Code_Check
CHECK (Fare_code = "F" OR Fare_code = "J" OR Fare_code = "Y" );

ALTER TABLE LEG_INSTANCE
ADD CONSTRAINT Flight_Seat_Check
CHECK (Number_of_available_seats >= 0);

ALTER TABLE FLIGHT_LEG
ADD Constraint Airport_Check_FL
CHECK(Departure_airport_code!=Arrival_airport_code);

ALTER TABLE LEG_INSTANCE
ADD Constraint Airport_Check_LI
CHECK(Departure_airport_code!=Arrival_airport_code);

Alter table CUSTOMER
ADD Constraint Passport_number_check
CHECK  (LENGTH(Passport_number) BETWEEN 7 and 9);

INSERT INTO AIRPORT(Airport_code,Airport_name,City,State) VALUES("SAW","Sabiha Gökçen Airport","Istanbul","Public");
INSERT INTO AIRPORT(Airport_code,Airport_name,City,State) VALUES("ADB","Adnan Menderes Airport","Izmir","Public");
INSERT INTO AIRPORT(Airport_code,Airport_name,City,State) VALUES("USQ","Uşak Airport","Usak","Public");
INSERT INTO AIRPORT(Airport_code,Airport_name,City,State) VALUES("KZR","Zafer Airport ","Kutahya","Public");
INSERT INTO AIRPORT(Airport_code,Airport_name,City,State) VALUES("ISL","Atatürk Airport","Istanbul","Public");
INSERT INTO AIRPORT(Airport_code,Airport_name,City,State) VALUES("ERZ","Erzurum Airport","Erzurum","Public");
INSERT INTO AIRPORT(Airport_code,Airport_name,City,State) VALUES("ESB","Esenboğa Airport","Ankara","Public");
INSERT INTO AIRPORT(Airport_code,Airport_name,City,State) VALUES("YEI","Bursa Airport","Bursa","Public");
INSERT INTO AIRPORT(Airport_code,Airport_name,City,State) VALUES("DLM","Dalaman Airport","Mugla","Public");
INSERT INTO AIRPORT(Airport_code,Airport_name,City,State) VALUES("GZT","Gaziantep Airport","Gaziantep","Public");

INSERT INTO FACTORY (Factory_id,Factory_name,Address) VALUES (789052719,"Airbus","Toulouse,Fransa");
INSERT INTO FACTORY  VALUES (862795626,"Boeing","Chicago,ABD");
INSERT INTO FACTORY  VALUES (059764289,"Bombardier","Wichita,Kansas,ABD");
INSERT INTO FACTORY  VALUES (278614098,"Douglas","Santa Monica, California,ABD");
INSERT INTO AIRLINE (Airline_id,Airline_name,Address,Airline_code)  VALUES  (249871359,"Turkish Airlines","İstanbul,Türkiye","THY");
INSERT INTO AIRLINE (Airline_id,Airline_name,Address,Airline_code) VALUES (179245063,"Anadolu Jet","Ankara,Türkiye","TK");
INSERT INTO AIRLINE (Airline_id,Airline_name,Address,Airline_code) VALUES (054795173,"Pegasus","İstanbul,Türkiye","PC");
INSERT INTO AIRLINE (Airline_id,Airline_name,Address,Airline_code) VALUES (047982417,"Sunexpress","Antalya,Türkiye","XQ");

INSERT INTO AIRPLANE_TYPE (Airplane_type_name,Max_seats,Company_name) VALUES ("Airbus A320",150,"Airbus");
INSERT INTO AIRPLANE_TYPE (Airplane_type_name,Max_seats,Company_name) VALUES ("Airbus A310",220,"Airbus");
INSERT INTO AIRPLANE_TYPE (Airplane_type_name,Max_seats,Company_name) VALUES ("Boeing 777",301,"Boeing");
INSERT INTO AIRPLANE_TYPE (Airplane_type_name,Max_seats,Company_name) VALUES ("Boeing 767-300",351,"Boeing");
INSERT INTO AIRPLANE_TYPE (Airplane_type_name,Max_seats,Company_name) VALUES ("Learjet 40",7,"Bombardier");
INSERT INTO AIRPLANE_TYPE (Airplane_type_name,Max_seats,Company_name) VALUES ("Douglas DC-2","14","Douglas");


INSERT INTO AIRPLANE VALUES ("N930NN",130,"Airbus A320","THY");
INSERT INTO AIRPLANE VALUES ("N973JM",150,"Airbus A320","PC");
INSERT INTO AIRPLANE VALUES ("N4216S",200,"Airbus A310","XQ");
INSERT INTO AIRPLANE VALUES ("N340LV",220,"Airbus A310","THY");
INSERT INTO AIRPLANE VALUES ("C-GTF0",250,"Boeing 777","XQ");
INSERT INTO AIRPLANE VALUES ("JA8089",300,"Boeing 777","TK");
INSERT INTO AIRPLANE VALUES ("N901CM",310,"Boeing 767-300","THY");
INSERT INTO AIRPLANE VALUES ("N7025U",350,"Boeing 767-300","PC");
INSERT INTO AIRPLANE VALUES ("JA5894",7,"Learjet 40","TK");
INSERT INTO AIRPLANE VALUES ("GS6464",10,"Douglas DC-2","TK");
INSERT INTO AIRPLANE VALUES ("GS4848",14,"Douglas DC-2","TK");



INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Airbus A320","SAW");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Airbus A320","ADB");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Airbus A320","USQ");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Airbus A320","KZR");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Airbus A320","ISL");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Airbus A320","DLM");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Airbus A320","GZT");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Airbus A320","ESB");

INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Airbus A310","SAW");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Airbus A310","DLM");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Airbus A310","GZT");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Airbus A310","ESB");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Airbus A310","ISL");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Airbus A310","ERZ");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Airbus A310","KZR");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Airbus A310","YEI");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Airbus A310","USQ");

INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Boeing 777","SAW");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Boeing 777","KZR");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Boeing 777","ESB");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Boeing 777","ADB");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Boeing 777","ISL");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Boeing 777","GZT");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Boeing 777","YEI");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Boeing 777","USQ");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Boeing 777","DLM");


INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Boeing 767-300","KZR");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Boeing 767-300","GZT");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Boeing 767-300","ISL");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Boeing 767-300","ESB");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Boeing 767-300","ERZ");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Boeing 767-300","ADB");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Boeing 767-300","SAW");

INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Learjet 40","ISL");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Learjet 40","KZR");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Learjet 40","GZT");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Learjet 40","ERZ");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Learjet 40","ADB");

INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Douglas DC-2","DLM");
INSERT INTO CAN_LAND (AIRPLANE_TYPE_NAME,AIRPORT_CODE) VALUES ("Douglas DC-2","USQ");

INSERT INTO FLIGHT (FLIGHT_NUMBER,AIRLINE_CODE,WEEKDAYS) VALUES ("DF2753","THY","PT CR CM");
INSERT INTO FLIGHT (FLIGHT_NUMBER,AIRLINE_CODE,WEEKDAYS) VALUES ("US4848","THY","PT CR CM");
INSERT INTO FLIGHT (FLIGHT_NUMBER,AIRLINE_CODE,WEEKDAYS) VALUES ("FU4864","THY","PT");
INSERT INTO FLIGHT (FLIGHT_NUMBER,AIRLINE_CODE,WEEKDAYS) VALUES ("TK2752","THY","PR CM CT PZ");
INSERT INTO FLIGHT VALUES ("FD5610","PC","PT SL CR PR CM");
INSERT INTO FLIGHT VALUES ("EN4267","PC","CT PZ");
INSERT INTO FLIGHT VALUES ("LN3211","PC","SL CM CT PZ");
INSERT INTO FLIGHT VALUES ("GT4638","XQ","PT CT");
INSERT INTO FLIGHT VALUES ("KV3323","TK","SL PR CT");
INSERT INTO FLIGHT VALUES ("LX3100","TK","PZ");




INSERT INTO FLIGHT_LEG (Flight_number,Leg_number,Departure_airport_code,Arrival_airport_code,Scheduled_departure_time,Scheduled_arrive_time,Mileage)
VALUES ("DF2753",901,"SAW","ADB",'2021-02-15 14:30:00','2021-02-15 16:00:00',350);
INSERT INTO FLIGHT_LEG (Flight_number,Leg_number,Departure_airport_code,Arrival_airport_code,Scheduled_departure_time,Scheduled_arrive_time,Mileage)
VALUES ("DF2753",911,"SAW","ADB",'2021-03-15 14:30:00','2021-03-15 16:00:00',350);
INSERT INTO FLIGHT_LEG (Flight_number,Leg_number,Departure_airport_code,Arrival_airport_code,Scheduled_departure_time,Scheduled_arrive_time,Mileage)
VALUES ("DF2753",921,"SAW","ADB",'2021-04-15 14:30:00','2021-04-15 16:00:00',350);
INSERT INTO FLIGHT_LEG (Flight_number,Leg_number,Departure_airport_code,Arrival_airport_code,Scheduled_departure_time,Scheduled_arrive_time,Mileage)
VALUES ("DF2753",907,"ESB","SAW",'2021-05-01 21:30:00','2021-05-01 22:30:00',221);

INSERT INTO FLIGHT_LEG (Flight_number,Leg_number,Departure_airport_code,Arrival_airport_code,Scheduled_departure_time,Scheduled_arrive_time,Mileage)
VALUES ("LN3211",902,"USQ","DLM",'2021-02-16 15:30:00','2021-02-16 16:45',325);

INSERT INTO FLIGHT_LEG (Flight_number,Leg_number,Departure_airport_code,Arrival_airport_code,Scheduled_departure_time,Scheduled_arrive_time,Mileage)
VALUES ("GT4638",903,"ISL","KZR",'2021-02-17 08:30:00','2021-02-17 09:45',250);
INSERT INTO FLIGHT_LEG (Flight_number,Leg_number,Departure_airport_code,Arrival_airport_code,Scheduled_departure_time,Scheduled_arrive_time,Mileage)
VALUES ("GT4638",908,"GZT","YEI",'2021-03-15 11:30:00','2021-03-15 13:30:00',221);
INSERT INTO FLIGHT_LEG (Flight_number,Leg_number,Departure_airport_code,Arrival_airport_code,Scheduled_departure_time,Scheduled_arrive_time,Mileage)
VALUES ("GT4638",998,"YEI","GZT",'2021-03-16 11:30:00','2021-03-16 13:30:00',221);

INSERT INTO FLIGHT_LEG (Flight_number,Leg_number,Departure_airport_code,Arrival_airport_code,Scheduled_departure_time,Scheduled_arrive_time,Mileage)
VALUES ("KV3323",904,"KZR","GZT",'2021-03-17 08:30:00','2021-03-17 10:30:00',195);
INSERT INTO FLIGHT_LEG (Flight_number,Leg_number,Departure_airport_code,Arrival_airport_code,Scheduled_departure_time,Scheduled_arrive_time,Mileage)
VALUES ("KV3323",704,"KZR","GZT",'2021-05-17 08:30:00','2021-05-17 10:30:00',195);

INSERT INTO FLIGHT_LEG (Flight_number,Leg_number,Departure_airport_code,Arrival_airport_code,Scheduled_departure_time,Scheduled_arrive_time,Mileage)
VALUES ("LX3100",905,"ADB","ISL",'2021-02-18 08:30:00','2021-02-18 09:40:00',440);

INSERT INTO FLIGHT_LEG (Flight_number,Leg_number,Departure_airport_code,Arrival_airport_code,Scheduled_departure_time,Scheduled_arrive_time,Mileage)
VALUES ("FD5610",906,"ERZ","USQ",'2021-03-01 21:30:00','2021-03-01 22:30:00',880);

INSERT INTO FLIGHT_LEG (Flight_number,Leg_number,Departure_airport_code,Arrival_airport_code,Scheduled_departure_time,Scheduled_arrive_time,Mileage)
VALUES ("EN4267",906,"ADB","USQ",'2021-03-05 21:30:00','2021-03-05 23:15:00',256);

INSERT INTO FLIGHT_LEG (Flight_number,Leg_number,Departure_airport_code,Arrival_airport_code,Scheduled_departure_time,Scheduled_arrive_time,Mileage)
VALUES ("FU4864",806,"USQ","DLM",'2021-03-25 11:30:00','2021-03-25 23:15:00',325);

DELETE FROM leg_instance;

INSERT INTO LEG_INSTANCE (Flight_number,Leg_number,Flight_date,Departure_airport_code,Arrival_airport_code,
Departure_time,Arrive_time,Airplane_id) VALUES 
("GT4638",903,"2021-02-17","ISL","KZR",'2021-02-17 08:30:00','2021-02-17 09:45',"N930NN");
INSERT INTO LEG_INSTANCE (Flight_number,Leg_number,Flight_date,Departure_airport_code,Arrival_airport_code,
Departure_time,Arrive_time,Airplane_id) VALUES 
("GT4638",908,"2021-03-15","GZT","YEI",'2021-03-15 11:30:00','2021-03-15 13:30:00',"C-GTF0");
INSERT INTO LEG_INSTANCE (Flight_number,Leg_number,Flight_date,Departure_airport_code,Arrival_airport_code,
Departure_time,Arrive_time,Airplane_id) VALUES 
("GT4638",998,"2021-03-16","YEI","GZT",'2021-03-16 11:30:00','2021-03-16 13:30:00',"JA8089");

INSERT INTO LEG_INSTANCE (Flight_number,Leg_number,Flight_date,Departure_airport_code,Arrival_airport_code,
Departure_time,Arrive_time,Airplane_id) VALUES 
("KV3323",904,"2021-03-17","KZR","GZT",'2021-03-17 08:30:00','2021-03-17 10:30:00',"N7025U");
INSERT INTO LEG_INSTANCE (Flight_number,Leg_number,Flight_date,Departure_airport_code,Arrival_airport_code,
Departure_time,Arrive_time,Airplane_id) VALUES 
("KV3323",704,"2021-05-17","KZR","GZT",'2021-05-17 08:45:00','2021-05-17 10:45:00',"N7025U");

INSERT INTO LEG_INSTANCE (Flight_number,Leg_number,Flight_date,Departure_airport_code,Arrival_airport_code,
Departure_time,Arrive_time,Airplane_id) VALUES 
("DF2753",907,"2021-05-01","ESB","SAW",'2021-02-17 23:30:00','2021-02-18 02:00:00',"N901CM");

INSERT INTO LEG_INSTANCE (Flight_number,Leg_number,Flight_date,Departure_airport_code,Arrival_airport_code,Departure_time,Arrive_time,Airplane_id)
 VALUES  ("DF2753",901,'2021-02-15 ',"SAW","ADB",'2021-02-15 14:30:00','2021-02-15 16:00:00',"JA8089");
INSERT INTO  LEG_INSTANCE (Flight_number,Leg_number,Flight_date,Departure_airport_code,Arrival_airport_code,Departure_time,Arrive_time,Airplane_id)
 VALUES  ("DF2753",911,'2021-03-15',"SAW","ADB",'2021-03-15 14:45:00','2021-03-15 16:15:00',"C-GTF0");
INSERT INTO LEG_INSTANCE (Flight_number,Leg_number,Flight_date,Departure_airport_code,Arrival_airport_code,Departure_time,Arrive_time,Airplane_id)
 VALUES  ("DF2753",921,'2021-04-15',"SAW","ADB",'2021-04-15 14:30:00','2021-04-15 16:00:00',"C-GTF0");

 
 INSERT INTO LEG_INSTANCE (Flight_number,Leg_number,Flight_date,Departure_airport_code,Arrival_airport_code,Departure_time,Arrive_time,Airplane_id)
 VALUES  ("LX3100",905,'2021-02-18',"ADB","ISL",'2021-02-18 08:30:00','2021-02-18 09:40:00',"N7025U");
 INSERT INTO LEG_INSTANCE (Flight_number,Leg_number,Flight_date,Departure_airport_code,Arrival_airport_code,Departure_time,Arrive_time,Airplane_id)
 VALUES  ("FD5610",906,'2021-03-01',"ERZ","USQ",'2021-03-01 21:30:00','2021-03-01 22:30:00',"N340LV");
INSERT INTO LEG_INSTANCE (Flight_number,Leg_number,Flight_date,Departure_airport_code,Arrival_airport_code,Departure_time,Arrive_time,Airplane_id)
 VALUES  ("EN4267",906,'2021-03-05',"ADB","USQ",'2021-03-05 21:30:00','2021-03-05 23:15:00',"JA8089");
INSERT INTO LEG_INSTANCE (Flight_number,Leg_number,Flight_date,Departure_airport_code,Arrival_airport_code,Departure_time,Arrive_time,Airplane_id)
 VALUES  ("FU4864",806,'2021-03-25',"USQ","DLM",'2021-03-25 11:30:00','2021-03-25 23:15:00',"N930NN");
 
 
 
 
INSERT INTO FARE (FLIGHT_NUMBER,FARE_CODE,AMOUNT,RESTRICTIONS)  VALUES ("DF2753","F",750,"Refundable");
INSERT INTO FARE (FLIGHT_NUMBER,FARE_CODE,AMOUNT,RESTRICTIONS)  VALUES ("DF2753","J",550,"Non-refundable");
INSERT INTO FARE (FLIGHT_NUMBER,FARE_CODE,AMOUNT,RESTRICTIONS)  VALUES ("DF2753","Y",300,"Non-refundable");
INSERT INTO FARE (FLIGHT_NUMBER,FARE_CODE,AMOUNT,RESTRICTIONS)  VALUES ("LN3211","F",625,"Non-refundable");
INSERT INTO FARE (FLIGHT_NUMBER,FARE_CODE,AMOUNT,RESTRICTIONS)  VALUES ("LN3211","Y",205,"Non-refundable");
INSERT INTO FARE (FLIGHT_NUMBER,FARE_CODE,AMOUNT,RESTRICTIONS)  VALUES ("GT4638","J",450,"Non-refundable");
INSERT INTO FARE (FLIGHT_NUMBER,FARE_CODE,AMOUNT,RESTRICTIONS)  VALUES ("GT4638","Y",210,"Non-refundable");
INSERT INTO FARE (FLIGHT_NUMBER,FARE_CODE,AMOUNT,RESTRICTIONS)  VALUES ("KV3323","J",425,"Non-refundable");
INSERT INTO FARE (FLIGHT_NUMBER,FARE_CODE,AMOUNT,RESTRICTIONS)  VALUES ("LX3100","Y",250,"Non-refundable");
INSERT INTO FARE (FLIGHT_NUMBER,FARE_CODE,AMOUNT,RESTRICTIONS)  VALUES ("LX3100","J",550,"Refundable");
INSERT INTO FARE (FLIGHT_NUMBER,FARE_CODE,AMOUNT,RESTRICTIONS)  VALUES ("FD5610","Y",175,"Refundable");
INSERT INTO FARE (FLIGHT_NUMBER,FARE_CODE,AMOUNT,RESTRICTIONS)  VALUES ("EN4267","J",480,"Refundable");
INSERT INTO FARE (FLIGHT_NUMBER,FARE_CODE,AMOUNT,RESTRICTIONS)  VALUES ("TK2752","Y",140,"Refundable");
INSERT INTO FARE (FLIGHT_NUMBER,FARE_CODE,AMOUNT,RESTRICTIONS)  VALUES ("LN3211","J",350,"Refundable");
INSERT INTO FARE (FLIGHT_NUMBER,FARE_CODE,AMOUNT,RESTRICTIONS)  VALUES ("FU4864","J",500,"Non-refundable");


DESCRIBE CUSTOMER;

INSERT INTO FLIGHT (FLIGHT_NUMBER,AIRLINE_CODE,WEEKDAYS) VALUES ("DF2755","PC","PT CR CM");
INSERT INTO FLIGHT_LEG (Flight_number,Leg_number,Departure_airport_code,Arrival_airport_code,Scheduled_departure_time,Scheduled_arrive_time,Mileage)
VALUES ("DF2755",901,"ADB","SAW",'2021-02-15 14:30:00','2021-02-15 16:00:00',350);
INSERT INTO LEG_INSTANCE (Flight_number,Leg_number,Flight_date,Departure_airport_code,Arrival_airport_code,Departure_time,Arrive_time,Airplane_id) VALUES  ("DF2755",901,"2021-02-15","ADB","SAW",'2021-02-15 14:30:00','2021-02-15 16:00:00',"JA8089");
INSERT INTO LEG_INSTANCE (Flight_number,Leg_number,Flight_date,Departure_airport_code,Arrival_airport_code,Departure_time,Arrive_time,Airplane_id) VALUES  ("DF2755",901,"2021-02-17","ADB","SAW",'2021-02-17 14:30:00','2021-02-17 16:00:00',"JA8089");
INSERT INTO LEG_INSTANCE (Flight_number,Leg_number,Flight_date,Departure_airport_code,Arrival_airport_code,Departure_time,Arrive_time,Airplane_id) VALUES  ("DF2755",901,"2021-02-19","ADB","SAW",'2021-02-19 14:30:00','2021-02-19 16:00:00',"JA8089");


DELETE FROM CUSTOMER;
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES("U00005001","Kerem Erkinsoy","5369874123","kerem@gmail.com","Usak","Turkiye");
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES("U00005002","İbrahim Kale","5055448210","ibo@gmail.com","Samsun","Turkiye");
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES("U00005003","Lokman Hekim","5055446515","loki@gmail.com","Konya","Turkiye");
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES("U00005004","Aybars Aydın","5545447810","ibo@gmail.com","Eskisehir","Turkiye");
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES("U00005005","Taylan Tufan","5545447810","tt@gmail.com","Alanya","Turkiye");
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES("U00005006","Halil Toprak","50519074586","tt@gmail.com","Izmır","Turkiye");

INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES ("U00005007","Özge Buyukasik","905414778681","o.b@g.com","Izmır","Turkiye");
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES ("U00005008","Ramazan Tas","905414778682","r.t@g.com","Usak","Turkiye");
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES ("U00005009","Sabri Gulseven","905414778683","s.g@g.com","Bursa","Turkiye");
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES ("U00005010","Hasan Tahsin","905414778684","h.t@g.com","Izmır","Turkiye");
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES ("U00005011","Ibrahim Afellay","4440444","i.a@g.com","Amsterdam","Hollanda");
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES ("U00005012","Gorkem Aktas","905414778686","g.a@g.com","Ankara","Turkiye");
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES ("U00005013","Emre Karagun","5414778687","e.k@g.com","Istanbul","Turkiye");
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES ("U00005014","Cristiano Pele","2245671052","c.p@g.com","Lizbon","Portekiz");
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES("U00005015","EMRE DURSUN","5369874123","emre@gmail.com","Izmır","Turkiye");
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES("U00005016","KEREM ARIKÇILI","5369874126","kerem1@gmail.com","hatay","Turkiye");
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country)
 VALUES("U00005017","MELİKE GÜNAS","5369875372","melike@gmail.com","Kutahya","Turkiye");
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES("U00005018","MUSTAFA OKUTAN","5369874320","mustafa@gmail.com","bursa","Turkiye");
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES("U00005019","DENİZ YILDIZ","5369873453","deniz@gmail.com","Ankara","Turkiye");
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES("U00005020","EMRE BELEZOĞLU","5369877602","emreb@gmail.com","Istanbul","Turkiye");
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES("U00005021","MEHMET YEŞİL","536265897","mehmet@gmail.com","adana","Turkiye");
INSERT INTO CUSTOMER (Passport_number,Customer_name,Customer_phone,Email,Address,Country) 
VALUES("U00005022","ÖNDER TOPALOĞLU","5369876420","önder@gmail.com","Manisa","Turkiye");



INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("DF2753",901,"2021-02-15","15A","U00005001");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("DF2753",901,"2021-02-15","22C","U00005002");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("DF2753",901,"2021-02-15","02C","U00005003");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("DF2753",901,"2021-02-15","82C","U00005004");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("DF2753",911,'2021-03-15',"82C","U00005005");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("DF2753",911,'2021-03-15',"42C","U00005006");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("DF2753",911,'2021-03-15',"12C","U00005007");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("DF2753",911,'2021-03-15',"15A","U00005001");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("DF2753",911,'2021-03-15',"22C","U00005002");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("DF2753",921,'2021-04-15',"22C","U00005002");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("DF2753",921,'2021-04-15',"78A","U00005001");

INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("GT4638",903,"2021-02-17","78A","U00005011");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("GT4638",903,"2021-02-17","79A","U00005012");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("GT4638",903,"2021-02-17","80A","U00005013");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("GT4638",903,"2021-02-17","81A","U00005014");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("GT4638",908,"2021-03-15","81A","U00005014");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("GT4638",908,"2021-03-15","80A","U00005013");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("GT4638",908,"2021-03-15","60A","U00005015");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("GT4638",998,"2021-03-16","60A","U00005016");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("GT4638",998,"2021-03-16","6A","U00005006");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("GT4638",998,"2021-03-16","7A","U00005007");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("GT4638",998,"2021-03-16","1A","U00005020");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("KV3323",904,"2021-03-17","1A","U00005010");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("KV3323",904,"2021-03-17","1C","U00005011");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("KV3323",904,"2021-03-17","3C","U00005018");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("KV3323",904,"2021-03-17","7C","U00005019");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("LX3100",905,'2021-02-18',"7C","U00005005");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("LX3100",905,'2021-02-18',"79C","U00005006");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("LX3100",905,'2021-02-18',"80C","U00005004");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("FD5610",906,'2021-03-01',"8C","U00005004");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("FD5610",906,'2021-03-01',"4C","U00005002");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("EN4267",906,'2021-03-05',"2C","U00005020");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("EN4267",906,'2021-03-05',"3C","U00005019");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("EN4267",906,'2021-03-05',"4C","U00005018");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("FU4864",806,'2021-03-25',"4C","U00005009");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("FU4864",806,'2021-03-25',"3C","U00005008");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("FU4864",806,'2021-03-25',"2C","U00005007");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("FU4864",806,'2021-03-25',"9C","U00005006");
INSERT INTO SEAT_RESERVATION (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("FU4864",806,'2021-03-25',"10C","U00005005");



INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("DF2753",901,"2021-02-15","15A","U00005001");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("DF2753",901,"2021-02-15","22C","U00005002");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("DF2753",901,"2021-02-15","02C","U00005003");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("DF2753",901,"2021-02-15","82C","U00005004");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("DF2753",911,'2021-03-15',"82C","U00005005");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("DF2753",911,'2021-03-15',"42C","U00005006");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("DF2753",911,'2021-03-15',"15A","U00005001");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("DF2753",911,'2021-03-15',"22C","U00005002");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("DF2753",921,'2021-04-15',"78A","U00005001");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("GT4638",903,"2021-02-17","79A","U00005012");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("GT4638",903,"2021-02-17","80A","U00005013");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("GT4638",903,"2021-02-17","81A","U00005014");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("GT4638",908,"2021-03-15","80A","U00005013");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("GT4638",908,"2021-03-15","60A","U00005015");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("GT4638",998,"2021-03-16","60A","U00005016");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("GT4638",998,"2021-03-16","7A","U00005007");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("GT4638",998,"2021-03-16","1A","U00005020");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("KV3323",904,"2021-03-17","1A","U00005010");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("KV3323",904,"2021-03-17","3C","U00005018");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("KV3323",904,"2021-03-17","7C","U00005019");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("LX3100",905,'2021-02-18',"7C","U00005005");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("LX3100",905,'2021-02-18',"80C","U00005004");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("FD5610",906,'2021-03-01',"4C","U00005002");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("EN4267",906,'2021-03-05',"2C","U00005020");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("EN4267",906,'2021-03-05',"3C","U00005019");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("FU4864",806,'2021-03-25',"4C","U00005009");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("FU4864",806,'2021-03-25',"3C","U00005008");

INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("FU4864",806,'2021-03-25',"2C","U00005007");
INSERT INTO checked_in (Flight_number,Leg_number,Flight_date,Seat_number,Passport_number)
VALUES ("FU4864",806,'2021-03-25',"9C","U00005006");


-- 2li sorgu 1
-- Uçuşların bilgilerini fiyatına göre büyükten küçüğe sıralama
SELECT FARE.Flight_number,Airline_code,Fare_code,Amount
FROM Flight,Fare
WHERE FARE.Flight_number=FLight.Flight_number
ORDER BY Amount DESC;

-- 2'li sorgu 2
-- Planlanan tarihte gerçekleşen uçuşların listelenmesi
SELECT FLIGHT_LEG.Flight_number,Departure_time,Arrive_time,Scheduled_departure_time,Scheduled_arrive_time
FROM FLIGHT_LEG,LEG_INSTANCE
WHERE FLIGHT_LEG.Scheduled_departure_time=LEG_INSTANCE.Departure_time
AND FLIGHT_LEG.Scheduled_arrive_time=LEG_INSTANCE.Arrive_time;

-- 2'li sorgu 3
# HAVAYOLLARINDA BULUNABİLEN Uçak tipleri ve Maksimum KAPASİTELERİ
SELECT can_land.Airport_code,airplane_type.airplane_type_name, airplane_type.Max_seats
FROM can_land, airplane_type
WHERE can_land.Airplane_type_name = airplane_type.Airplane_type_name
GROUP BY airplane_type_name
ORDER BY Max_seats DESC;

-- 3'lü sorgu 1
-- Economy sınıfından olan uçuşların kalkış ve varış yerleriyle birlikte
-- fiyatını listeler.
SELECT Fare.Flight_number,Departure_airport_code,Arrival_airport_code,Amount
FROM Flight,Fare,Leg_Instance
WHERE Flight.Flight_number=Fare.Flight_number
AND Fare_code="Y" AND Flight.Flight_number=Leg_Instance.Flight_number;

-- 3'lü sorgu 2
-- 
# İstanbulda check-in yapan müşterilerinin isimleri
SELECT Customer_name
FROM CUSTOMER , CHECKED_IN, AIRPORT
WHERE CUSTOMER.Passport_number = CHECKED_IN.Passport_number
AND CHECKED_IN.Arrival_airport_code = AIRPORT.Airport_code
AND AIRPORT.City = "Istanbul" ;


-- 3'lü sorgu 3

-- İsmi "Kerem Erkinsoy" olan müşterinin
-- uçuş yapacağı tarihler

SELECT Customer.Customer_name, flight_leg.Scheduled_departure_time
from Customer, Flight_leg, seat_reservation
where Customer.Customer_name= "Kerem Erkinsoy"
and Customer.Passport_number = Seat_reservation.Passport_number
and Seat_reservation.Flight_number = Flight_leg.Flight_number
and Seat_reservation.Leg_number = Flight_leg.Leg_number;

-- 4'lü sorgu
-- Müşterilerin uçuşlarında hangi havayolu şirketlerini kullandığını listeler.
select Distinct Customer.Customer_name, customer.Passport_number, airline.Airline_name
from customer, airline, seat_reservation, flight
where customer.Passport_number = seat_reservation.Passport_number
and seat_reservation.Flight_number = flight.Flight_number
and flight.Airline_code = airline.Airline_code
order by customer.Passport_number;



-- NESTED ORNEGİ 1
-- Ekonomi sınıfından olan uçuşların
-- ortaalama bilet fiyatlarından daha ucuz olan
-- uçuşların listelenmesi
SELECT Flight_number, Amount
FROM FARE
HAVING AMOUNT <
ALL (SELECT AVG(Amount) FROM FARE WHERE FARE_CODE="Y");

-- NESTED ORNEGİ 2
-- 250 km'den kısa olan uçuşların listesi
select flight_leg.flight_number, flight_leg.leg_number, flight_leg.Mileage
from flight_leg
where (flight_leg.flight_number, flight_leg.leg_number) in (
select flight_leg.flight_number, flight_leg.leg_number
from flight_leg
where flight_leg.Mileage < 250);


-- NESTED ORNEGI 3
-- Koltuk numarası 300'den fazla olan uçakların yaptığı uçuşlar ve tarihleri
SELECT Flight_number ,Leg_number,Flight_date
FROM LEG_INSTANCE
WHERE Airplane_id IN(
SELECT Airplane_id
FROM AIRPLANE
WHERE Total_number_of_seats > 300);

-- NESTED ORNEGI  4
# Uçuş ücretinin değeri 150'den küçük olan havayolu şirketi
SELECT Airline_code,Flight_number
FROM FLIGHT
WHERE FLIGHT.Flight_number IN (
SELECT FARE.Flight_number 
FROM FARE
WHERE Amount < 200);

# CHECK-IN YAPMAYAN MUSTERİLER - NOT EXIST ORNEGI
SELECT *
FROM SEAT_RESERVATION AS A
WHERE NOT EXISTS (
SELECT  Flight_number ,Leg_number ,Flight_date ,Seat_number Passport_number 
FROM CHECKED_IN AS B
WHERE A.Flight_number = B.Flight_number
AND A.Leg_number = B.Leg_number
AND A.Flight_date =B.Flight_date
AND A.Seat_number=B.Seat_number
AND A.Passport_number=B.Passport_number);


-- EXIST ORNEGI AMA BU NE BİLMİYORUZ
-- !!!!!!!

/*SELECT Airport_code,Airport_name, AIRPLANE.Airplane_id,Flight_number,Leg_number
FROM AIRPORT, AIRPLANE, FLIGHT_LEG 
WHERE EXISTS (
SELECT Airport_code, LEG_INSTANCE.Airplane_id,Flight_number,Leg_number 
FROM WHICH_CAN_LAND, LEG_INSTANCE 
WHERE LEG_INSTANCE.Airplane_id = WHICH_CAN_LAND.Airplane_id);*/


-- Inner Join örneği
-- Varış havaalanlarında hizmet veren şirketler ve buraya giden uçuşlar
SELECT FLIGHT.Flight_number,Airport.Airport_name, AIRLINE.Airline_name
FROM AIRPORT INNER JOIN 
FLIGHT_LEG ON AIRPORT.Airport_code=FLIGHT_LEG.Departure_airport_code
INNER JOIN FLIGHT ON FLIGHT_LEG.Flight_number=FLIGHT.Flight_number
INNER JOIN AIRLINE ON AIRLINE.Airline_code=FLIGHT.Airline_code
AND FLIGHT.Airline_code=AIRLINE.Airline_code;

-- FULL OUTER JOIN
-- MYSQL DESTEKLEMEDIGI ICIN
-- UNION YAPILDI
SELECT * FROM CUSTOMER
LEFT OUTER JOIN FFC on CUSTOMER.Passport_number = FFC.Passport_number
UNION
SELECT * FROM CUSTOMER
RIGHT OUTER JOIN FFC on CUSTOMER.Passport_number = FFC.Passport_number;



CREATE VIEW CUSTOMER_SEG AS
SELECT *
FROM FFC
WHERE Total_mileage_point >= 1000;

-- Uçuşlardaki boş koltuk sayısı ve uçuş bilgileri gösterilir
create view flight_koltuk
as select leg_instance.Flight_number, leg_instance.Leg_number, leg_instance.Number_of_available_seats, flight_leg.Mileage
from flight_leg, leg_instance
where flight_leg.Flight_number = leg_instance.Flight_number
and flight_leg.Leg_number = leg_instance.Leg_number
order by flight_leg.Flight_number;

-- View son
CREATE VIEW NEAREST_LEG_INSTANCES AS
SELECT * 
FROM LEG_INSTANCE
ORDER BY Flight_date;

-- View örneği
-- Hangi havalimanına hangi uçak ve hangi havayolu şirketinden inecek olanları
-- gösterir.
CREATE VIEW WHICH_CAN_LAND AS
SELECT *
FROM CAN_LAND
RIGHT JOIN AIRPLANE ON CAN_LAND.Airplane_type_name=AIRPLANE.Airplane_type;












