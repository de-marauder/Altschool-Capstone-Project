const express = require('express')

const Author = require('../models/author')
const Book = require('../models/book')

const router = express.Router()

router.get('/', async (req, res)=>{
    console.log("root route hit")
  try {
    const authors = await Author.find({}).catch((e)=>console.log(e));
    let books = await Book.find().sort({createdAt: 'desc'}).limit(10).catch((e)=>console.log(e));
    
    const bookAuthors = await Promise.all(books.map(async (book, i)=>{
      const author = await Author.findOne({_id: book.author}).catch((e)=>console.log(e))
      
      return {
        name: author.name
      }
    })).catch((e)=>console.log(e))

    res.render("index", {authors: authors, bookAuthors: bookAuthors, books: books});
  } catch (error) {
    console.error(error)
    res.redirect('books')
  }

})

module.exports = router