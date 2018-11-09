-- reference https://www.imdb.com/interfaces/
create table title.basics_s (
  tconst         text,
  titleType      text,
  primaryTitle   text,
  originalTitle  text,
  isAdult        boolean,
  startYear      text,
  endYear        text,
  runtimeMinutes int,
  genres         text
);
create table title.basics (
  tconst         text,
  titleType      text,
  primaryTitle   text,
  originalTitle  text,
  isAdult        boolean,
  startYear      text,
  endYear        text,
  runtimeMinutes int,
  genres         text []
);
insert into title.basics (tconst,
                          titleType,
                          primaryTitle,
                          originalTitle,
                          isAdult,
                          startYear,
                          endYear,
                          runtimeMinutes,
                          genres)
select tconst,
       titleType,
       primaryTitle,
       originalTitle,
       isAdult,
       startYear,
       endYear,
       runtimeMinutes,
       string_to_array(genres, ',')
from title.basics_s;
drop table title.basics_s;
