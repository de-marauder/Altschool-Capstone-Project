const express = require("express");

const router = express.Router();

const Author = require("../models/author");

// Author routes
router.get("/", async (req, res) => {
  console.log("get author route hit");
  const name = req.query.name
  let query = {}
  if (name) query.name = new RegExp(name, 'i')
  try {
    const authors = await Author.find(query);
    res.render("Authors", { authors: authors, search: name });
  } catch (error) {
      console.log(error)
      res.redirect('/')
  }
});

router.get("/new", (req, res) => {
  console.log("new author route hit");
  res.render("Authors/new", { author: new Author() });
});

router.post("/", async (req, res) => {
  console.log("post author route hit");

  const author = new Author({
    name: req.body.name,
  });

  try {
    const newAuthor = await author.save();
    res.redirect(`Authors`);
  } catch (error) {
    console.log("there was an error");
    res.render("Authors/new", {
      author: author,
      errorMessage: `Error creating Author`,
    });
  }
});

module.exports = router;
