
create or replace function get_prolific(arg_categories text [], arg_genres text [], arg_min_rating numeric(3,1)=3.5)
  returns table(name text, count bigint) as $$
begin
  return query select actor.primaryname, count(1) c
               from name.basics actor
                    join title.principals actor_film
                        on actor.nconst = actor_film.nconst
                    join title.basics film
                        on film.tconst = actor_film.tconst
                    join title.ratings rating
                        on film.tconst = rating.tconst
               where actor_film.category = any(arg_categories)
                 and rating.averagerating >= arg_min_rating
                 and array_length(array_intersect(arg_genres, genres), 1) > 0
               group by actor.primaryname
               order by c desc
               limit 50;
end;
$$
language plpgsql;

select *
from get_prolific('{actor}' :: text [], '{Fantasy}' :: text []);
CREATE FUNCTION array_intersect(anyarray, anyarray)
  RETURNS anyarray
language sql
as $FUNCTION$
SELECT ARRAY(
         SELECT UNNEST($1)
             INTERSECT
             SELECT UNNEST($2)
           );
$FUNCTION$;


SELECT proname
FROM pg_catalog.pg_namespace n
     JOIN pg_catalog.pg_proc p
         ON pronamespace = n.oid
WHERE nspname = 'public';