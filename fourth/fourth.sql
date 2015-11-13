-- Тенищев Семён А3400

-- 1. Имена всех пользователей.
SELECT DisplayName FROM Users

-- 2. Заголовок, текст и имя создателя для 100 последних созданных вопросов.
-- работают обе, но говорят, что первая меньшее число раз сканирует таблицу
SELECT TOP 100 P.Title, P.Body, U.DisplayName
  FROM Posts AS P
    INNER JOIN Users AS U -- Вытаскиваю имя из Users т.к. OwnerDisplayName часто пустой
      ON P.PostTypeId = 1 AND P.OwnerUserId = U.Id
  ORDER BY P.CreationDate DESC

SELECT TOP 100 P.Title, P.Body, (SELECT DisplayName FROM Users WHERE Id = P.OwnerUserId)
  FROM Posts AS P
  WHERE P.PostTypeId = 1
  ORDER BY P.CreationDate DESC

-- 3. Количество зарегистрированных пользователей, вопросов, ответов и тэгов.
-- работают обе, первая выдает в одну строку, вторая в один столбец
SELECT COUNT(Id),
      (SELECT COUNT(Id) FROM Posts WHERE PostTypeId = 1),
      (SELECT COUNT(Id) FROM Posts WHERE PostTypeId = 2),
      (SELECT COUNT(Id) FROM Tags)
 FROM Users

SELECT COUNT(U.Id)
  FROM Users AS U
UNION ALL
SELECT COUNT(P.PostTypeId)
  FROM Posts AS P
  GROUP BY (P.PostTypeId)
  HAVING P.PostTypeId = 1 OR P.PostTypeId = 2
UNION ALL
SELECT COUNT(T.Id)
  FROM Tags AS T

-- 4. Имена и места проживания(Location) пользователей, зарегистрированных в 2015 году, старше 25 лет.
SELECT DisplayName, Location
  FROM Users
  WHERE YEAR(CreationDate) = 2015 AND Age > 25

-- 5. Количество пользователей, зарегистрированных в 2015 году, старше 25 лет.
SELECT COUNT(Id)
  FROM Users
  WHERE YEAR(CreationDate) = 2015 AND Age > 25

-- 6. Количество пользователей, у которых в качестве места проживания указана Germany.
SELECT COUNT(Id)
  FROM Users
  WHERE Location = 'Germany'

-- 7. Места проживания и количество пользователей, указавших соответствующее место проживания в своём профиле.
SELECT Location, COUNT(Location)
  FROM Users
  GROUP BY (Location)

-- 8. Первых 10 пользователей с максимальной репутацией, а также количество вопросов, созданных ими.
SELECT TOP 10 U.Reputation, U.DisplayName, COUNT(P.OwnerUserId)
  FROM Users AS U
    INNER JOIN Posts AS P
      ON P.PostTypeId = 1 AND P.OwnerUserId = U.Id
  GROUP BY U.Reputation, U.DisplayName
  ORDER BY U.Reputation DESC

-- 9. Всех пользователей, задавших не менее трёх вопросов с тэгом 'sql' и ответивших не менее чем на 10 вопросов с тэгом 'java'.
SELECT P1.OwnerUserId
  FROM Posts AS P1
    INNER JOIN Posts AS P2
      ON P1.OwnerUserId = P2.OwnerUserId
      AND P1.PostTypeId = 1
      AND P2.PostTypeId = 2
      AND P1.Tags LIKE '%<sql>%'
    INNER JOIN Posts AS P3
      ON P3.Id = P2.ParentId
      AND P3.PostTypeId = 1 -- страховочка
      AND P3.Tags LIKE '%<java>%'
  GROUP BY P1.OwnerUserId, P1.Tags, P3.Tags
  HAVING COUNT(P1.Tags) > 2 AND COUNT(P3.Tags) > 9

-- 10. Все пары пользователей, таких что каждый из двух оставил хотя бы один комментарий под некоторым ответом другого пользователя.
SELECT C1.UserId, C2.UserId -- или P1.OwnerUserId, P2.OwnerUserId
  FROM Posts AS P1
    INNER JOIN Comments AS C1
      ON C1.PostId = P1.Id
      AND P1.PostTypeId = 2
    INNER JOIN Posts AS P2
      ON C1.UserId = P2.OwnerUserId
      AND P2.PostTypeId = 2
    INNER JOIN Comments AS C2
      ON C2.PostId = P2.Id
      AND C2.UserId = P1.OwnerUserId

-- 11. Количество вопросов, в которых выбранный ответ содержит в два или более раза меньше комментариев, чем некоторый другой ответ на этот же вопрос.
SELECT COUNT(R.cnt) --  количество таких вопросов
  FROM (SELECT P1.Id AS cnt -- выдаст список id вопросов удовлетворяющих требованию
        FROM Posts AS P1
          INNER JOIN Posts AS P2
            ON P2.ParentId = P1.Id -- в P2 ответы на наш вопрос
            AND P1.PostTypeId = 1
            AND P2.PostTypeId = 2
          INNER JOIN Posts AS P3
            ON P3.Id = P1.AcceptedAnswerId -- а в P3 выбранынй ответ
        GROUP BY P1.Id, P2.CommentCount, P3.CommentCount
        HAVING MAX(P2.CommentCount) / 2 > P3.CommentCount) AS R -- проверяем условие

-- 12. Список всех вопросов с самым комментируемым ответом на данный вопрос.
SELECT P1.Id, (SELECT TOP 1 P3.Id -- оставляем 1 из возможных ответов(несколько ответов с наибольшим раным числом комментариев)
               FROM Posts AS P3
               WHERE P3.ParentId = P1.Id
                     AND P3.PostTypeId = 2
                     AND P3.CommentCount = (SELECT MAX(P2.CommentCount) -- ищем максимум комментариев к ответу
                                            FROM Posts AS P2
                                            WHERE P2.PostTypeId = 2
                                                  AND P2.ParentId = P1.Id))
  FROM Posts AS P1
  WHERE P1.PostTypeId = 1

-- 13. Найдите всех пользователей, которые либо непосредственно отвечали на вопросы
--    либо оставляли комментарии(как комментарии к самому вопросу, так и комментарии к некоторому из ответов на вопрос)
--    к вопросам, помеченных хотя бы 2 из 10 самых часто используемых в вопросах тэгов.
SELECT C.UserId -- все пользователи комментировавшие ответ или вопрос из условия
  FROM Comments AS C
    INNER JOIN (SELECT P2.Id AS qaId -- id всех вопросов и ответов удовлетворяющих условию
                FROM Posts AS P2
                  INNER JOIN (SELECT P1.Id AS id -- id вопросов помеченных хотя бы 2 из 10 самых часто используемых в вопросах тэгов
                          FROM Posts AS P1
                            INNER JOIN (SELECT TOP 10 TagName AS tag From Tags ORDER BY Count DESC) AS T -- топ 10 самых используемых тегов
                              ON P1.Tags LIKE ('%<' + T.tag + '>%')
                          GROUP BY P1.Id
                          HAVING COUNT(P1.Id) > 1) AS P
                    ON P.id = P2.ParentId OR P.id = P2.Id) AS P3
      ON C.PostId = P3.qaId
UNION -- ничего лучше не придумал
SELECT P4.OwnerUserId -- id всех пользователей ответивших на вопросы удовлетворяющие условию
  FROM Posts AS P4
    INNER JOIN (SELECT P6.Id AS id2 -- id вопросов помеченных хотя бы 2 из 10 самых часто используемых в вопросах тэгов
            FROM Posts AS P6
              INNER JOIN (SELECT TOP 10 TagName AS tag2 From Tags ORDER BY Count DESC) AS T2 -- топ 10 самых используемых тегов
                ON P6.Tags LIKE ('%<' + T2.tag2 + '>%')
            GROUP BY P6.Id
            HAVING COUNT(P6.Id) > 1) AS P5
      ON P5.id2 = P4.ParentId

-- Можно ли как-то вынести например поиск топ 10 тегов отдельно, что бы не писать каждый раз?