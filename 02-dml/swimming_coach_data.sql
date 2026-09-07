use swimming_coach;

-- insert one parent
INSERT INTO parents (first_name, last_name) VALUES ("Ah Kow", "Tan");

INSERT INTO students (first_name, last_name, swimming_level, dob, parent_id)
    values ("Ah Mew", "Tan", 1, "2020-06-08", 1);

INSERT INTO students (first_name, last_name, swimming_level, dob, parent_id)
    values ("Steven", "Tan", 1, "2021-06-08", 1);

-- UPDATE A ROW
UPDATE students SET swimming_level = 2 WHERE student_id = 1;

-- UPDATE MULTIPLE COLUMNS IN A ROW
UPDATE students SET swimming_level = 2, dob="2021-08-06" WHERE student_id = 3;

-- DELETE 
DELETE FROM students WHERE student_id = 3;