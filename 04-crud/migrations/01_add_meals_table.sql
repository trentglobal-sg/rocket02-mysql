use cico_tracker;

create table meals (
    id int unsigned primary key auto_increment,
    name varchar(255) not null
) engine = innodb;