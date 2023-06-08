if (process.env.NODE_ENV !== 'production') {
    require('dotenv').config()
}

// random comment

const express = require('express');
const bodyParser = require('body-parser')
const methodOverride = require('method-override');

const expressLayouts = require('express-ejs-layouts')
const indexRoute = require('./Routes')
const authorsRoute = require('./Routes/authors.js')
const authorRoute = require('./Routes/author.js')
const booksRoute = require('./Routes/books.js')
const bookRoute = require('./Routes/book.js')


const app = express()

const mongoose = require('mongoose');
console.log('start connecting to database...')
mongoose.connect(process.env.DATABASE_URL).catch((err) => console.log(err))
console.log('connected to database...')

const db = mongoose.connection
db.on('error', error => console.error(error))
db.once('open', () => console.log('Connected to Mongoose'))

app.set('view engine', 'ejs')
app.set('views', __dirname + '/views')
app.set('layout', 'layouts/layout')

app.use(bodyParser.urlencoded({ extended: false, limit: '10mb' }))
app.use(expressLayouts)
app.use(express.static('public'))
app.use(methodOverride('_method'))

const port = process.env.PORT || 5000

app.use((req, res, next) => {
    console.log(mongoose.connection.readyState)
    if (mongoose.connection.readyState !== 1) return res.send('db not connected')
    next()
})

app.use('/', indexRoute)
app.use('/authors', authorsRoute)
app.use('/authors/author', authorRoute)
app.use('/books', booksRoute)
app.use('/books/book', bookRoute)

app.get('/*', (req, res) => {
    res.send("Not Found")
})

app.listen(port, () => {
    console.log(`listening on port ${port}`)
})

// something new