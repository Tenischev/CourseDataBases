-- Тенищев Семён А3400

-- *****************************************
-- Создание таблицы для 1 НФ

-- Исследую таблицу.
-- Если отсортировать по TrackId, можно легко увидеть, что треку с id 1 соответсвует 3 плей листа, но общие OrderID, CustomerId, ArtistId, AlbumId
-- треку с id 2, соответсвует как несколько плейлситов, так и два заказа.
-- Трек с заданным id всегда исполняется только одним исполнителем и только в одном альбоме.
-- Если отсортировать по CustomerId, легко видно что у однин id может соответсвовать разным OrderId

-- Хотя имеющиеся данные и не говорят о том что у одного заказчика могут быть разные адреса доставки, из-за формулировки
-- содержимого "оформления заказов на доставку музыкальных композиций на винтажных пластинках до определённого адреса"
-- считаю что, один заказчик может заказывать на разные адреса

-- Итог:
-- ArtistId и AlbumId - один ко многим
-- AlbumId и TrackId - один ко многим
-- TrackId и PlaylistId - один ко многим
-- CustomerId и OrderId - один ко многим
-- TrackId и OrderId - многие ко многим

-- Очевидно необходимо сохранить отношение многие ко многим, но TrackId связан как один ко многим с PlaylistId,
-- а значит индекс получается `TrackId`, `PlaylistId`, `OrderId`
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
DROP TABLE IF EXISTS secondNF_Tracks;
DROP TABLE IF EXISTS secondNF_Playlists;
DROP TABLE IF EXISTS secondNF_Keys;
DROP TABLE IF EXISTS secondNF_Orders;
DROP TABLE IF EXISTS secondNF_OrdersInfo;

-- CREATE TABLE secondNF_PlaylistsInfo ( -- т.к. информации которая зависит от этих двух параметров сразу, нет - связь выносим отдельно
-- Вот здесь не нужно было выносить в отдельную таблицу, т.к. нет никаких нарушений 2НФ(аккуратно посмотрите на определение 2НФ, понятно почему нет нарушений?)

-- Понятно, это ключевые атрибуты, в формулировке говорится о не ключевых атрибутах,
-- т.е. так и так у нас должна была остаться таблица со всеми тремя атрибутами ключа, тогда еще раз

--                          |-> secondNF_Tracks (отделили альбом, исполнителя и информацию о треке)
--                          |
-- firstNF_AudioTrackStore -|               |-> secondNF_Orders (отделили то что завязано на OrderId)
--                          |               |
--                          |->  temptable -|                     |-> secondNF_Playlists (отделили PlaylistName)
--                            TrackId       |                     |
--                            PlaylistId    |-> temptable2 -------|                     |-> secondNF_OrdersInfo (отделили OrderTrackQuantity)
--                            PlaylistName      TrackId           |                     |
--                            OrderId           PlaylistId        |-> temptable3 -------|
--                            CustomerId        PlaylistName          TrackId           |-> осталась таблица ключей
--                            CustomerName      OrderId               PlaylistId               TrackId
--                            CustomerEmail     OrderTrackQuantity    OrderId                  PlaylistId
--                            OrderDate                               OrderTrackQuantity       OrderId
--                            DeliveryAddress
--                            OrderTrackQuantity

CREATE TABLE secondNF_Tracks ( -- вся эта информация не зависит от трек листа и номера заказа
  ArtistId int NOT NULL,
  ArtistName varchar(120) NOT NULL,
  AlbumId int NOT NULL,
  AlbumTitle varchar(120) NOT NULL,
  TrackId int NOT NULL PRIMARY KEY,
  TrackName varchar(200) NOT NULL,
  TrackLength bigint NOT NULL,
  TrackGenre varchar(120) NOT NULL,
  TrackPrice decimal(10,2) NOT NULL
);
CREATE TABLE secondNF_Playlists ( -- название плейлиста не зависит от конкретного трека и заказа, а только от id
  PlaylistId int NOT NULL PRIMARY KEY,
  PlaylistName varchar(120) NOT NULL
);
CREATE TABLE secondNF_Keys ( -- остаток - таблица из ключей
  TrackId int NOT NULL,
  PlaylistId int NOT NULL,
  OrderId int NOT NULL,
  PRIMARY KEY `second_NF_keys` (`PlaylistId`, `TrackId`, `OrderId`)
);
CREATE TABLE secondNF_Orders ( -- вся эта информация зависит только от номера заказа, номер трека и из какого он плейлиста значения не имеет
  OrderId int NOT NULL PRIMARY KEY,
  CustomerId int NOT NULL,
  CustomerName varchar(60) NOT NULL,
  CustomerEmail varchar(60) NOT NULL,
  OrderDate date NOT NULL,
  DeliveryAddress varchar(70) NOT NULL
);
CREATE TABLE secondNF_OrdersInfo ( -- а вот количество треков уже зависит от заказа и трека
  OrderId int NOT NULL,
  TrackId int NOT NULL,
  OrderTrackQuantity int NOT NULL,
  PRIMARY KEY `second_NF_ord` (`TrackId`, `OrderId`)
);

-- Заполняем
INSERT IGNORE INTO secondNF_Tracks SELECT ArtistId, ArtistName, AlbumId, AlbumTitle, TrackId, TrackName, TrackLength, TrackGenre, TrackPrice  FROM firstNF_AudioTrackStore;
INSERT IGNORE INTO secondNF_Playlists SELECT PlaylistId, PlaylistName FROM firstNF_AudioTrackStore;
INSERT IGNORE INTO secondNF_Keys SELECT TrackId, PlaylistId, OrderId FROM firstNF_AudioTrackStore;
INSERT IGNORE INTO secondNF_Orders SELECT OrderId, CustomerId, CustomerName, CustomerEmail, OrderDate, DeliveryAddress FROM firstNF_AudioTrackStore;
INSERT IGNORE INTO secondNF_OrdersInfo SELECT OrderId, TrackId, OrderTrackQuantity FROM firstNF_AudioTrackStore;

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
  SELECT Track.ArtistId, Track.ArtistName, Track.AlbumId, Track.AlbumTitle,
         Track.TrackId, Track.TrackName, Track.TrackLength, Track.TrackGenre, Track.TrackPrice,
         Pl.PlaylistId, Pl.PlaylistName,
         Ord.OrderId, Ord.CustomerId, Ord.CustomerName, Ord.CustomerEmail, Ord.OrderDate, Ord.DeliveryAddress,
         OrdInfo.OrderTrackQuantity FROM secondNF_Keys AS K
    INNER JOIN secondNF_OrdersInfo AS OrdInfo
      ON K.TrackId = OrdInfo.TrackId AND K.OrderId = OrdInfo.OrderId
    INNER JOIN secondNF_Orders AS Ord
      ON K.OrderId = Ord.OrderId
    INNER JOIN secondNF_Playlists AS Pl
      ON K.PlaylistId = Pl.PlaylistId
    INNER JOIN secondNF_Tracks AS Track
      ON K.TrackId = Track.TrackId);

-- *****************************************
-- Создание таблиц для 3 НФ
-- Начинаем расчлениять таблички по транзитивным ФЗ
DROP TABLE IF EXISTS thirdNF_Artists;
DROP TABLE IF EXISTS thirdNF_Albums;
DROP TABLE IF EXISTS thirdNF_Tracks;
DROP TABLE IF EXISTS thirdNF_Playlists;
DROP TABLE IF EXISTS thirdNF_Keys;
DROP TABLE IF EXISTS thirdNF_Orders;
DROP TABLE IF EXISTS thirdNF_OrdersInfo;
DROP TABLE IF EXISTS thirdNF_Customers;

-- Вставлю табличку комментарием что бы было легче
-- CREATE TABLE secondNF_Tracks (
--  ArtistId int NOT NULL,
--  ArtistName varchar(120) NOT NULL,
--  AlbumId int NOT NULL,
--  AlbumTitle varchar(120) NOT NULL,
--  TrackId int NOT NULL PRIMARY KEY,
--  TrackName varchar(200) NOT NULL,
--  TrackLength bigint NOT NULL,
--  TrackGenre varchar(120) NOT NULL,
--  TrackPrice decimal(10,2) NOT NULL,
-- );
-- Из нашего исследования знаем, что трек одназначно задает свой альбом, а альбом одназначно задает испонителя.

CREATE TABLE thirdNF_Tracks ( -- очевидно что название, длина, жанр, цена зависят от только от id самого трека
  TrackId int NOT NULL PRIMARY KEY,
  TrackName varchar(200) NOT NULL,
  TrackLength bigint NOT NULL,
  TrackGenre varchar(120) NOT NULL,
  TrackPrice decimal(10,2) NOT NULL,
  AlbumId int NOT NULL -- определяем альбом
);
CREATE TABLE thirdNF_Albums ( -- название альбома определяется его id
  AlbumId int NOT NULL PRIMARY KEY,
  AlbumTitle varchar(120) NOT NULL,
  ArtistId int NOT NULL -- определяем исполнителя
);
CREATE TABLE thirdNF_Artists ( -- имя исполнителя определяется его id
  ArtistId int NOT NULL PRIMARY KEY,
  ArtistName varchar(120) NOT NULL
);

-- Следующая таблица, тут упрощать как бы некуда
-- CREATE TABLE secondNF_Playlists (
--  PlaylistId int NOT NULL PRIMARY KEY,
--  PlaylistName varchar(120) NOT NULL
-- );
CREATE TABLE thirdNF_Playlists (
  PlaylistId int NOT NULL PRIMARY KEY,
  PlaylistName varchar(120) NOT NULL
);

-- CREATE TABLE secondNF_Keys (
--  TrackId int NOT NULL,
--  PlaylistId int NOT NULL,
--  OrderId int NOT NULL,
--  PRIMARY KEY `second_NF_keys` (`PlaylistId`, `TrackId`, `OrderId`)
-- );
-- Опять же в определении у нас говорилось только о "неключевых" атрибутах и их отношениях, эта таблица сохраняется
CREATE TABLE thirdNF_Keys (
  TrackId int NOT NULL,
  PlaylistId int NOT NULL,
  OrderId int NOT NULL,
  PRIMARY KEY `third_NF_keys` (`PlaylistId`, `TrackId`, `OrderId`)
);

-- CREATE TABLE secondNF_Orders (
--  OrderId int NOT NULL PRIMARY KEY,
--  CustomerId int NOT NULL,
--  CustomerName varchar(60) NOT NULL,
--  CustomerEmail varchar(60) NOT NULL,
--  OrderDate date NOT NULL,
--  DeliveryAddress varchar(70) NOT NULL
-- );
-- Можно заметить, что CustomerName, CustomerEmail зависят от CustomerId, а не от id заказа
CREATE TABLE thirdNF_Orders (
  OrderId int NOT NULL PRIMARY KEY,
  CustomerId int NOT NULL, -- определили заказчика
  OrderDate date NOT NULL,
  DeliveryAddress varchar(70) NOT NULL -- вспоминаем наложенные в начале логические условия
);
CREATE TABLE thirdNF_Customers ( -- вынесли информацию зависящую только от заказчика
  CustomerId int NOT NULL PRIMARY KEY,
  CustomerName varchar(60) NOT NULL,
  CustomerEmail varchar(60) NOT NULL
);

-- Как есть
-- CREATE TABLE secondNF_OrdersInfo (
--  OrderId int NOT NULL,
--  TrackId int NOT NULL,
--  OrderTrackQuantity int NOT NULL,
--  PRIMARY KEY `second_NF_ord` (`TrackId`, `OrderId`)
-- );
CREATE TABLE thirdNF_OrdersInfo (
  OrderId int NOT NULL,
  TrackId int NOT NULL,
  OrderTrackQuantity int NOT NULL,
  PRIMARY KEY `third_NF_ord` (`TrackId`, `OrderId`)
);

-- Заполним
INSERT IGNORE  INTO thirdNF_Artists SELECT ArtistId, ArtistName FROM secondNF_Tracks;
INSERT IGNORE  INTO thirdNF_Albums SELECT AlbumId, AlbumTitle, ArtistId FROM secondNF_Tracks;
INSERT IGNORE INTO thirdNF_Tracks SELECT TrackId, TrackName, TrackLength, TrackGenre, TrackPrice, AlbumId FROM secondNF_Tracks;
INSERT INTO thirdNF_Playlists SELECT * FROM secondNF_Playlists;
INSERT INTO thirdNF_Keys SELECT * FROM secondNF_Keys;
INSERT IGNORE INTO thirdNF_Orders SELECT OrderId, CustomerId, OrderDate, DeliveryAddress FROM secondNF_Orders;
INSERT IGNORE INTO thirdNF_Customers SELECT CustomerId, CustomerName, CustomerEmail FROM secondNF_Orders;
INSERT INTO thirdNF_OrdersInfo SELECT * FROM secondNF_OrdersInfo;

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
         Track.TrackId, Track.TrackName, Track.TrackLength, Track.TrackGenre, Track.TrackPrice,
         Pl.PlaylistId, Pl.PlaylistName,
         Ord.OrderId, Cust.CustomerId, Cust.CustomerName, Cust.CustomerEmail, Ord.OrderDate, Ord.DeliveryAddress,
         OrdInfo.OrderTrackQuantity From thirdNF_Keys AS K
    INNER JOIN thirdNF_OrdersInfo AS OrdInfo
      ON K.OrderId = OrdInfo.OrderId AND K.TrackId = OrdInfo.TrackId
    INNER JOIN thirdNF_Orders AS Ord
      ON Ord.OrderId = K.OrderId
    INNER JOIN thirdNF_Customers AS Cust
      ON Cust.CustomerId = Ord.CustomerId
    INNER JOIN thirdNF_Tracks AS Track
      ON K.TrackId = Track.TrackId
    INNER JOIN thirdNF_Albums AS Alb
      ON Track.AlbumId = Alb.AlbumId
    INNER JOIN thirdNF_Artists AS Art
      ON Alb.ArtistId = Art.ArtistId
    INNER JOIN thirdNF_Playlists AS Pl
      ON K.PlaylistId = Pl.PlaylistId);

-- *****************************************
-- Создание таблиц для НФ Бойса-Кода

DROP TABLE IF EXISTS NFBK_Artists;
DROP TABLE IF EXISTS NFBK_Albums;
DROP TABLE IF EXISTS NFBK_Tracks;
DROP TABLE IF EXISTS NFBK_Playlists;
DROP TABLE IF EXISTS NFBK_Keys;
DROP TABLE IF EXISTS NFBK_Orders;
DROP TABLE IF EXISTS NFBK_OrdersInfo;
DROP TABLE IF EXISTS NFBK_CustomersName;
DROP TABLE IF EXISTS NFBK_CustomersEmail;

CREATE TABLE NFBK_Artists (
  ArtistId int NOT NULL PRIMARY KEY,
  ArtistName varchar(120) NOT NULL
);
CREATE TABLE NFBK_Albums (
  AlbumId int NOT NULL PRIMARY KEY,
  AlbumTitle varchar(120) NOT NULL,
  ArtistId int NOT NULL
);
-- К счастью длина, жанр и цена трека не могут определить его название.
-- Более того у нас в базе есть песни с одинаковым названием но разной продолжительностью и стоимостью
CREATE TABLE NFBK_Tracks (
  TrackId int NOT NULL PRIMARY KEY,
  TrackName varchar(200) NOT NULL,
  TrackLength bigint NOT NULL,
  TrackGenre varchar(120) NOT NULL,
  TrackPrice decimal(10,2) NOT NULL,
  AlbumId int NOT NULL
);
CREATE TABLE NFBK_Playlists (
  PlaylistId int NOT NULL PRIMARY KEY,
  PlaylistName varchar(120) NOT NULL
);
CREATE TABLE NFBK_Keys (
  TrackId int NOT NULL,
  PlaylistId int NOT NULL,
  OrderId int NOT NULL,
  PRIMARY KEY `BK_NF_keys` (`PlaylistId`, `TrackId`, `OrderId`)
);
CREATE TABLE NFBK_Orders (
  OrderId int NOT NULL PRIMARY KEY,
  CustomerId int NOT NULL,
  OrderDate date NOT NULL,
  DeliveryAddress varchar(70) NOT NULL
);
CREATE TABLE NFBK_OrdersInfo (
  OrderId int NOT NULL,
  TrackId int NOT NULL,
  OrderTrackQuantity int NOT NULL,
  PRIMARY KEY `BK_NF_ord` (`TrackId`, `OrderId`)
);
-- Но вот похоже приходится думать, что Name <-> Email. Разобъем таблицу Customers
CREATE TABLE NFBK_CustomersName (
  CustomerId int NOT NULL PRIMARY KEY,
  CustomerName varchar(60) NOT NULL
);
CREATE TABLE NFBK_CustomersEmail (
  CustomerId int NOT NULL PRIMARY KEY,
  CustomerEmail varchar(60) NOT NULL
);

-- Заполним
INSERT INTO NFBK_Artists SELECT * FROM thirdNF_Artists;
INSERT INTO NFBK_Albums SELECT * FROM thirdNF_Albums;
INSERT INTO NFBK_Tracks SELECT * FROM thirdNF_Tracks;
INSERT INTO NFBK_Playlists SELECT * FROM thirdNF_Playlists;
INSERT INTO NFBK_Keys SELECT * FROM thirdNF_Keys;
INSERT INTO NFBK_Orders SELECT * FROM thirdNF_Orders;
INSERT INTO NFBK_OrdersInfo SELECT * FROM thirdNF_OrdersInfo;
INSERT INTO NFBK_CustomersName SELECT CustomerId, CustomerName FROM thirdNF_Customers;
INSERT INTO NFBK_CustomersEmail SELECT CustomerId, CustomerEmail FROM thirdNF_Customers;

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
         Track.TrackId, Track.TrackName, Track.TrackLength, Track.TrackGenre, Track.TrackPrice,
         Pl.PlaylistId, Pl.PlaylistName,
         Ord.OrderId, CustN.CustomerId, CustN.CustomerName, CustE.CustomerEmail, Ord.OrderDate, Ord.DeliveryAddress,
         OrdInfo.OrderTrackQuantity FROM NFBK_Keys AS K
     INNER JOIN NFBK_OrdersInfo AS OrdInfo
       ON K.OrderId = OrdInfo.OrderId AND K.TrackId = OrdInfo.TrackId
     INNER JOIN NFBK_Orders AS Ord
       ON Ord.OrderId = K.OrderId
     INNER JOIN NFBK_CustomersName AS CustN
       ON Ord.CustomerId = CustN.CustomerId
     INNER JOIN NFBK_CustomersEmail AS CustE
       ON Ord.CustomerId = CustE.CustomerId
     INNER JOIN NFBK_Tracks AS Track
       ON K.TrackId = Track.TrackId
     INNER JOIN NFBK_Albums AS Alb
       ON Track.AlbumId = Alb.AlbumId
     INNER JOIN NFBK_Artists AS Art
       ON Alb.ArtistId = Art.ArtistId
     INNER JOIN NFBK_Playlists AS Pl
       ON K.PlaylistId = Pl.PlaylistId);

-- *****************************************
-- Создание таблиц для 4 НФ
-- Счастье привалило, нам есть что менять!

DROP TABLE IF EXISTS fourthNF_Artists;
DROP TABLE IF EXISTS fourthNF_Albums;
DROP TABLE IF EXISTS fourthNF_Tracks;
DROP TABLE IF EXISTS fourthNF_Playlists;
DROP TABLE IF EXISTS fourthNF_PlaylistsKey;
DROP TABLE IF EXISTS fourthNF_OrdersKey;
DROP TABLE IF EXISTS fourthNF_Orders;
DROP TABLE IF EXISTS fourthNF_OrdersInfo;
DROP TABLE IF EXISTS fourthNF_CustomersName;
DROP TABLE IF EXISTS fourthNF_CustomersEmail;

CREATE TABLE fourthNF_Artists ( -- простой ключ + НФБК
  ArtistId int NOT NULL PRIMARY KEY,
  ArtistName varchar(120) NOT NULL
);
CREATE TABLE fourthNF_Albums ( -- простой ключ + НФБК
  AlbumId int NOT NULL PRIMARY KEY,
  AlbumTitle varchar(120) NOT NULL,
  ArtistId int NOT NULL
);
CREATE TABLE fourthNF_Tracks ( -- простой ключ + НФБК
  TrackId int NOT NULL PRIMARY KEY,
  TrackName varchar(200) NOT NULL,
  TrackLength bigint NOT NULL,
  TrackGenre varchar(120) NOT NULL,
  TrackPrice decimal(10,2) NOT NULL,
  AlbumId int NOT NULL
);
CREATE TABLE fourthNF_Playlists ( -- простой ключ + НФБК
  PlaylistId int NOT NULL PRIMARY KEY,
  PlaylistName varchar(120) NOT NULL
);

-- CREATE TABLE NFBK_Keys (
--   TrackId int NOT NULL,
--   PlaylistId int NOT NULL,
--   OrderId int NOT NULL
--   PRIMARY KEY `BK_NF_keys` (`PlaylistId`, `TrackId`, `OrderId`)
-- );
-- Да, теперь тут есть нарушение, PlaylistId и OrderId между собой никак не связанны, так что при добавлении нового заказа
-- нам придется вставлять не одну строку а k строк, где k - количество плейлистов где этот трек есть, выполним декомпозицию
CREATE TABLE fourthNF_OrdersKey (
  TrackId int NOT NULL,
  OrderId int NOT NULL,
  PRIMARY KEY `fourth_NF_order_keys` (`TrackId`, `OrderId`)
);
CREATE TABLE fourthNF_PlaylistsKey (
  TrackId int NOT NULL,
  PlaylistId int NOT NULL,
  PRIMARY KEY `fourth_NF_playlist_keys` (`PlaylistId`, `TrackId`)
);

CREATE TABLE fourthNF_Orders ( -- простой ключ + НФБК
  OrderId int NOT NULL PRIMARY KEY,
  CustomerId int NOT NULL,
  OrderDate date NOT NULL,
  DeliveryAddress varchar(70) NOT NULL
);
CREATE TABLE fourthNF_OrdersInfo ( -- составной ключ, но только OrderId ->> TrackId и (OrderId, TrackId) -> OrderTrackQuantity
  OrderId int NOT NULL,
  TrackId int NOT NULL,
  OrderTrackQuantity int NOT NULL,
  PRIMARY KEY `fourth_NF_ord` (`TrackId`, `OrderId`)
);
CREATE TABLE fourthNF_CustomersName ( -- простой ключ + НФБК
  CustomerId int NOT NULL PRIMARY KEY,
  CustomerName varchar(60) NOT NULL
);
CREATE TABLE fourthNF_CustomersEmail ( -- простой ключ + НФБК
  CustomerId int NOT NULL PRIMARY KEY,
  CustomerEmail varchar(60) NOT NULL
);

-- Заполним
INSERT INTO fourthNF_Artists SELECT * FROM NFBK_Artists;
INSERT INTO fourthNF_Albums SELECT * FROM NFBK_Albums;
INSERT INTO fourthNF_Tracks SELECT * FROM NFBK_Tracks;
INSERT INTO fourthNF_Playlists SELECT * FROM NFBK_Playlists;
INSERT IGNORE INTO fourthNF_PlaylistsKey SELECT TrackId, PlaylistId FROM NFBK_Keys;
INSERT IGNORE INTO fourthNF_OrdersKey SELECT TrackId, OrderId FROM NFBK_Keys;
INSERT INTO fourthNF_Orders SELECT * FROM NFBK_Orders;
INSERT INTO fourthNF_OrdersInfo SELECT * FROM NFBK_OrdersInfo;
INSERT INTO fourthNF_CustomersName SELECT * FROM NFBK_CustomersName;
INSERT INTO fourthNF_CustomersEmail SELECT * FROM NFBK_CustomersEmail;

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
         Track.TrackId, Track.TrackName, Track.TrackLength, Track.TrackGenre, Track.TrackPrice,
         Pl.PlaylistId, Pl.PlaylistName,
         Ord.OrderId, CustN.CustomerId, CustN.CustomerName, CustE.CustomerEmail,
         Ord.OrderDate, Ord.DeliveryAddress,
         OrdInfo.OrderTrackQuantity FROM fourthNF_OrdersKey AS OrdKeys
    INNER JOIN fourthNF_PlaylistsKey AS PlKeys
      ON OrdKeys.TrackId = PlKeys.TrackId
    INNER JOIN fourthNF_OrdersInfo AS OrdInfo
      ON OrdKeys.OrderId = OrdInfo.OrderId AND OrdKeys.TrackId = OrdInfo.TrackId
    INNER JOIN fourthNF_Orders AS Ord
      ON OrdKeys.OrderId = Ord.OrderId
    INNER JOIN fourthNF_CustomersName AS CustN
      ON Ord.CustomerId = CustN.CustomerId
    INNER JOIN fourthNF_CustomersEmail AS CustE
      ON Ord.CustomerId = CustE.CustomerId
    INNER JOIN fourthNF_Tracks AS Track
      ON OrdKeys.TrackId = Track.TrackId
    INNER JOIN fourthNF_Albums AS Alb
      ON Track.AlbumId = Alb.AlbumId
    INNER JOIN fourthNF_Artists AS Art
      ON Alb.ArtistId = Art.ArtistId
    INNER JOIN fourthNF_Playlists AS Pl
      ON PlKeys.PlaylistId = Pl.PlaylistId);

-- *****************************************
-- 5 НФ
-- Отсутсвуют нетривиальные зависимости соединения + теорема Дейта-Фейгина, повторяет 4НФ