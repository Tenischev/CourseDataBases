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
  PRIMARY KEY `first_NF` (`TrackId`, `PlaylistId`, `OrderId`)
);

-- Заполняем
INSERT IGNORE INTO firstNF_AudioTrackStore SELECT * FROM AudioTrackStore;

-- *****************************************
-- Создание таблиц для 2 НФ
DROP TABLE IF EXISTS secondNF_Artists;
DROP TABLE IF EXISTS secondNF_Albums;
DROP TABLE IF EXISTS secondNF_Tracks;
DROP TABLE IF EXISTS secondNF_Playlists;
DROP TABLE IF EXISTS secondNF_PlaylistsInfo;
DROP TABLE IF EXISTS secondNF_Orders;
DROP TABLE IF EXISTS secondNF_OrdersInfo;
DROP TABLE IF EXISTS secondNF_Customers;
CREATE TABLE secondNF_Artists (
  ArtistId int NOT NULL PRIMARY KEY,
  ArtistName varchar(120) NOT NULL
);
CREATE TABLE secondNF_Albums (
  AlbumId int NOT NULL PRIMARY KEY,
  AlbumTitle varchar(120) NOT NULL,
  ArtistId int NOT NULL
);
CREATE TABLE secondNF_Tracks (
  TrackId int NOT NULL PRIMARY KEY,
  TrackName varchar(200) NOT NULL,
  TrackLength bigint NOT NULL,
  TrackGenre varchar(120) NOT NULL,
  TrackPrice decimal(10,2) NOT NULL,
  AlbumId int NOT NULL
);
CREATE TABLE secondNF_Playlists ( -- название плейлиста не зависит в функциональном смысле от его состава
  PlaylistId int NOT NULL PRIMARY KEY,
  PlaylistName varchar(120) NOT NULL
);
CREATE TABLE secondNF_PlaylistsInfo (
  PlaylistId int NOT NULL,
  TrackId int NOT NULL,
  PRIMARY KEY `second_NF_pl` (`PlaylistId`, `TrackId`)
);
CREATE TABLE secondNF_Orders ( -- заказчик и дата заказа не зависят от трека
  OrderId int NOT NULL PRIMARY KEY,
  CustomerId int NOT NULL,
  OrderDate date NOT NULL
);
CREATE TABLE secondNF_OrdersInfo ( -- а вот количество треков уже заивисит от заказа и трека
  OrderId int NOT NULL,
  TrackId int NOT NULL,
  OrderTrackQuantity int NOT NULL,
  PRIMARY KEY `second_NF_ord` (`TrackId`, `OrderId`)
);
CREATE TABLE secondNF_Customers (
  CustomerId int NOT NULL PRIMARY KEY,
  CustomerName varchar(60) NOT NULL,
  CustomerEmail varchar(60) NOT NULL,
  DeliveryAddress varchar(70) NOT NULL -- а если бы он зависел еще от заказа, было бы веселее
);

-- Заполняем
INSERT IGNORE INTO secondNF_Artists SELECT ArtistId, ArtistName FROM firstNF_AudioTrackStore;
INSERT IGNORE INTO secondNF_Albums SELECT AlbumId, AlbumTitle, ArtistId FROM firstNF_AudioTrackStore;
INSERT IGNORE INTO secondNF_Tracks SELECT TrackId, TrackName, TrackLength, TrackGenre, TrackPrice, AlbumId  FROM firstNF_AudioTrackStore;
INSERT IGNORE INTO secondNF_Playlists SELECT PlaylistId, PlaylistName FROM firstNF_AudioTrackStore;
INSERT IGNORE INTO secondNF_PlaylistsInfo SELECT PlaylistId, TrackId FROM firstNF_AudioTrackStore;
INSERT IGNORE INTO secondNF_Orders SELECT OrderId, CustomerId, OrderDate FROM firstNF_AudioTrackStore;
INSERT IGNORE INTO secondNF_OrdersInfo SELECT OrderId, TrackId, OrderTrackQuantity FROM firstNF_AudioTrackStore;
INSERT IGNORE INTO secondNF_Customers SELECT CustomerId, CustomerName, CustomerEmail, DeliveryAddress FROM firstNF_AudioTrackStore;

-- Восстановим исходную в 1НФ
DROP TABLE IF EXISTS revers_secondNF_to_firstNF;
CREATE TABLE revers_secondNF_to_firstNF (
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
  PRIMARY KEY `revers_secondNF` (`TrackId`, `PlaylistId`, `OrderId`)
);

INSERT IGNORE INTO revers_secondNF_to_firstNF (
  SELECT Art.ArtistId, Art.ArtistName,
         Alb.AlbumId, Alb.AlbumTitle,
         Track.TrackId, Track.TrackName, Track.TrackLength, Track.TrackGenre, Track.TrackPrice,
         Pl.PlaylistId, Pl.PlaylistName,
         Ord.OrderId, Cust.CustomerId, Cust.CustomerName, Cust.CustomerEmail,
         Ord.OrderDate, Cust.DeliveryAddress,
         OrdInf.OrderTrackQuantity FROM secondNF_Artists AS Art
    INNER JOIN secondNF_Albums AS Alb
      ON Art.ArtistId = Alb.ArtistId
    INNER JOIN secondNF_Tracks AS Track
      ON Track.AlbumId = Alb.AlbumId
    INNER JOIN secondNF_PlaylistsInfo AS PlInfo
      ON PlInfo.TrackId = Track.TrackId
    INNER JOIN secondNF_Playlists AS Pl
      ON Pl.PlaylistId = PlInfo.PlaylistId
    INNER JOIN secondNF_OrdersInfo AS OrdInf
      ON OrdInf.TrackId = Track.TrackId
    INNER JOIN secondNF_Orders AS Ord
      ON Ord.OrderId = OrdInf.OrderId
    INNER JOIN secondNF_Customers AS Cust
      ON Cust.CustomerId = Ord.CustomerId);

-- *****************************************
-- Создание таблиц для 3 НФ
-- Единственное разумное, что могу предложить, это "заподозрить", что длина, жанр и цена зависят от названия а не от id трека
-- аналогично для покупателей Email и адрес зависят от имени, а не от id. Давайте так и сделаем.

DROP TABLE IF EXISTS thirdNF_Artists;
DROP TABLE IF EXISTS thirdNF_Albums;
DROP TABLE IF EXISTS thirdNF_Tracks;
DROP TABLE IF EXISTS thirdNF_TracksInfo;
DROP TABLE IF EXISTS thirdNF_Playlists;
DROP TABLE IF EXISTS thirdNF_PlaylistsInfo;
DROP TABLE IF EXISTS thirdNF_Orders;
DROP TABLE IF EXISTS thirdNF_OrdersInfo;
DROP TABLE IF EXISTS thirdNF_Customers;
DROP TABLE IF EXISTS thirdNF_CustomersInfo;
CREATE TABLE thirdNF_Artists (
  ArtistId int NOT NULL PRIMARY KEY,
  ArtistName varchar(120) NOT NULL
);
CREATE TABLE thirdNF_Albums (
  AlbumId int NOT NULL PRIMARY KEY,
  AlbumTitle varchar(120) NOT NULL,
  ArtistId int NOT NULL
);
CREATE TABLE thirdNF_Tracks (
  TrackId int NOT NULL PRIMARY KEY,
  TrackName varchar(200) NOT NULL,
  AlbumId int NOT NULL
);
CREATE TABLE thirdNF_TracksInfo (
  TrackName varchar(200) NOT NULL PRIMARY KEY,
  TrackLength bigint NOT NULL,
  TrackGenre varchar(120) NOT NULL,
  TrackPrice decimal(10,2) NOT NULL
);
CREATE TABLE thirdNF_Playlists (
  PlaylistId int NOT NULL PRIMARY KEY,
  PlaylistName varchar(120) NOT NULL
);
CREATE TABLE thirdNF_PlaylistsInfo (
  PlaylistId int NOT NULL,
  TrackId int NOT NULL,
  PRIMARY KEY `third_NF_pl` (`PlaylistId`, `TrackId`)
);
CREATE TABLE thirdNF_Orders (
  OrderId int NOT NULL PRIMARY KEY,
  CustomerId int NOT NULL,
  OrderDate date NOT NULL
);
CREATE TABLE thirdNF_OrdersInfo (
  OrderId int NOT NULL,
  TrackId int NOT NULL,
  OrderTrackQuantity int NOT NULL,
  PRIMARY KEY `third_NF_ord` (`TrackId`, `OrderId`)
);
CREATE TABLE thirdNF_Customers (
  CustomerId int NOT NULL PRIMARY KEY,
  CustomerName varchar(60) NOT NULL
);
CREATE TABLE thirdNF_CustomersInfo (
  CustomerName varchar(60) NOT NULL PRIMARY KEY,
  CustomerEmail varchar(60) NOT NULL,
  DeliveryAddress varchar(70) NOT NULL
);

-- Заполним
INSERT INTO thirdNF_Artists SELECT * FROM secondNF_Artists;
INSERT INTO thirdNF_Albums SELECT * FROM secondNF_Albums;
INSERT IGNORE INTO thirdNF_Tracks SELECT TrackId, TrackName, AlbumId FROM secondNF_Tracks;
INSERT IGNORE INTO thirdNF_TracksInfo SELECT TrackName, TrackLength, TrackGenre, TrackPrice FROM secondNF_Tracks;
INSERT INTO thirdNF_Playlists SELECT * FROM secondNF_Playlists;
INSERT INTO thirdNF_PlaylistsInfo SELECT * FROM secondNF_PlaylistsInfo;
INSERT INTO thirdNF_Orders SELECT * FROM secondNF_Orders;
INSERT INTO thirdNF_OrdersInfo SELECT * FROM secondNF_OrdersInfo;
INSERT IGNORE INTO thirdNF_Customers SELECT CustomerId, CustomerName FROM secondNF_Customers;
INSERT IGNORE INTO thirdNF_CustomersInfo SELECT CustomerName, CustomerEmail, DeliveryAddress FROM secondNF_Customers;

-- Восстановим исходную в 1НФ
DROP TABLE IF EXISTS revers_thirdNF_to_firstNF;
CREATE TABLE revers_thirdNF_to_firstNF (
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
  PRIMARY KEY `revers_thirdNF` (`TrackId`, `PlaylistId`, `OrderId`)
);

INSERT IGNORE INTO revers_thirdNF_to_firstNF (
  SELECT Art.ArtistId, Art.ArtistName,
         Alb.AlbumId, Alb.AlbumTitle,
         Track.TrackId, Track.TrackName, TrackInfo.TrackLength, TrackInfo.TrackGenre, TrackInfo.TrackPrice,
         Pl.PlaylistId, Pl.PlaylistName,
         Ord.OrderId, Cust.CustomerId, Cust.CustomerName, CustInfo.CustomerEmail,
         Ord.OrderDate, CustInfo.DeliveryAddress,
         OrdInf.OrderTrackQuantity FROM thirdNF_Artists AS Art
    INNER JOIN thirdNF_Albums AS Alb
      ON Art.ArtistId = Alb.ArtistId
    INNER JOIN thirdNF_Tracks AS Track
      ON Track.AlbumId = Alb.AlbumId
    INNER JOIN thirdNF_TracksInfo AS TrackInfo
      ON Track.TrackName = TrackInfo.TrackName
    INNER JOIN thirdNF_PlaylistsInfo AS PlInfo
      ON PlInfo.TrackId = Track.TrackId
    INNER JOIN thirdNF_Playlists AS Pl
      ON Pl.PlaylistId = PlInfo.PlaylistId
    INNER JOIN thirdNF_OrdersInfo AS OrdInf
      ON OrdInf.TrackId = Track.TrackId
    INNER JOIN thirdNF_Orders AS Ord
      ON Ord.OrderId = OrdInf.OrderId
    INNER JOIN thirdNF_Customers AS Cust
      ON Cust.CustomerId = Ord.CustomerId
    INNER JOIN thirdNF_CustomersInfo AS CustInfo
      ON Cust.CustomerName = CustInfo.CustomerName);

-- *****************************************
-- Создание таблиц для НФ Бойса-Кода
-- К счастью длина, жанр и цена трека не могут определить его название.
-- Но вот похоже приходится думать, что адрес может определить имя, Email может определить имя, и Email соотносится с адресом (я вычислю тебя по IP)
-- Разобъем таблицу CustomersInfo, при этом потеряем ФЗ Email <-> Address

DROP TABLE IF EXISTS NFBK_Artists;
DROP TABLE IF EXISTS NFBK_Albums;
DROP TABLE IF EXISTS NFBK_Tracks;
DROP TABLE IF EXISTS NFBK_TracksInfo;
DROP TABLE IF EXISTS NFBK_Playlists;
DROP TABLE IF EXISTS NFBK_PlaylistsInfo;
DROP TABLE IF EXISTS NFBK_Orders;
DROP TABLE IF EXISTS NFBK_OrdersInfo;
DROP TABLE IF EXISTS NFBK_Customers;
DROP TABLE IF EXISTS NFBK_CustomersEmail;
DROP TABLE IF EXISTS NFBK_CustomersAddress;
CREATE TABLE NFBK_Artists (
  ArtistId int NOT NULL PRIMARY KEY,
  ArtistName varchar(120) NOT NULL
);
CREATE TABLE NFBK_Albums (
  AlbumId int NOT NULL PRIMARY KEY,
  AlbumTitle varchar(120) NOT NULL,
  ArtistId int NOT NULL
);
CREATE TABLE NFBK_Tracks (
  TrackId int NOT NULL PRIMARY KEY,
  TrackName varchar(200) NOT NULL,
  AlbumId int NOT NULL
);
CREATE TABLE NFBK_TracksInfo (
  TrackName varchar(200) NOT NULL PRIMARY KEY,
  TrackLength bigint NOT NULL,
  TrackGenre varchar(120) NOT NULL,
  TrackPrice decimal(10,2) NOT NULL
);
CREATE TABLE NFBK_Playlists (
  PlaylistId int NOT NULL PRIMARY KEY,
  PlaylistName varchar(120) NOT NULL
);
CREATE TABLE NFBK_PlaylistsInfo (
  PlaylistId int NOT NULL,
  TrackId int NOT NULL,
  PRIMARY KEY `BK_NF_pl` (`PlaylistId`, `TrackId`)
);
CREATE TABLE NFBK_Orders (
  OrderId int NOT NULL PRIMARY KEY,
  CustomerId int NOT NULL,
  OrderDate date NOT NULL
);
CREATE TABLE NFBK_OrdersInfo (
  OrderId int NOT NULL,
  TrackId int NOT NULL,
  OrderTrackQuantity int NOT NULL,
  PRIMARY KEY `BK_NF_ord` (`TrackId`, `OrderId`)
);
CREATE TABLE NFBK_Customers (
  CustomerId int NOT NULL PRIMARY KEY,
  CustomerName varchar(60) NOT NULL
);
CREATE TABLE NFBK_CustomersEmail (
  CustomerName varchar(60) NOT NULL PRIMARY KEY,
  CustomerEmail varchar(60) NOT NULL
);
CREATE TABLE NFBK_CustomersAddress (
  CustomerName varchar(60) NOT NULL PRIMARY KEY,
  DeliveryAddress varchar(70) NOT NULL
);

-- Заполним
INSERT INTO NFBK_Artists SELECT * FROM thirdNF_Artists;
INSERT INTO NFBK_Albums SELECT * FROM thirdNF_Albums;
INSERT INTO NFBK_Tracks SELECT * FROM thirdNF_Tracks;
INSERT INTO NFBK_TracksInfo SELECT * FROM thirdNF_TracksInfo;
INSERT INTO NFBK_Playlists SELECT * FROM thirdNF_Playlists;
INSERT INTO NFBK_PlaylistsInfo SELECT * FROM thirdNF_PlaylistsInfo;
INSERT INTO NFBK_Orders SELECT * FROM thirdNF_Orders;
INSERT INTO NFBK_OrdersInfo SELECT * FROM thirdNF_OrdersInfo;
INSERT INTO NFBK_Customers SELECT * FROM thirdNF_Customers;
INSERT IGNORE INTO NFBK_CustomersEmail SELECT CustomerName, CustomerEmail FROM thirdNF_CustomersInfo;
INSERT IGNORE INTO NFBK_CustomersAddress SELECT CustomerName, DeliveryAddress FROM thirdNF_CustomersInfo;

-- Восстановим исходную в 1НФ
DROP TABLE IF EXISTS revers_NFBK_to_firstNF;
CREATE TABLE revers_NFBK_to_firstNF (
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
  PRIMARY KEY `revers_NFBK` (`TrackId`, `PlaylistId`, `OrderId`)
);

INSERT IGNORE INTO revers_NFBK_to_firstNF (
  SELECT Art.ArtistId, Art.ArtistName,
         Alb.AlbumId, Alb.AlbumTitle,
         Track.TrackId, Track.TrackName, TrackInfo.TrackLength, TrackInfo.TrackGenre, TrackInfo.TrackPrice,
         Pl.PlaylistId, Pl.PlaylistName,
         Ord.OrderId, Cust.CustomerId, Cust.CustomerName, CustEm.CustomerEmail,
         Ord.OrderDate, CustAd.DeliveryAddress,
         OrdInf.OrderTrackQuantity FROM NFBK_Artists AS Art
    INNER JOIN NFBK_Albums AS Alb
      ON Art.ArtistId = Alb.ArtistId
    INNER JOIN NFBK_Tracks AS Track
      ON Track.AlbumId = Alb.AlbumId
    INNER JOIN NFBK_TracksInfo AS TrackInfo
      ON Track.TrackName = TrackInfo.TrackName
    INNER JOIN NFBK_PlaylistsInfo AS PlInfo
      ON PlInfo.TrackId = Track.TrackId
    INNER JOIN NFBK_Playlists AS Pl
      ON Pl.PlaylistId = PlInfo.PlaylistId
    INNER JOIN NFBK_OrdersInfo AS OrdInf
      ON OrdInf.TrackId = Track.TrackId
    INNER JOIN NFBK_Orders AS Ord
      ON Ord.OrderId = OrdInf.OrderId
    INNER JOIN NFBK_Customers AS Cust
      ON Cust.CustomerId = Ord.CustomerId
    INNER JOIN NFBK_CustomersEmail AS CustEm
      ON Cust.CustomerName = CustEm.CustomerName
    INNER JOIN NFBK_CustomersAddress AS CustAd
      ON Cust.CustomerName = CustAd.CustomerName);

-- *****************************************
-- Создание таблиц для 4 НФ
-- Она полностью повторяет НФБК. Я не вижу ни каких зависимостей вида X->>Y|Z
-- Сложно представить, что при добавлении длины песни, не обязателен ее жанр и цена

DROP TABLE IF EXISTS fourthNF_Artists;
DROP TABLE IF EXISTS fourthNF_Albums;
DROP TABLE IF EXISTS fourthNF_Tracks;
DROP TABLE IF EXISTS fourthNF_TracksInfo;
DROP TABLE IF EXISTS fourthNF_Playlists;
DROP TABLE IF EXISTS fourthNF_PlaylistsInfo;
DROP TABLE IF EXISTS fourthNF_Orders;
DROP TABLE IF EXISTS fourthNF_OrdersInfo;
DROP TABLE IF EXISTS fourthNF_Customers;
DROP TABLE IF EXISTS fourthNF_CustomersEmail;
DROP TABLE IF EXISTS fourthNF_CustomersAddress;
CREATE TABLE fourthNF_Artists (
  ArtistId int NOT NULL PRIMARY KEY,
  ArtistName varchar(120) NOT NULL
);
CREATE TABLE fourthNF_Albums (
  AlbumId int NOT NULL PRIMARY KEY,
  AlbumTitle varchar(120) NOT NULL,
  ArtistId int NOT NULL
);
CREATE TABLE fourthNF_Tracks (
  TrackId int NOT NULL PRIMARY KEY,
  TrackName varchar(200) NOT NULL,
  AlbumId int NOT NULL
);
CREATE TABLE fourthNF_TracksInfo (
  TrackName varchar(200) NOT NULL PRIMARY KEY,
  TrackLength bigint NOT NULL,
  TrackGenre varchar(120) NOT NULL,
  TrackPrice decimal(10,2) NOT NULL
);
CREATE TABLE fourthNF_Playlists (
  PlaylistId int NOT NULL PRIMARY KEY,
  PlaylistName varchar(120) NOT NULL
);
CREATE TABLE fourthNF_PlaylistsInfo (
  PlaylistId int NOT NULL,
  TrackId int NOT NULL,
  PRIMARY KEY `fourth_NF_pl` (`PlaylistId`, `TrackId`)
);
CREATE TABLE fourthNF_Orders (
  OrderId int NOT NULL PRIMARY KEY,
  CustomerId int NOT NULL,
  OrderDate date NOT NULL
);
CREATE TABLE fourthNF_OrdersInfo (
  OrderId int NOT NULL,
  TrackId int NOT NULL,
  OrderTrackQuantity int NOT NULL,
  PRIMARY KEY `fourth_NF_ord` (`TrackId`, `OrderId`)
);
CREATE TABLE fourthNF_Customers (
  CustomerId int NOT NULL PRIMARY KEY,
  CustomerName varchar(60) NOT NULL
);
CREATE TABLE fourthNF_CustomersEmail (
  CustomerName varchar(60) NOT NULL PRIMARY KEY,
  CustomerEmail varchar(60) NOT NULL
);
CREATE TABLE fourthNF_CustomersAddress (
  CustomerName varchar(60) NOT NULL PRIMARY KEY,
  DeliveryAddress varchar(70) NOT NULL
);

-- Заполним
INSERT INTO fourthNF_Artists SELECT * FROM NFBK_Artists;
INSERT INTO fourthNF_Albums SELECT * FROM NFBK_Albums;
INSERT INTO fourthNF_Tracks SELECT * FROM NFBK_Tracks;
INSERT INTO fourthNF_TracksInfo SELECT * FROM NFBK_TracksInfo;
INSERT INTO fourthNF_Playlists SELECT * FROM NFBK_Playlists;
INSERT INTO fourthNF_PlaylistsInfo SELECT * FROM NFBK_PlaylistsInfo;
INSERT INTO fourthNF_Orders SELECT * FROM NFBK_Orders;
INSERT INTO fourthNF_OrdersInfo SELECT * FROM NFBK_OrdersInfo;
INSERT INTO fourthNF_Customers SELECT * FROM NFBK_Customers;
INSERT INTO fourthNF_CustomersEmail SELECT * FROM NFBK_CustomersEmail;
INSERT INTO fourthNF_CustomersAddress SELECT * FROM NFBK_CustomersAddress;

-- Восстановим исходную в 1НФ
DROP TABLE IF EXISTS revers_fourthNF_to_firstNF;
CREATE TABLE revers_fourthNF_to_firstNF (
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
  PRIMARY KEY `revers_fourthNF` (`TrackId`, `PlaylistId`, `OrderId`)
);

INSERT IGNORE INTO revers_fourthNF_to_firstNF (
  SELECT Art.ArtistId, Art.ArtistName,
         Alb.AlbumId, Alb.AlbumTitle,
         Track.TrackId, Track.TrackName, TrackInfo.TrackLength, TrackInfo.TrackGenre, TrackInfo.TrackPrice,
         Pl.PlaylistId, Pl.PlaylistName,
         Ord.OrderId, Cust.CustomerId, Cust.CustomerName, CustEm.CustomerEmail,
         Ord.OrderDate, CustAd.DeliveryAddress,
         OrdInf.OrderTrackQuantity FROM fourthNF_Artists AS Art
    INNER JOIN fourthNF_Albums AS Alb
      ON Art.ArtistId = Alb.ArtistId
    INNER JOIN fourthNF_Tracks AS Track
      ON Track.AlbumId = Alb.AlbumId
    INNER JOIN fourthNF_TracksInfo AS TrackInfo
      ON Track.TrackName = TrackInfo.TrackName
    INNER JOIN fourthNF_PlaylistsInfo AS PlInfo
      ON PlInfo.TrackId = Track.TrackId
    INNER JOIN fourthNF_Playlists AS Pl
      ON Pl.PlaylistId = PlInfo.PlaylistId
    INNER JOIN fourthNF_OrdersInfo AS OrdInf
      ON OrdInf.TrackId = Track.TrackId
    INNER JOIN fourthNF_Orders AS Ord
      ON Ord.OrderId = OrdInf.OrderId
    INNER JOIN fourthNF_Customers AS Cust
      ON Cust.CustomerId = Ord.CustomerId
    INNER JOIN fourthNF_CustomersEmail AS CustEm
      ON Cust.CustomerName = CustEm.CustomerName
    INNER JOIN fourthNF_CustomersAddress AS CustAd
      ON Cust.CustomerName = CustAd.CustomerName);

-- *****************************************
-- Создание таблиц для 5 НФ
-- Отсутсвуют сложные зависимости соединения, повторяет 4НФ
DROP TABLE IF EXISTS fifthNF_Artists;
DROP TABLE IF EXISTS fifthNF_Albums;
DROP TABLE IF EXISTS fifthNF_Tracks;
DROP TABLE IF EXISTS fifthNF_TracksInfo;
DROP TABLE IF EXISTS fifthNF_Playlists;
DROP TABLE IF EXISTS fifthNF_PlaylistsInfo;
DROP TABLE IF EXISTS fifthNF_Orders;
DROP TABLE IF EXISTS fifthNF_OrdersInfo;
DROP TABLE IF EXISTS fifthNF_Customers;
DROP TABLE IF EXISTS fifthNF_CustomersEmail;
DROP TABLE IF EXISTS fifthNF_CustomersAddress;
CREATE TABLE fifthNF_Artists (
  ArtistId int NOT NULL PRIMARY KEY,
  ArtistName varchar(120) NOT NULL
);
CREATE TABLE fifthNF_Albums (
  AlbumId int NOT NULL PRIMARY KEY,
  AlbumTitle varchar(120) NOT NULL,
  ArtistId int NOT NULL
);
CREATE TABLE fifthNF_Tracks (
  TrackId int NOT NULL PRIMARY KEY,
  TrackName varchar(200) NOT NULL,
  AlbumId int NOT NULL
);
CREATE TABLE fifthNF_TracksInfo (
  TrackName varchar(200) NOT NULL PRIMARY KEY,
  TrackLength bigint NOT NULL,
  TrackGenre varchar(120) NOT NULL,
  TrackPrice decimal(10,2) NOT NULL
);
CREATE TABLE fifthNF_Playlists (
  PlaylistId int NOT NULL PRIMARY KEY,
  PlaylistName varchar(120) NOT NULL
);
CREATE TABLE fifthNF_PlaylistsInfo (
  PlaylistId int NOT NULL,
  TrackId int NOT NULL,
  PRIMARY KEY `fifth_NF_pl` (`PlaylistId`, `TrackId`)
);
CREATE TABLE fifthNF_Orders (
  OrderId int NOT NULL PRIMARY KEY,
  CustomerId int NOT NULL,
  OrderDate date NOT NULL
);
CREATE TABLE fifthNF_OrdersInfo (
  OrderId int NOT NULL,
  TrackId int NOT NULL,
  OrderTrackQuantity int NOT NULL,
  PRIMARY KEY `fifth_NF_ord` (`TrackId`, `OrderId`)
);
CREATE TABLE fifthNF_Customers (
  CustomerId int NOT NULL PRIMARY KEY,
  CustomerName varchar(60) NOT NULL
);
CREATE TABLE fifthNF_CustomersEmail (
  CustomerName varchar(60) NOT NULL PRIMARY KEY,
  CustomerEmail varchar(60) NOT NULL
);
CREATE TABLE fifthNF_CustomersAddress (
  CustomerName varchar(60) NOT NULL PRIMARY KEY,
  DeliveryAddress varchar(70) NOT NULL
);

-- Заполним
INSERT INTO fifthNF_Artists SELECT * FROM fourthNF_Artists;
INSERT INTO fifthNF_Albums SELECT * FROM fourthNF_Albums;
INSERT INTO fifthNF_Tracks SELECT * FROM fourthNF_Tracks;
INSERT INTO fifthNF_TracksInfo SELECT * FROM fourthNF_TracksInfo;
INSERT INTO fifthNF_Playlists SELECT * FROM fourthNF_Playlists;
INSERT INTO fifthNF_PlaylistsInfo SELECT * FROM fourthNF_PlaylistsInfo;
INSERT INTO fifthNF_Orders SELECT * FROM fourthNF_Orders;
INSERT INTO fifthNF_OrdersInfo SELECT * FROM fourthNF_OrdersInfo;
INSERT INTO fifthNF_Customers SELECT * FROM fourthNF_Customers;
INSERT INTO fifthNF_CustomersEmail SELECT * FROM fourthNF_CustomersEmail;
INSERT INTO fifthNF_CustomersAddress SELECT * FROM fourthNF_CustomersAddress;

-- Восстановим исходную в 1НФ
DROP TABLE IF EXISTS revers_fifthNF_to_firstNF;
CREATE TABLE revers_fifthNF_to_firstNF (
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
  PRIMARY KEY `revers_fifthNF` (`TrackId`, `PlaylistId`, `OrderId`)
);

INSERT IGNORE INTO revers_fifthNF_to_firstNF (
  SELECT Art.ArtistId, Art.ArtistName,
         Alb.AlbumId, Alb.AlbumTitle,
         Track.TrackId, Track.TrackName, TrackInfo.TrackLength, TrackInfo.TrackGenre, TrackInfo.TrackPrice,
         Pl.PlaylistId, Pl.PlaylistName,
         Ord.OrderId, Cust.CustomerId, Cust.CustomerName, CustEm.CustomerEmail,
         Ord.OrderDate, CustAd.DeliveryAddress,
         OrdInf.OrderTrackQuantity FROM fifthNF_Artists AS Art
    INNER JOIN fifthNF_Albums AS Alb
      ON Art.ArtistId = Alb.ArtistId
    INNER JOIN fifthNF_Tracks AS Track
      ON Track.AlbumId = Alb.AlbumId
    INNER JOIN fifthNF_TracksInfo AS TrackInfo
      ON Track.TrackName = TrackInfo.TrackName
    INNER JOIN fifthNF_PlaylistsInfo AS PlInfo
      ON PlInfo.TrackId = Track.TrackId
    INNER JOIN fifthNF_Playlists AS Pl
      ON Pl.PlaylistId = PlInfo.PlaylistId
    INNER JOIN fifthNF_OrdersInfo AS OrdInf
      ON OrdInf.TrackId = Track.TrackId
    INNER JOIN fifthNF_Orders AS Ord
      ON Ord.OrderId = OrdInf.OrderId
    INNER JOIN fifthNF_Customers AS Cust
      ON Cust.CustomerId = Ord.CustomerId
    INNER JOIN fifthNF_CustomersEmail AS CustEm
      ON Cust.CustomerName = CustEm.CustomerName
    INNER JOIN fifthNF_CustomersAddress AS CustAd
      ON Cust.CustomerName = CustAd.CustomerName);