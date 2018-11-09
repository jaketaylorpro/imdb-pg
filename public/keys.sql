--episode
create index ix_episode_parent_tconst
  on title.episode (parentTconst, tconst);
create index ix_episode_tconst
  on title.episode (tconst);
cluster title.episode using ix_episode_parent_tconst;
-- first remove episodes that don't have corresponding values in basic
delete
from title.episode e
    using title.episode e1
    left join title.basics b1
    on b1.tconst = e1.tconst
where b1.tconst is null
  and e.tconst = e1.tconst;
alter table title.episode
  add constraint fk_tconst foreign key (tconst) references title.basics (tconst);
--akas
create index ix_akas_titleId_ordering
  on title.akas (titleid, ordering);
cluster title.akas using ix_akas_titleId_ordering;
-- first remove akas that don't have corresponding values in basic
delete
from title.akas a
    using title.akas a1
    left join title.basics b1
    on b1.tconst = a1.titleid
where b1.tconst is null
  and a.titleid = a1.titleid;
alter table title.akas
  add constraint fk_tconst foreign key (titleid) references title.basics (tconst);
--principals
create index ix_principals_tconst_ordering
  on title.principals (tconst, ordering);
cluster title.principals using ix_principals_tconst_ordering;
delete
from title.principals p
    using title.principals p1
    left join title.basics b1
    on b1.tconst = p1.tconst
where b1.tconst is null
  and p.tconst = p1.tconst;
alter table title.principals
  add constraint fk_tconst foreign key (tconst) references title.basics (tconst);
delete
from title.principals p
    using title.principals p1
    left join name.basics b1
    on b1.nconst = p1.nconst
where b1.nconst is null
  and p.nconst = p1.nconst;
alter table title.principals
  add constraint fk_nconst foreign key (nconst) references name.basics (nconst);
--ratings
create index ix_ratings_tconst
  on title.ratings (tconst);
cluster title.ratings using ix_ratings_tconst;
delete
from title.ratings r
    using title.ratings r1
    left join title.basics b1
    on b1.tconst = r1.tconst
where b1.tconst is null
  and r.tconst = r1.tconst;
alter table title.ratings
  add constraint fk_tconst foreign key (tconst) references title.basics (tconst);
--title.basics
create unique index ix_basics_tconst
  on title.basics (tconst);
cluster title.basics using ix_basics_tconst;
--name.basics
create unique index ix_basics_nconst
  on name.basics (nconst);
cluster name.basics using ix_basics_nconst;
--title.crew
create unique index ix_crew_tconst
  on title.crew (tconst);
cluster title.crew using ix_crew_tconst;
--create trigger compatible procedure to check that nconsts exist for crew.directors
create or replace function director_nconst_exists()
  returns trigger as
$$
begin
  if array_length(new.directors,1) =
     (select count(1) from name.basics where nconst = ANY(new.directors))
  then
    return new;
  else raise exception 'non existent director nconst: %',new.directors;
  end if;
end;
$$
LANGUAGE plpgsql;
--done
--create trigger compatible procedure to check that nconsts don't exist in crew.directors when name.basic gets updated or deleted
create or replace function director_nconst_doesnt_exists()
  returns trigger as
$$
begin
  if tg_op = 'DELETE'
  then
    if (select count(1) from title.crew where old.nconst = any(directors)) = 0
    then return old; -- tell the trigger to continue
    else raise exception 'rows in title.crew depend on: %',old.nconst; -- tell the trigger to stop
    end if;
  else
    if new.nconst <> old.nconst and (select count(1) from title.crew where old.nconst = any(directors)) = 0
    then
      return new; -- tell the trigger to continue
    else raise exception 'rows in title.crew depend on: %',old.nconst; -- tell the trigger to stop
    end if;
  end if;
end;
$$
LANGUAGE plpgsql;
--done
--create insert trigger
create trigger afk_directors
  before insert or update
  on title.crew
  for each row
  when (array_length(new.directors, 1) is not null)
execute procedure director_nconst_exists();
--create delete trigger
drop trigger if exists afk_directors on name.basics;
create trigger afk_directors
  before delete or update
  on name.basics
  for each row
execute procedure director_nconst_doesnt_exists();
--now to test triggers
select * from name.basics order by nconst desc limit 1;
select * from title.basics order by tconst desc limit 1;
begin transaction;
insert into name.basics(nconst, primaryname, birthyear, deathyear, primaryprofession, knownfortitles) VALUES
   ('nm9993720','test',null,null,'{}'::text[],null);
insert into title.basics(tconst, titletype, primarytitle, originaltitle, isadult, startyear, endyear, runtimeminutes, genres) VALUES
   ('tt9193141','tvEpisode','test','test',false ,null,null,1,'{test}');
insert into title.crew(tconst, directors, writers) values ('tt9193141','{nm9993720}',null);
-- delete from title.crew where tconst= 'tt9193141';
update name.basics set nconst = 'nm9993721' where nconst = 'nm9993720';
-- delete from name.basics where nconst = 'nm9993720';
select * from title.crew where 'nm9993720' = any(directors);
rollback;