-- reference https://www.imdb.com/interfaces/
create table title.crew_s (
  tconst    text,
  directors text,
  writers   text
);
create table title.crew (
  tconst    text,
  directors text [],
  writers   text []
);
create index ix_crew_tconst
  on title.crew (tconst);
cluster title.crew using ix_crew_tconst;
insert into title.crew (tconst, directors, writers)
select tconst, string_to_array(directors, ','), string_to_array(writers, ',')
from title.crew_s;
drop table title.crew_s;
