--todo move to new file
create database imdb;
create schema title;
create schema name;
--toto start file here
-- reference https://www.imdb.com/interfaces/
create table title.akas_s (
  titleId         text,
  ordering        int  null,
  title           text null,
  region          text null,
  language        text null,
  types           text null,
  attributes      text null,
  isOriginalTitle bit  null
);
-- import data
drop table title.akas;
create table title.akas (
  titleId         text,
  ordering        int,
  title           text,
  region          text,
  language        text,
  types           text [],
  attributes      text [],
  isOriginalTitle boolean
);
insert into title.akas (titleId, ordering, title, region, language, types, attributes, isOriginalTitle)
select titleId,
       ordering,
       title,
       region,
       language,
       string_to_array(types, ' '),      --TODO transform to array
       string_to_array(attributes, ','), -- TODO transform to array
       isOriginalTitle = 1 :: bit
from title.akas_s;
drop table title.akas_s;