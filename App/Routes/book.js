const express = require("express");

const Book = require("../models/book");
const Author = require("../models/author");

const imgMimeTypes = ["image/jpeg", "image/png", "image/gif"];

const router = express.Router();

router.get("/:id", async (req, res) => {
  const id = req.params.id;
  const newBook = await Book.find({ _id: id });
  const author = await Author.findOne({ _id: newBook[0].author });

  res.render("Books/book", { id: id, book: newBook[0], bookAuthor: author });
});

router.get("/:id/edit", async (req, res) => {
  const book = await Book.findById(req.params.id);
  const authors = await Author.find();
  res.render("Books/editbook", { book: book, authors: authors });
});

router.put("/:id", async (req, res) => {
  let book, oldbook, bookAuthor;
  const newBook = {
    title: req.body.title,
    publishDate: new Date(req.body.publishDate),
    pageCount: req.body.pageCount,
    author: req.body.author,
    description: req.body.description,
  };
  saveCover(newBook, req.body.cover);
  try {
    oldbook = await Book.findById(req.params.id);
    oldbookAuthor = await Author.findById(oldbook.author);
  } catch (error) {
    res.render("Books/book", {
      id: req.params.id,
      book: book,
      bookAuthor: bookAuthor,
      errorMessage: "Could not find book",
    });
  }
  try {
    book = {
      ...oldbook._doc,
      ...newBook,
    };
    await Book.updateOne({ _id: req.params.id }, book);
    book = await Book.findById(req.params.id);
    bookAuthor = await Author.findById(book.author);
    res.render("Books/book", {
      id: book._id,
      book: book,
      bookAuthor: bookAuthor,
    });
  } catch (error) {
    console.error(error);
    res.render("Books/book", {
      id: req.params.id,
      book: oldbook,
      bookAuthor: oldbookAuthor,
      errorMessage: "Could not update book",
    });
  }
});

router.delete("/:id", async (req, res) => {
  let book;
  try {
    book = await Book.findById(req.params.id);
    await book.remove();
    res.redirect(`/books`);
  } catch (error) {
    if (book !== null) console.error(error);
    res.render("Books/book", {
      errorMessage: `Could not remove book. \n${error}`,
    });
  }
});

function saveCover(book, coverEncoded) {
  if (!coverEncoded) return;
  const cover = JSON.parse(coverEncoded);
  if (cover !== null && imgMimeTypes.includes(cover.type)) {
    book.cover = new Buffer.from(cover.data, "base64");
    book.coverType = cover.type;
  }
}

module.exports = router;
