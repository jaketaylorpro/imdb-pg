# imdb-pg

set to scripts to load the IMDB exported files into a postgres database.
This is mostly an excersize to learn postgres and remove rust from my sql skills.

## to reproduce
1. download source files from imdb
  * https://datasets.imdbws.com/name.basics.tsv.gz
  * https://datasets.imdbws.com/title.akas.tsv.gz
  * https://datasets.imdbws.com/title.basics.tsv.gz
  * https://datasets.imdbws.com/title.crew.tsv.gz
  * https://datasets.imdbws.com/title.episode.tsv.gz
  * https://datasets.imdbws.com/title.principals.tsv.gz
  * https://datasets.imdbws.com/title.ratings.tsv.gz
1. run the create-database.sql script and the two create-schema.sql scripts
1. each tsv file has a corresponding sql file <schema>/table>
  * if there is a scratch table (ie ends with _s):
    * run that both create table scripts to create the real table and the scratch table
    * use a tool<sup>1</sup> to import the data from the tsv into the scratch table
    * run the insert script and drop table script to remove the scratch table, after the data is transformed into the real table
  * otherwise:
    * run the create table script for the main table
    * use a tool<sup>1</sup> to import the data from the tsv to the main table directly (no transformation will be needed)
1. run the keys.sql script to add a number of constraints
  * more info here about the constraints
    
 
 <sup>1</sup> i used datagraip, and it worked pretty well
  

## todo
* [ ] need to find a tool that handles escaped double quotes in the TSV files properly.
  * currently we just ignore a few thousand records per table, and it isn't soo bad
  
## references 
https://www.postgresql.org/docs/10/index.html
https://www.imdb.com/interfaces/
