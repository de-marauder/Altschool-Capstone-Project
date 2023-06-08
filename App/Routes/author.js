const express = require('express')
const { render } = require('express/lib/response')

const Author = require('../models/author')
const book = require('../models/book')

const router = express.Router()

router.get('/:id', async (req,res)=> {
    let books
    try {
        books = await book.find({author: req.params.id}).limit(6)
    } catch (error) {
        render('/Authors/author', {errorMessage: "Could not find books by this author."})
    }
    const params = {
        books: books,
        page: 'Authors', 
        method:'', 
        postState: ''
    }
    simpleRender(req, res, params)
})

router.get('/:id/edit', (req,res)=> {
    const params = {
        page: 'Author', 
        method: 'edit', 
        // postState: 'updated'
    }
    simpleRender(req, res, params)
})

router.put('/:id', async (req,res)=> {
    const updateAuthorOption = {
        name: req.body.name
    }
    try {
        const updatedAuthor = await Author.findByIdAndUpdate(req.params.id, updateAuthorOption)
        await updatedAuthor.save()
        updatedAuthor.name = updateAuthorOption.name
        res.render('Authors/author', {
            id: req.params.id, 
            author: updatedAuthor,
            postState: 'updated'
        })
    } catch (error) {
        console.error(res,err)
        res.render('404')
    }
})

router.delete('/:id', async (req,res)=> {
    try {
        var author = await Author.findById(req.params.id)
        await author.remove()
        res.redirect('/authors')
    } catch (error) {
        errorHandler(res, `Authors/author`, {author: author, errorMessage: error})
    }
})

const simpleRender = async (req, res, params) => {
    try {
        const author = await Author.find({_id: req.params.id})
        res.render(`Authors/${params.method}author`, {author: author[0], books: params.books, postState: params.postState})
    } catch (error) {
        errorHandler(res, params.page, {errorMessage: error})
    }
}
const errorHandler =(res, page, renderParams)=> {
    console.error(renderParams.errorMeassge)
        res.render(page, renderParams)
}
module.exports = router