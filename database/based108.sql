--
-- created on 09-05-2012 by Mill
--
drop database if exists based108;
create database based108 with encoding 'UTF-8';

\c based108;


CREATE TABLE ville( 
       nom_ville VARCHAR(45) not null,
       mel_contact VARCHAR(100) not null default '',
       PRIMARY KEY( nom_ville )
);

CREATE TABLE festival( 
       ville_festival VARCHAR(45) not null,
       date TIMESTAMP not null default TIMESTAMP '1901-01-01 00:00:00.000000',
       lieu VARCHAR(100) not null default '',
       prix_place INTEGER not null,
       PRIMARY KEY( ville_festival ),
       CONSTRAINT festival_FK_0 FOREIGN KEY( ville_festival) references ville( nom_ville ) on delete CASCADE
);

CREATE TABLE jour_festival( 
       id_jour_festival INTEGER not null,
       festival VARCHAR(45) not null,
       num_ordre INTEGER not null,
       nbre_concert_max INTEGER not null,
       heure_debut INTEGER not null,
       PRIMARY KEY( id_jour_festival ),
       CONSTRAINT jour_festival_FK_0 FOREIGN KEY( festival) references festival( ville_festival ) on delete CASCADE
);

CREATE TABLE groupe( 
       nom_groupe VARCHAR(100) not null,
       nom_contact VARCHAR(50) not null default '',
       coord_contact VARCHAR(100) not null default '',
       adr_site VARCHAR(100) default '',
       genre INTEGER not null,
       PRIMARY KEY( nom_groupe )
);

CREATE TABLE participant_festival( 
       nom_groupe_inscrit VARCHAR(100) not null,
       festival VARCHAR(45) not null,
       gagnant INTEGER default 0,
       PRIMARY KEY( nom_groupe_inscrit, festival ),
       CONSTRAINT participant_festival_FK_0 FOREIGN KEY( festival) references festival( ville_festival ) on delete CASCADE,
       CONSTRAINT participant_festival_FK_1 FOREIGN KEY( nom_groupe_inscrit) references groupe( nom_groupe ) on delete cascade
);

CREATE TABLE programme_jour_festival( 
       nom_groupe_programme VARCHAR(100) not null,
       jour_fest INTEGER not null,
       passage INTEGER not null,
       PRIMARY KEY( nom_groupe_programme, jour_fest ),
       CONSTRAINT programme_jour_festival_FK_0 FOREIGN KEY( jour_fest) references jour_festival( id_jour_festival ) on delete CASCADE,
       CONSTRAINT programme_jour_festival_FK_1 FOREIGN KEY( nom_groupe_programme) references groupe( nom_groupe ) on delete cascade
);

