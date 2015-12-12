-- Тенищев Семен А3400

LOAD DATA INFILE '/tmp/Blog.txt'
INTO TABLE Blog
COLUMNS TERMINATED BY ','; -- 0:05.58

LOAD DATA INFILE '/tmp/BlogPost.txt'
INTO TABLE BlogPost
COLUMNS TERMINATED BY ','; -- 3:58

LOAD DATA INFILE '/tmp/BlogReader.txt'
INTO TABLE BlogReader
COLUMNS TERMINATED BY ','; -- 3:01

LOAD DATA INFILE '/tmp/Login.txt'
INTO TABLE Login
COLUMNS TERMINATED BY ','; -- 0:06.3

LOAD DATA INFILE '/tmp/PersonalData.txt'
INTO TABLE PersonalData
COLUMNS TERMINATED BY ','; -- 0:07.3

-- индексы именованы самым явным образом, так что думаю понятно к чему что относится

-- 1.
drop index forEleventhQueryBlogReader on BlogReader;

-- login и pass четко заданны и это строки, что может быть лучше чем хэш по строкам?
create index forFirstQuery
using hash on Login(login, passMd5);

-- 2.
drop index forFirstQuery on Login;
-- создаю два "основных" индекса в таблицах для ускорения проверки на =
create index forSecondQueryLogin
on Login(personalDataId);
create index forSecondQueryPersonalData
on PersonalData(id);
-- если теперь посмотреть в explain можно видеть что количество строк для второй таблицы сократилось примерно  в 200 раз
create index forSecondQueryPersonalDataBetween
on PersonalData(birthDate);
-- теперь о том что у нас в Where - year(birthDate) = 1973 and month(birthDate) = 11, это конечно красиво, но индекс так не поиспользовать
explain select *
  from PersonalData
    join Login on Login.personalDataId = PersonalData.id
  where
    birthDate >= '1973-11-00' AND birthDate <= '1973-11-31';
-- а так намного лучше, к сожалению в mysql так и не исправили LIKE по date в индексе(имеются баг репорты еще с 5.5)
-- можно через between но там нужен явный cast

-- 3.
drop index forSecondQueryLogin on Login;
drop index forSecondQueryPersonalData on PersonalData;
drop index forSecondQueryPersonalDataBetween on PersonalData;

create index forThirdQueryLogin
on Login(personalDataId);
create index forThirdQueryPersonalData
on PersonalData(id);
-- lastName и firstName, не проблема
create index forThirdQueryPersonalDataName
using hash on PersonalData(lastName, firstName);
-- но explain говорит, что как-то не сильно помогло, ну оно и не удивительно, нам там пробел дорисовывают
explain select *
  from PersonalData
    join Login on Login.personalDataId = PersonalData.id
  where lastName = 'Javier' AND firstName = 'Sandy';
-- ну вот теперь хорошо, кстати, вот понял, что если бы условие звучало как "вы не можете менять входные данные" было бы веселее
-- т.е. например тут надо было считать, что обязательно надо обыгрывать строку 'Javier Sandy'

-- 4.
drop index forThirdQueryLogin on Login;
drop index forThirdQueryPersonalData on PersonalData;
drop index forThirdQueryPersonalDataName on PersonalData;

create index forFourthQueryLogin
on Login(id);
create index forFourthQueryPersonalData
on PersonalData(id);

-- 5.
drop index forFourthQueryLogin on Login;
drop index forFourthQueryPersonalData on PersonalData;

create index forFifthQueryBlog
on Blog(ownerId);

-- 6.
drop index forFifthQueryBlog on Blog;

create index forSixthQueryBlog
on Blog(creationDate);
create index forSixthQueryLogin
on Login(id);
create index forSixthQueryPersonalData
on PersonalData(id);
-- Забавный по своей сути набор индексов, особенно если читать документацию mysql,
-- где они советуют включать в индекс сортировки столбцы из where

-- 7.
drop index forSixthQueryBlog on Blog;
drop index forSixthQueryLogin on Login;
drop index forSixthQueryPersonalData on PersonalData;

create index forSeventhQueryBlog
on Blog(name);

-- 8.
drop index forSeventhQueryBlog on Blog;

create index forEighthQueryBlogPost
on BlogPost(posterId, creationDate);

--9.
drop index forEighthQueryBlogPost on BlogPost;

create index forNinthQueryBlogPost
on BlogPost(blogId, creationDate);

-- 10.
drop index forNinthQueryBlogPost on BlogPost;

create index forTenthQueryBlogReader
on BlogReader(blogId);

-- 11.
drop index forTenthQueryBlogReader on BlogReader;

create index forEleventhQueryBlogReader
on BlogReader(readerId);

-- Что-то не пойму смысла в последних 3 запросах