const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const ChildRegistrationSchema = new Schema({
    username: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    day: { type: Number, required: true },
    month: { type: Number, required: true },
    year: { type: Number, required: true }
});

module.exports = mongoose.model('ChildRegistration', ChildRegistrationSchema);
