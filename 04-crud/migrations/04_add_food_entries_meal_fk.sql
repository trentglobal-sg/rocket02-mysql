use cico_tracker;

-- update all existing food entries to use N/A
UPDATE food_entries SET meal_id = 1;

ALTER TABLE food_entries MODIFY COLUMN meal_id  INT UNSIGNED NOT NULL;

ALTER TABLE food_entries ADD CONSTRAINT fk_food_entries_meals
    FOREIGN KEY (meal_id) REFERENCES meals(id);