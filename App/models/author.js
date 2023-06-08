const mongoose = require('mongoose')

const Book = require('./book')

const authorSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    }
})

authorSchema.pre('remove', async function(next){
    try {
        var books = await Book.find({author: this._id})
        if(books.length > 0) {
            var err = new Error("Cannot delete. \nA Book with this author still exists in your library.")
            next(err)
        } else next()
    } catch (error) {
        next(error)
    }
    
})

module.exports = mongoose.model('Author', authorSchema)