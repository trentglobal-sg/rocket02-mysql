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

// create a connection to the database
const dbConfig = {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT
}

console.log(dbConfig);

const dbConnection = mysql2.createPool(dbConfig);

// a dynamic web app, like the one here
// is one where the HTML is dynamically generated
// by the server each time the client visit the server
app.get('/', function(req,res){
    res.render('index', {
        name: "Tan Ah Kow"
    });
})

app.get('/food_entries', async function(req,res){
    const [rows] = await dbConnection.execute("SELECT * FROM food_entries");
   res.send(rows);
})

app.listen(port, function(){
    console.log("Server has started")
})