// const path = require("path");
const mongoose = require("mongoose");


const bookSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
    },
    description: {
      type: String,
    },
    cover: {
      type: Buffer,
      required: true,
    },
    coverType: {
      type: String,
      required: true,
    },
    publishDate: {
      type: Date,
      required: true,
    },
    pageCount: {
      type: Number,
      required: true,
    },
    author: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      ref: "Author",
    },
  },
  {
    timestamps: true,
  }
);


bookSchema.virtual("cover_src").get(function() {
    if (this.cover && this.coverType) {
        return `data:${this.coverType};charset=utf-8;base64,${this.cover.toString('base64')}`
    }
})

module.exports = mongoose.model("Book", bookSchema);
