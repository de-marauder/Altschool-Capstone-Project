const express = require("express");

const router = express.Router();

const imgMimeTypes = ["image/jpeg", "image/png", "image/gif"];


const Author = require("../models/author");
const Book = require("../models/book");

// Books routes
router.get("/", async (req, res) => {
  console.log("get book route hit");
  let query = {}
  let options = {...req.query}
  if (options !== null) {
    if (options.publishedAfter) {
      query.publishDate = {'$gte': new Date(options.publishedAfter)}
    }
    if (options.publishedBefore) {
      query.publishDate = {'$lte': new Date(options.publishedBefore)}
    }
    if (options.title) {
      query.title = new RegExp(options.title, 'i')
    }
    if (options.author) {
      query.author = options.author
    }

  }
  try {
    const authors = await Author.find({});
    let books = await Book.find(query).sort({'createdAt': -1});
    const bookAuthors = await Promise.all(books.map(async (book, i)=>{
      const author = await Author.findOne({_id: book.author})
      
      return {
        name: author?.name
      }
    }))

    res.render("Books", {authors: authors, books: books, bookAuthors: bookAuthors, searchOptions: options });
  } catch (error) {
    console.error(error)
    redirect('books')
  }
});

router.get("/new", async (req, res) => {
  console.log("new book route hit");
  
  renderNewPage(res, new Book());
});

router.post("/new", async (req, res) => {
  console.log("post book route hit");

  console.log("req body: ", req.body);
  const book = new Book({
    title: req.body.title,
    description: req.body.description,
    pageCount: req.body.pageCount,
    publishDate: new Date(req.body.publishDate),
    author: req.body.author,
  });

  saveCover(book, req.body.cover)
  try {
    const newBook = await book.save();
    res.redirect(`book/${newBook._id}`);
  } catch (error) {
    console.log(`new post ERROR: ${error}`);
   
    renderNewPage(res, book, true);
  }
});



function saveCover(book, coverEncoded) {
  if (!coverEncoded) return
  const cover = JSON.parse(coverEncoded)
  if (cover !== null && imgMimeTypes.includes(cover.type)) {
    book.cover = new Buffer.from(cover.data, "base64")
    book.coverType = cover.type
  }
}

async function renderNewPage(res, book, hasError = false) {
  try {
    const authors = await Author.find({});
    const params = {
      book: book,
      authors: authors,
    };
    if (hasError) {
      params.errorMessage = "Error creating new book";
    }
    res.render("Books/new", params);
  } catch (error) {
    console.log(`new book error ${error}`);
    res.redirect("/");
  }
}

module.exports = router;
