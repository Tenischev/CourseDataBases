-- Тенищев Семён А3400

DROP DATABASE Social_network;
CREATE DATABASE Social_network;

USE Social_network;

CREATE TABLE IF NOT EXISTS `pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY -- задаем общую нумерацию для пользователей и групп 
);

CREATE TABLE IF NOT EXISTS `user` (
  `id` int(11) NOT NULL PRIMARY KEY, -- id пользователя берется из таблицы pages
  `name` varchar(30) NOT NULL,
  `birthday` date NOT NULL,
  `telephone` varchar(10) DEFAULT NULL,
  `email` varchar(20) DEFAULT NULL,
  `mother_id` int(11) DEFAULT NULL,
  `father_id` int(11) DEFAULT NULL,
  FOREIGN KEY (`id`) REFERENCES `pages` (`id`),
  FOREIGN KEY (`mother_id`) REFERENCES `user` (`id`),
  FOREIGN KEY (`father_id`) REFERENCES `user` (`id`)
);

CREATE TABLE IF NOT EXISTS `user_pm` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY, -- id личного сообщения
  `from_id` int(11) NOT NULL, -- id отправителя
  `to_id` int(11) NOT NULL, -- id получателя
  `text` text NOT NULL,
  `title` varchar(50) DEFAULT NULL,
  FOREIGN KEY (`from_id`) REFERENCES `user` (`id`),
  FOREIGN KEY (`to_id`) REFERENCES `user` (`id`)
);

CREATE TABLE IF NOT EXISTS `group` (
  `id` int(11) NOT NULL PRIMARY KEY, -- id группы берется из таблицы pages
  `name` varchar(20) NOT NULL,
  `owner_id` int(11) NOT NULL, -- id создателя
  FOREIGN KEY (`id`) REFERENCES `pages` (`id`),
  FOREIGN KEY (`owner_id`) REFERENCES `user` (`id`)
);

CREATE TABLE IF NOT EXISTS `relation_user_group` (
  `pages_id` int(11) NOT NULL, -- id страницы(пользователь либо группа) для кого мы описываем отношение
  `whom_id` int(11) NOT NULL, -- пользователь с которым задается отношение
  `relation` int(11) NOT NULL, -- кодируем отношение: друг, брат, модератор, администратор и тд. 
  PRIMARY KEY `relation_whom_id` (`pages_id`, `whom_id`),
  FOREIGN KEY (`pages_id`) REFERENCES `pages` (`id`),
  FOREIGN KEY (`whom_id`) REFERENCES `user` (`id`)
);

CREATE TABLE IF NOT EXISTS `walls` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY, -- id сообщения
  `pages_id` int(11) NOT NULL, -- id страницы(пользователь либо группа) на чьей стене сообщение
  `who_id` int(11) NOT NULL, -- id страницы(пользователь либо группа) которая оставила это сообщение
  `text` text NOT NULL,
  FOREIGN KEY (`pages_id`) REFERENCES `pages` (`id`),
  FOREIGN KEY (`who_id`) REFERENCES `pages` (`id`)
);

CREATE TABLE IF NOT EXISTS `comments_walls` (
  `id` int(11) NOT NULL  AUTO_INCREMENT PRIMARY KEY, -- id комментария
  `who_id` int(11) NOT NULL, -- id страницы(пользователь либо группа) оставившей комментарий
  `mes_id` int(11) NOT NULL, -- id сообщения к которому комментарий
  `text` text NOT NULL,
  FOREIGN KEY (`who_id`) REFERENCES `pages` (`id`),
  FOREIGN KEY (`mes_id`) REFERENCES `walls` (`id`)
);

-- 1.Добавить двух пользователей(c id=123 и id=321) друг к другу в друзья.
INSERT INTO `pages` VALUES (123), (321);
INSERT INTO `user` (`id`, `name`, `birthday`) VALUES (123, 'Ivan', '1995-10-10'), (321, 'Petr', '1994-05-12');
INSERT INTO `relation_user_group` (`pages_id`, `whom_id`, `relation`) VALUES (123, 321, 4), (321, 123, 4)
  ON DUPLICATE KEY UPDATE `relation` = `relation` | 4;

-- 2. Получить всех друзей некоторого пользователя.
SELECT `whom_id` FROM `relation_user_group` WHERE `pages_id` = SOME_USER_ID AND `relation` & 4;

-- 3. Удалить из друзей пользователя(с id=123) всех друзей его жены.
INSERT INTO `pages` VALUES (111);
INSERT INTO `user` (`id`, `name`, `birthday`) VALUES (111, 'Wife', '1995-12-10');
INSERT INTO `relation_user_group` (`pages_id`, `whom_id`, `relation`) VALUES (123, 111, 128) -- добавляем мужу жену
  ON DUPLICATE KEY UPDATE `relation` = `relation` | 128;
INSERT INTO `relation_user_group` (`pages_id`, `whom_id`, `relation`) VALUES (111, 123, 64) -- добавляем жену мужу
  ON DUPLICATE KEY UPDATE `relation` = `relation` | 64;
INSERT INTO `relation_user_group` (`pages_id`, `whom_id`, `relation`) VALUES (111, 321, 4) -- добавляем жене друга 321
  ON DUPLICATE KEY UPDATE `relation` = `relation` | 4;
UPDATE `relation_user_group` SET `relation` = `relation` ^ 4
  WHERE `pages_id` = 123 AND `whom_id` IN (SELECT * FROM (SELECT `whom_id` FROM `relation_user_group`
                                                           WHERE `pages_id` = 111 AND `relation` & 4) AS P);