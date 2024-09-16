const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const ThemeManagementSchema = new Schema({
    background_color: { type: String, required: true },
    font_style: { type: String, required: true },
    app_bar_color: { type: String, required: true },
    button_color: { type: String, required: true },
    text_color: { type: String, required: true },
    admin_id: { type: Schema.Types.ObjectId, ref: 'AdminRegistration', required: true }
});

module.exports = mongoose.model('ThemeManagement', ThemeManagementSchema);
