-- Тенищев Семён А3400

-- *****************************************
-- Создание таблицы для 1 НФ
DROP TABLE IF EXISTS firstNF_AudioTrackStore;
CREATE TABLE firstNF_AudioTrackStore (
  ArtistId int NOT NULL,
  ArtistName varchar(120) NOT NULL,
  AlbumId int NOT NULL,
  AlbumTitle varchar(120) NOT NULL,
  TrackId int NOT NULL,
  TrackName varchar(200) NOT NULL,
  TrackLength bigint NOT NULL,
  TrackGenre varchar(120) NOT NULL,
  TrackPrice decimal(10,2) NOT NULL,
  PlaylistId int NOT NULL,
  PlaylistName varchar(120) NOT NULL,
  OrderId int NOT NULL,
  CustomerId int NOT NULL,
  CustomerName varchar(60) NOT NULL,
  CustomerEmail varchar(60) NOT NULL,
  OrderDate date NOT NULL,
  DeliveryAddress varchar(70) NOT NULL,
  OrderTrackQuantity int NOT NULL,
  PRIMARY KEY `first_NF` (`ArtistId`, `AlbumId`, `TrackId`, `PlaylistId`, `OrderId`)
);

-- Заполняем
INSERT IGNORE INTO firstNF_AudioTrackStore SELECT * FROM AudioTrackStore;

-- *****************************************
-- Создание таблиц для 2 НФ
DROP TABLE IF EXISTS secondNF_Artists;
DROP TABLE IF EXISTS secondNF_Albums;
DROP TABLE IF EXISTS secondNF_Tracks;
DROP TABLE IF EXISTS secondNF_Playlists;
DROP TABLE IF EXISTS secondNF_Orders;
CREATE TABLE secondNF_Artists (
  ArtistId int NOT NULL PRIMARY KEY,
  ArtistName varchar(120) NOT NULL
);
CREATE TABLE secondNF_Albums (
  AlbumId int NOT NULL PRIMARY KEY,
  AlbumTitle varchar(120) NOT NULL
);
CREATE TABLE secondNF_Tracks (
  TrackId int NOT NULL PRIMARY KEY,
  TrackName varchar(200) NOT NULL,
  TrackLength bigint NOT NULL,
  TrackGenre varchar(120) NOT NULL,
  TrackPrice decimal(10,2) NOT NULL
);
CREATE TABLE secondNF_Playlists (
  PlaylistId int NOT NULL PRIMARY KEY,
  PlaylistName varchar(120) NOT NULL
);
CREATE TABLE secondNF_Orders (
  OrderId int NOT NULL PRIMARY KEY,
  CustomerId int NOT NULL,
  CustomerName varchar(60) NOT NULL,
  CustomerEmail varchar(60) NOT NULL,
  OrderDate date NOT NULL,
  DeliveryAddress varchar(70) NOT NULL,
  OrderTrackQuantity int NOT NULL
);

-- Заполняем
INSERT IGNORE INTO secondNF_Artists SELECT ArtistId, ArtistName FROM firstNF_AudioTrackStore;
INSERT IGNORE INTO secondNF_Albums SELECT AlbumId, AlbumTitle FROM firstNF_AudioTrackStore;
INSERT IGNORE INTO secondNF_Tracks SELECT TrackId, TrackName, TrackLength, TrackGenre, TrackPrice FROM firstNF_AudioTrackStore;
INSERT IGNORE INTO secondNF_Playlists SELECT PlaylistId, PlaylistName FROM firstNF_AudioTrackStore;
INSERT IGNORE INTO secondNF_Orders SELECT OrderId, CustomerId, CustomerName, CustomerEmail, OrderDate, DeliveryAddress, OrderTrackQuantity FROM firstNF_AudioTrackStore;

-- *****************************************
-- Создание таблиц для 3 НФ
DROP TABLE IF EXISTS thirdNF_Artists;
DROP TABLE IF EXISTS thirdNF_Albums;
DROP TABLE IF EXISTS thirdNF_Tracks;
DROP TABLE IF EXISTS thirdNF_TracksInfo;
DROP TABLE IF EXISTS thirdNF_Playlists;
DROP TABLE IF EXISTS thirdNF_Orders;
DROP TABLE IF EXISTS thirdNF_Customers;
DROP TABLE IF EXISTS thirdNF_CustomersInfo;
DROP TABLE IF EXISTS thirdNF_OrdersInfo;
CREATE TABLE thirdNF_Artists (
  ArtistId int NOT NULL PRIMARY KEY,
  ArtistName varchar(120) NOT NULL
);
CREATE TABLE thirdNF_Albums (
  AlbumId int NOT NULL PRIMARY KEY,
  AlbumTitle varchar(120) NOT NULL
);
CREATE TABLE thirdNF_Tracks (
  TrackId int NOT NULL PRIMARY KEY,
  TrackName varchar(200) NOT NULL
);
CREATE TABLE thirdNF_TracksInfo (
  TrackId int NOT NULL PRIMARY KEY,
  TrackLength bigint NOT NULL,
  TrackGenre varchar(120) NOT NULL,
  TrackPrice decimal(10,2) NOT NULL
);
CREATE TABLE thirdNF_Playlists (
  PlaylistId int NOT NULL PRIMARY KEY,
  PlaylistName varchar(120) NOT NULL
);
CREATE TABLE thirdNF_Orders (
  OrderId int NOT NULL PRIMARY KEY,
  CustomerId int NOT NULL
);
CREATE TABLE thirdNF_Customers (
  CustomerId int NOT NULL PRIMARY KEY,
  CustomerName varchar(60) NOT NULL
);
CREATE TABLE thirdNF_CustomersInfo (
  CustomerId int NOT NULL PRIMARY KEY,
  CustomerEmail varchar(60) NOT NULL,
  DeliveryAddress varchar(70) NOT NULL
);
CREATE TABLE thirdNF_OrdersInfo (
  OrderId int NOT NULL PRIMARY KEY,
  OrderDate date NOT NULL,
  OrderTrackQuantity int NOT NULL
);

-- Заполним
INSERT INTO thirdNF_Artists SELECT * FROM secondNF_Artists;
INSERT INTO thirdNF_Albums SELECT * FROM secondNF_Albums;
INSERT IGNORE INTO thirdNF_Tracks SELECT TrackId, TrackName FROM secondNF_Tracks;
INSERT IGNORE INTO thirdNF_TracksInfo SELECT TrackId, TrackLength, TrackGenre, TrackPrice FROM secondNF_Tracks;
INSERT INTO thirdNF_Playlists SELECT * FROM secondNF_Playlists;
INSERT IGNORE INTO thirdNF_Orders SELECT OrderId, CustomerId FROM secondNF_Orders;
INSERT IGNORE INTO thirdNF_Customers SELECT CustomerId, CustomerName FROM secondNF_Orders;
INSERT IGNORE INTO thirdNF_CustomersInfo SELECT CustomerId, CustomerEmail, DeliveryAddress FROM secondNF_Orders;
INSERT IGNORE INTO thirdNF_OrdersInfo SELECT OrderId, OrderDate, OrderTrackQuantity FROM secondNF_Orders;

-- *****************************************
-- Создание таблиц для НФ Бойса-Кода
DROP TABLE IF EXISTS NFBK_Artists;
DROP TABLE IF EXISTS NFBK_Albums;
DROP TABLE IF EXISTS NFBK_Tracks;
DROP TABLE IF EXISTS NFBK_TracksInfo;
DROP TABLE IF EXISTS NFBK_Playlists;
DROP TABLE IF EXISTS NFBK_Orders;
DROP TABLE IF EXISTS NFBK_Customers;
DROP TABLE IF EXISTS NFBK_CustomersEmail;
DROP TABLE IF EXISTS NFBK_CustomersAddress;
DROP TABLE IF EXISTS NFBK_OrdersInfo;
CREATE TABLE NFBK_Artists (
  ArtistId int NOT NULL PRIMARY KEY,
  ArtistName varchar(120) NOT NULL
);
CREATE TABLE NFBK_Albums (
  AlbumId int NOT NULL PRIMARY KEY,
  AlbumTitle varchar(120) NOT NULL
);
CREATE TABLE NFBK_Tracks (
  TrackId int NOT NULL PRIMARY KEY,
  TrackName varchar(200) NOT NULL
);
CREATE TABLE NFBK_TracksInfo (
  TrackId int NOT NULL PRIMARY KEY,
  TrackLength bigint NOT NULL,
  TrackGenre varchar(120) NOT NULL,
  TrackPrice decimal(10,2) NOT NULL
);
CREATE TABLE NFBK_Playlists (
  PlaylistId int NOT NULL PRIMARY KEY,
  PlaylistName varchar(120) NOT NULL
);
CREATE TABLE NFBK_Orders (
  OrderId int NOT NULL PRIMARY KEY,
  CustomerId int NOT NULL
);
CREATE TABLE NFBK_Customers (
  CustomerId int NOT NULL PRIMARY KEY,
  CustomerName varchar(60) NOT NULL
);
CREATE TABLE NFBK_CustomersEmail (
  CustomerId int NOT NULL PRIMARY KEY,
  CustomerEmail varchar(60) NOT NULL
);
CREATE TABLE NFBK_CustomersAddress (
  CustomerId int NOT NULL PRIMARY KEY,
  DeliveryAddress varchar(70) NOT NULL
);
CREATE TABLE NFBK_OrdersInfo (
  OrderId int NOT NULL PRIMARY KEY,
  OrderDate date NOT NULL,
  OrderTrackQuantity int NOT NULL
);

-- Заполним
INSERT INTO NFBK_Artists SELECT * FROM thirdNF_Artists;
INSERT INTO NFBK_Albums SELECT * FROM thirdNF_Albums;
INSERT INTO NFBK_Tracks SELECT * FROM thirdNF_Tracks;
INSERT INTO NFBK_TracksInfo SELECT * FROM thirdNF_TracksInfo;
INSERT INTO NFBK_Playlists SELECT * FROM thirdNF_Playlists;
INSERT INTO NFBK_Orders SELECT * FROM thirdNF_Orders;
INSERT INTO NFBK_Customers SELECT * FROM thirdNF_Customers;
INSERT IGNORE INTO NFBK_CustomersEmail SELECT CustomerId, CustomerEmail FROM thirdNF_CustomersInfo;
INSERT IGNORE INTO NFBK_CustomersAddress SELECT CustomerId, DeliveryAddress FROM thirdNF_CustomersInfo;
INSERT INTO NFBK_OrdersInfo SELECT * FROM thirdNF_OrdersInfo;

-- *****************************************
-- Создание таблиц для 4 НФ
DROP TABLE IF EXISTS fourthNF_Artists;
DROP TABLE IF EXISTS fourthNF_Albums;
DROP TABLE IF EXISTS fourthNF_Tracks;
DROP TABLE IF EXISTS fourthNF_TracksLength;
DROP TABLE IF EXISTS fourthNF_TracksGenre;
DROP TABLE IF EXISTS fourthNF_TracksPrice;
DROP TABLE IF EXISTS fourthNF_Playlists;
DROP TABLE IF EXISTS fourthNF_Orders;
DROP TABLE IF EXISTS fourthNF_Customers;
DROP TABLE IF EXISTS fourthNF_CustomersEmail;
DROP TABLE IF EXISTS fourthNF_CustomersAddress;
DROP TABLE IF EXISTS fourthNF_OrdersDate;
DROP TABLE IF EXISTS fourthNF_OrdersQuantity;
CREATE TABLE fourthNF_Artists (
  ArtistId int NOT NULL PRIMARY KEY,
  ArtistName varchar(120) NOT NULL
);
CREATE TABLE fourthNF_Albums (
  AlbumId int NOT NULL PRIMARY KEY,
  AlbumTitle varchar(120) NOT NULL
);
CREATE TABLE fourthNF_Tracks (
  TrackId int NOT NULL PRIMARY KEY,
  TrackName varchar(200) NOT NULL
);
CREATE TABLE fourthNF_TracksLength (
  TrackId int NOT NULL PRIMARY KEY,
  TrackLength bigint NOT NULL
);
CREATE TABLE fourthNF_TracksGenre (
  TrackId int NOT NULL PRIMARY KEY,
  TrackGenre varchar(120) NOT NULL
);
CREATE TABLE fourthNF_TracksPrice (
  TrackId int NOT NULL PRIMARY KEY,
  TrackPrice decimal(10,2) NOT NULL
);
CREATE TABLE fourthNF_Playlists (
  PlaylistId int NOT NULL PRIMARY KEY,
  PlaylistName varchar(120) NOT NULL
);
CREATE TABLE fourthNF_Orders (
  OrderId int NOT NULL PRIMARY KEY,
  CustomerId int NOT NULL
);
CREATE TABLE fourthNF_Customers (
  CustomerId int NOT NULL PRIMARY KEY,
  CustomerName varchar(60) NOT NULL
);
CREATE TABLE fourthNF_CustomersEmail (
  CustomerId int NOT NULL PRIMARY KEY,
  CustomerEmail varchar(60) NOT NULL
);
CREATE TABLE fourthNF_CustomersAddress (
  CustomerId int NOT NULL PRIMARY KEY,
  DeliveryAddress varchar(70) NOT NULL
);
CREATE TABLE fourthNF_OrdersDate (
  OrderId int NOT NULL PRIMARY KEY,
  OrderDate date NOT NULL
);
CREATE TABLE fourthNF_OrdersQuantity (
  OrderId int NOT NULL PRIMARY KEY,
  OrderTrackQuantity int NOT NULL
);

-- Заполним
INSERT INTO fourthNF_Artists SELECT * FROM NFBK_Artists;
INSERT INTO fourthNF_Albums SELECT * FROM NFBK_Albums;
INSERT INTO fourthNF_Tracks SELECT * FROM NFBK_Tracks;
INSERT IGNORE INTO fourthNF_TracksLength SELECT TrackId, TrackLength FROM NFBK_TracksInfo;
INSERT IGNORE INTO fourthNF_TracksGenre SELECT TrackId, TrackGenre FROM NFBK_TracksInfo;
INSERT IGNORE INTO fourthNF_TracksPrice SELECT TrackId, TrackPrice FROM NFBK_TracksInfo;
INSERT INTO fourthNF_Playlists SELECT * FROM NFBK_Playlists;
INSERT INTO fourthNF_Orders SELECT * FROM NFBK_Orders;
INSERT INTO fourthNF_Customers SELECT * FROM NFBK_Customers;
INSERT INTO fourthNF_CustomersEmail SELECT * FROM NFBK_CustomersEmail;
INSERT INTO fourthNF_CustomersAddress SELECT * FROM NFBK_CustomersAddress;
INSERT IGNORE INTO fourthNF_OrdersDate SELECT OrderId, OrderDate FROM NFBK_OrdersInfo;
INSERT IGNORE INTO fourthNF_OrdersQuantity SELECT OrderId, OrderTrackQuantity FROM NFBK_OrdersInfo;

-- *****************************************
-- Согласно первой теореме Дейта-Фейгина, таблицы которые мы имели в 3НФ уже находились в 5НФ
-- Создание таблиц для 5 НФ
DROP TABLE IF EXISTS fifthNF_Artists;
DROP TABLE IF EXISTS fifthNF_Albums;
DROP TABLE IF EXISTS fifthNF_Tracks;
DROP TABLE IF EXISTS fifthNF_TracksLength;
DROP TABLE IF EXISTS fifthNF_TracksGenre;
DROP TABLE IF EXISTS fifthNF_TracksPrice;
DROP TABLE IF EXISTS fifthNF_Playlists;
DROP TABLE IF EXISTS fifthNF_Orders;
DROP TABLE IF EXISTS fifthNF_Customers;
DROP TABLE IF EXISTS fifthNF_CustomersEmail;
DROP TABLE IF EXISTS fifthNF_CustomersAddress;
DROP TABLE IF EXISTS fifthNF_OrdersDate;
DROP TABLE IF EXISTS fifthNF_OrdersQuantity;
CREATE TABLE fifthNF_Artists (
  ArtistId int NOT NULL PRIMARY KEY,
  ArtistName varchar(120) NOT NULL
);
CREATE TABLE fifthNF_Albums (
  AlbumId int NOT NULL PRIMARY KEY,
  AlbumTitle varchar(120) NOT NULL
);
CREATE TABLE fifthNF_Tracks (
  TrackId int NOT NULL PRIMARY KEY,
  TrackName varchar(200) NOT NULL
);
CREATE TABLE fifthNF_TracksLength (
  TrackId int NOT NULL PRIMARY KEY,
  TrackLength bigint NOT NULL
);
CREATE TABLE fifthNF_TracksGenre (
  TrackId int NOT NULL PRIMARY KEY,
  TrackGenre varchar(120) NOT NULL
);
CREATE TABLE fifthNF_TracksPrice (
  TrackId int NOT NULL PRIMARY KEY,
  TrackPrice decimal(10,2) NOT NULL
);
CREATE TABLE fifthNF_Playlists (
  PlaylistId int NOT NULL PRIMARY KEY,
  PlaylistName varchar(120) NOT NULL
);
CREATE TABLE fifthNF_Orders (
  OrderId int NOT NULL PRIMARY KEY,
  CustomerId int NOT NULL
);
CREATE TABLE fifthNF_Customers (
  CustomerId int NOT NULL PRIMARY KEY,
  CustomerName varchar(60) NOT NULL
);
CREATE TABLE fifthNF_CustomersEmail (
  CustomerId int NOT NULL PRIMARY KEY,
  CustomerEmail varchar(60) NOT NULL
);
CREATE TABLE fifthNF_CustomersAddress (
  CustomerId int NOT NULL PRIMARY KEY,
  DeliveryAddress varchar(70) NOT NULL
);
CREATE TABLE fifthNF_OrdersDate (
  OrderId int NOT NULL PRIMARY KEY,
  OrderDate date NOT NULL
);
CREATE TABLE fifthNF_OrdersQuantity (
  OrderId int NOT NULL PRIMARY KEY,
  OrderTrackQuantity int NOT NULL
);

-- Заполним
INSERT INTO fifthNF_Artists SELECT * FROM fourthNF_Artists;
INSERT INTO fifthNF_Albums SELECT * FROM fourthNF_Albums;
INSERT INTO fifthNF_Tracks SELECT * FROM fourthNF_Tracks;
INSERT INTO fifthNF_TracksLength SELECT * FROM fourthNF_TracksLength;
INSERT INTO fifthNF_TracksGenre SELECT * FROM fourthNF_TracksGenre;
INSERT INTO fifthNF_TracksPrice SELECT * FROM fourthNF_TracksPrice;
INSERT INTO fifthNF_Playlists SELECT * FROM fourthNF_Playlists;
INSERT INTO fifthNF_Orders SELECT * FROM fourthNF_Orders;
INSERT INTO fifthNF_Customers SELECT * FROM fourthNF_Customers;
INSERT INTO fifthNF_CustomersEmail SELECT * FROM fourthNF_CustomersEmail;
INSERT INTO fifthNF_CustomersAddress SELECT * FROM fourthNF_CustomersAddress;
INSERT INTO fifthNF_OrdersDate SELECT * FROM fourthNF_OrdersDate;
INSERT INTO fifthNF_OrdersQuantity SELECT * FROM fourthNF_OrdersQuantity;
