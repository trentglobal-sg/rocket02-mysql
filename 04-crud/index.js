const express = require('express');
const mysql2 = require('mysql2/promise');
const ejs = require('ejs');

const app = express();
const port = 3000;

require('dotenv').config();

// tell express we are using ejs as the view engine
// view engine is the same template engine

app.set('view engine', 'ejs');
app.set('views', './views');

// set up express to use web forms (or forms that submitted directly to the server)
app.use(express.urlencoded({
    extended: true
}))

// create a connection to the database
const dbConfig = {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT
}

const dbConnection = mysql2.createPool(dbConfig);

// a dynamic web app, like the one here
// is one where the HTML is dynamically generated
// by the server each time the client visit the server
app.get('/', function (req, res) {
    res.render('index', {
        name: "Tan Ah Kow"
    });
})


app.get('/search/food_entries', async function (req, res) {

    const { foodName, meal, minCalories, maxCalories } = req.query;

    // implement a query builder pattern
    let query = "SELECT * FROM food_entries WHERE 1";
    const bindings = [];

    if (foodName) {
        query += " AND foodName LIKE ?";
        bindings.push("%" + foodName + "%")
    }

    if (meal) {
        query += " AND meal LIKE ?";
        bindings.push("%" + meal + "%");
    }

    if (minCalories) {
        query += " AND calories >= ?";
        bindings.push(minCalories);
    }

    if (maxCalories) {
        query += " AND calories <= ?";
        bindings.push(maxCalories);
    }

    console.log(query);
    const [rows] = await dbConnection.execute(query, bindings);

    res.render('search', {
        results: rows,
        values: req.query
    });
})


app.get('/food_entries', async function (req, res) {
    // array destructuring
    // see: https://onecompiler.com/javascript/452z3c982
    // dbConnection.execute returns more than one element in an array as the return
    // element 0 is the result from the database
    // element 1 are meta-data
    const [rows] = await dbConnection.execute(
        `SELECT food_entries.*, meals.name AS "meal_name", group_concat(tags.name)  AS tags FROM food_entries
            JOIN meals
                ON food_entries.meal_id = meals.id
            LEFT JOIN food_entries_tags
                ON food_entries_tags.food_entry_id = food_entries.id
            LEFT JOIN tags
                ON food_entries_tags.tag_id = tags.id
            GROUP BY food_entries.id
        `
    );


        console.log(rows);
    // we could do:
    // const results = await dbConnection.execute("SELECT * FROM food_entries");
    // const rows = results[0];
    res.render("food_entries", {
        results: rows
    });
})

// render (i.e show a form) to the user
app.get('/create_food_entry', async function (req, res) {
    const [rows] = await dbConnection.execute("SELECT * FROM meals");
    const meals = rows.slice(1);  // return a new array from index 1 onwards to the end

    const [tagRows] = await dbConnection.execute("SELECT * FROM tags");

    res.render('create_food_entry', {
        meals: meals,
        tags: tagRows
    });
})

app.post('/create_food_entry', async function (req, res) {

    const connection = await dbConnection.getConnection();
    console.log(req.body);

    try {
        // a transaction is like a checkpoint; no changes made to the database persists
        // until we commit
        await connection.beginTransaction();
        const sql = `insert into food_entries (dateTime, foodName, calories, meal_id, servingSize, unit)
            VALUES ( NOW(), ?, ?, ?, ?, ?);`
        const [results] = await connection.execute(sql, [
            req.body.foodName,
            req.body.calories,
            req.body.meal_id,
            req.body.servingSize,
            req.body.unit

        ]);

        //get the id of the newly created food entry
        const newFoodEntryId = results.insertId;

        for (let tagId of req.body.tags) {
            await connection.execute(
                `INSERT INTO food_entries_tags (food_entry_id, tag_id) VALUES (?, ?)`, [newFoodEntryId, tagId]);
        }


        // make all changes permanent
        await connection.commit();
        res.redirect('/food_entries')
    } catch (e) {
        // discard changes made to the database
        await connection.rollback();
        console.error(e);
        res.send(e);
    } finally {
        await connection.release();
    }

    console.log(req.body)

});

app.get('/confirm_delete_food_entry/:id', async function (req, res) {
    const foodEntryId = req.params.id;
    // use prepared query (i.e paramterized query)
    const [rows] = await dbConnection.execute(
        "SELECT foodName, calories, dateTime FROM food_entries WHERE id = ?", [foodEntryId]
    );
    // dbConnection.execute with SELECT will always return an array, so if we want the first found result
    // we must reference index 0
    const foodEntry = rows[0];
    res.render('confirm_delete_food_entry', {
        foodEntry
    })
})

app.post('/confirm_delete_food_entry/:id', async function (req, res) {
    const foodEntryId = req.params.id;
    const sql = "DELETE FROM food_entries WHERE id = ?";
    await dbConnection.execute(sql, [foodEntryId]);
    res.redirect('/food_entries');
})

app.get('/edit_food_entry/:id', async function (req, res) {
    const foodEntryId = req.params.id;

    // get all the meal types
    const [mealRows] = await dbConnection.execute(`SELECT * FROM meals`);
    const meals = mealRows.slice(1);

    const sql = "SELECT * FROM food_entries WHERE id = ?";
    const [rows] = await dbConnection.execute(sql, [foodEntryId]);
    const foodEntry = rows[0];
    res.render('edit_food_entry', {
        foodEntry,
        meals
    })
})

app.post('/edit_food_entry/:id', async function (req, res) {

    const { foodName, calories, meal_id, tags, servingSize, unit } = req.body;
    console.log(req.body);
    const foodEntryId = req.params.id;
    const sql = `UPDATE food_entries SET 
                    foodName = ?,
                    calories = ?,
                    meal_id = ?,
                    tags = ?,
                    servingSize = ?,
                    unit = ?
                WHERE id = ?
    `
    await dbConnection.execute(sql, [
        foodName,
        calories,
        meal_id,
        JSON.stringify(tags),
        servingSize,
        unit,
        foodEntryId
    ]);

    res.redirect('/food_entries');
})

app.listen(port, function () {
    console.log("Server has started")
})