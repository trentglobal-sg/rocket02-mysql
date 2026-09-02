-- how to create a new database in MariaDB / MySQL
create database swimming_coach;

-- switch to the created database
use swimming_coach;

-- definition for <column_name> <options>
create table parents (
    parent_id int unsigned auto_increment primary key,
    first_name varchar(45) not null,
    last_name varchar(45) default ''
) engine = innodb; 

-- show all tables
show tables;

-- insert one parent
INSERT INTO parents (first_name, last_name) VALUES ("Ah Kow", "Tan");

-- show all parents
SELECT * FROM parents;

-- create the table without foreign key
create table students (
    student_id int unsigned auto_increment primary key,
    first_name varchar(45) not null,
    last_name varchar(45),
    swimming_level tinyint,
    dob date
) engine = innodb;


-- add a new columnm
alter table students add column parent_id int unsigned not null;

-- add the foreign key
alter table students
    add constraint fk_parents_students
    foreign key (parent_id) references parents(parent_id)
    on delete cascade
    on update restrict;

INSERT INTO students (first_name, last_name, swimming_level, dob, parent_id)
    values ("Ah Mew", "Tan", 1, "2020-06-08", 1);

INSERT INTO students (first_name, last_name, swimming_level, dob, parent_id)
values ("Jon", "Snow", 1, "2020-06-08", 199);

alter table students add column gender varchar(2) not null;

alter table students rename column dob to date_of_birth; 

alter table students modify column swimming_level tinyint unsigned not null default 0;

alter table students drop column gender;

drop table students;
