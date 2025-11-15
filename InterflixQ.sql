/* Write your data-normalization SQL statements here */
/* Make sure you code your primary keys and foreign keys in SQL (not set up via the GUI) */

/* 2NF */
drop table if exists SHOW_2NF;
create table SHOW_2NF (
  show_id INTEGER,
  title VARCHAR(113),
  type_id INTEGER,
  number_of_featured_countries INTEGER,
  release_year INTEGER,
  rating VARCHAR(9),
  rating_desc VARCHAR(45),
  movie_minutes_or_tv_seasons INTEGER,
  primary key (show_id)
);

insert into SHOW_2NF 
    select distinct show_id,
                    title,
                    type_id,
                    number_of_featured_countries,
                    release_year,
                    rating,
                    rating_desc,
                    movie_minutes_or_tv_seasons
    from INTERFLIX_1NF;
                    
drop table if exists INTERFLIX_2NF;
create table INTERFLIX_2NF (
  show_id INTEGER,
  provider_id INTEGER,
  genre_id INTEGER,
  date_added DATE,
  primary key (show_id, provider_id, genre_id)
  foreign key (show_id) references SHOW_2NF(show_id)
);

insert into INTERFLIX_2NF 
    select show_id,
           provider_id,
           genre_id,
           date_added
    from INTERFLIX_1NF;
    
/* 3NF */

drop table if exists INTERFLIX_3NF;
create table INTERFLIX_3NF (
  show_id INTEGER,
  provider_id INTEGER,
  genre_id INTEGER,
  date_added DATE,
  primary key (show_id, provider_id, genre_id)
  foreign key (show_id) references SHOW_3NF(show_id)
  foreign key (provider_id) references PROVIDER_3NF(provider_id)
  foreign key (genre_id) references GENRE_3NF(genre_id)
);

insert into INTERFLIX_3NF 
    select show_id,
           provider_id,
           genre_id,
           date_added
    from INTERFLIX_2NF;
    
drop table if exists SHOW_3NF;
create table SHOW_3NF (
  show_id INTEGER,
  title VARCHAR(113),
  type_id INTEGER,
  number_of_featured_countries INTEGER,
  release_year INTEGER,
  rating VARCHAR(9),
  movie_minutes_or_tv_seasons INTEGER,
  primary key (show_id)
  foreign key (rating) references RATING_3NF(rating)
  foreign key (type_id) references TYPE_3NF(type_id)
);

insert into SHOW_3NF 
    select distinct show_id,
                    title,
                    type_id,
                    number_of_featured_countries,
                    release_year,
                    rating,
                    movie_minutes_or_tv_seasons
    from SHOW_2NF;
    
drop table if exists RATING_3NF;
create table RATING_3NF (
  rating VARCHAR(9),
  rating_desc VARCHAR(45),
  primary key (rating)
);

insert into RATING_3NF
    select distinct rating,
                    rating_desc
    from SHOW_2NF;
    
/* DAHFLIX */

drop table if exists DASHFLIX;
create table DASHFLIX (
  provider VARCHAR(12),
  title VARCHAR(113),
  type VARCHAR(7),
  release_year INTEGER,
  rating VARCHAR(45),
  genre VARCHAR(26)
);

insert into DASHFLIX
    select PROVIDER_3NF.provider_name as provider,
           SHOW_3NF.title as title,
           TYPE_3NF.type_name as type,
           SHOW_3NF.release_year as release_year,
           RATING_3NF.rating_desc as rating,
           GENRE_3NF.genre_label
       from INTERFLIX_3NF, GENRE_3NF, SHOW_3NF, PROVIDER_3NF, RATING_3NF, TYPE_3NF
           where INTERFLIX_3NF.show_id = SHOW_3NF.show_id and
                 INTERFLIX_3NF.genre_id = GENRE_3NF.genre_id and
                 INTERFLIX_3NF.provider_id = PROVIDER_3NF.provider_id and
                 SHOW_3NF.type_id = TYPE_3NF.type_id and
                 SHOW_3NF.rating = RATING_3NF.rating
     order by title;