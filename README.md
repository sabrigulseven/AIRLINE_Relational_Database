# AIRLINE_Relational_Database
AIRLINE relational database MySQL

EER DIAGRAM

![image](https://user-images.githubusercontent.com/80418105/194514417-a346b6cf-a471-419d-b90d-3bb19e81fc65.png)


TABLES:

AIRPORT:

![image](https://user-images.githubusercontent.com/80418105/194515167-4ccfa48e-62cd-45dc-862d-3d39578a61c1.png)

AIRLINE:

![image](https://user-images.githubusercontent.com/80418105/194515224-0b8c68ce-e848-493e-b946-eaa7927c14f6.png)

FACTORY:

![image](https://user-images.githubusercontent.com/80418105/194515314-01982ad3-4394-4add-b7b1-4943cfee1973.png)

AIRPLANE_TYPE:

![image](https://user-images.githubusercontent.com/80418105/194515377-338ff8d7-74ad-41fb-92fb-e41f60ade39b.png)

AIRPLANE:

![image](https://user-images.githubusercontent.com/80418105/194515433-823d6d96-27ed-43ae-87b8-aa7f27c4f1e7.png)

CAN_LAND:

![image](https://user-images.githubusercontent.com/80418105/194515574-32b83810-0f4c-409d-a30a-6c797ca2040e.png)


FLIGHT:

![image](https://user-images.githubusercontent.com/80418105/194515700-d07ebabb-ebd2-4cd3-847d-a963a8dd8a70.png)

FLIGHT_LEG:

![image](https://user-images.githubusercontent.com/80418105/194515780-a9245be8-fd02-47ca-b213-d2ff3cd35d65.png)
![image](https://user-images.githubusercontent.com/80418105/194515959-382fd72d-886a-4619-ba93-9a30f96451c5.png)


LEG_INSTANCE:

![image](https://user-images.githubusercontent.com/80418105/194516028-00bdc268-bc79-4924-b3bf-9679b145b9e6.png)

FARE:

![image](https://user-images.githubusercontent.com/80418105/194516080-6d75f8f4-bc12-4ffc-910f-2f33a6fbc82b.png)
![image](https://user-images.githubusercontent.com/80418105/194516118-b1ccc32d-c98f-4754-a4e2-0ccf5391cdf9.png)


CUSTOMER:

![image](https://user-images.githubusercontent.com/80418105/194516204-5109cd79-9e6b-4d8b-a5b7-dc4c2b663197.png)


SEAT_RESERVATION:

![image](https://user-images.githubusercontent.com/80418105/194516289-a5fd75c1-9193-414f-894c-73850e30b694.png)


CHECKED_IN:

![image](https://user-images.githubusercontent.com/80418105/194516362-b3414ec8-3e5c-4a0c-a7b2-f347132dcb6f.png)


FFC:

![image](https://user-images.githubusercontent.com/80418105/194516463-31fef3fe-4741-4de6-9010-81587a4e6585.png)


<br><br>


TRIGGERS:

1. For a valid flight record, the aircraft to be used must be capable of landing and taking off on both airlines.

![image](https://user-images.githubusercontent.com/80418105/194517108-36459626-8749-43ef-8ead-196353e2f89b.png)


2.When the customer checks in, the mileage information of the flight is received and the total miles score in the FFC table is increased.

![image](https://user-images.githubusercontent.com/80418105/194517539-3dce2c67-3b5d-40ec-9898-bdbcc3d29a19.png)

3.The flight information of the checking-in customer is added to the CHECKED_IN table.

![image](https://user-images.githubusercontent.com/80418105/194517788-4a207bf8-935a-40b5-94b8-95878fce614b.png)
![image](https://user-images.githubusercontent.com/80418105/194517825-53b0ed95-3cbe-4ce2-9d59-5eb1737b5a30.png)


4.Before the customer makes a reservation, the availability of seats is checked. If there is a suitable seat, the number of seats available is reduced by one, otherwise an error message is given.

![image](https://user-images.githubusercontent.com/80418105/194521605-2d6a6def-c1dd-4ff9-a09b-b9593154d17a.png)

5.When any aircraft record is added to the system, the number of aircraft of the company belonging to that aircraft is increased by 1.

![image](https://user-images.githubusercontent.com/80418105/194521884-a537bd23-aa02-463e-a476-c9149e2e221c.png)


<br>

CHECK CONSTRAINTS:

1. The departure time must be ahead of the arrival time

![image](https://user-images.githubusercontent.com/80418105/194522730-1db1754d-f2b8-4fa4-bfec-fecf6ad6b3e3.png)
![image](https://user-images.githubusercontent.com/80418105/194522779-ef609dc5-5a9c-4428-8649-c94621e363de.png)

2. “F” stands for First Class, “J” for Business Class and “Y” for Economy Class. The ticket code must consist of these 3 types.

![image](https://user-images.githubusercontent.com/80418105/194523036-db3e836a-af42-48b3-a114-44069feee9ec.png)

3.The number of available seats on a flight cannot be negative.

![image](https://user-images.githubusercontent.com/80418105/194523258-386a95eb-6080-476b-a0ed-2441a94f6479.png)


4.The departure and arrival places of the aircraft should not be the same.

![image](https://user-images.githubusercontent.com/80418105/194523457-ff7e36f5-fbcc-4a1d-8513-fae1df75201c.png)
![image](https://user-images.githubusercontent.com/80418105/194523523-7e8d269d-e86c-45f2-891f-d81f67b0639b.png)
