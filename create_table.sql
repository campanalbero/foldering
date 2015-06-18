create table photo (
  path varchar(255) unique,
  md5 varchar(32) unique,
  date_time datetime,
  model varchar(255)
);
