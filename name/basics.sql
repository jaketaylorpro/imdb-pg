-- reference https://www.imdb.com/interfaces/
create table name.basics_s (
  nconst            text,
  primaryName       text,
  birthYear         text,
  deathYear         text,
  primaryProfession text,
  knownForTitles    text
);
create table name.basics (
  nconst            text,
  primaryName       text,
  birthYear         text,
  deathYear         text,
  primaryProfession text [],
  knownForTitles    text []
);
insert into name.basics (nconst, primaryName, birthYear, deathYear, primaryProfession, knownForTitles)
select nconst,
       primaryname,
       birthyear,
       deathyear,
       string_to_array(primaryprofession, ','),
       string_to_array(knownForTitles, ',')
from name.basics_s;
drop table name.basics_s;
