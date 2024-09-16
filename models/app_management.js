const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const AppManagementSchema = new Schema({
    child_id: { type: Schema.Types.ObjectId, ref: 'ChildProfile', required: true },
    app_name: { type: String, required: true },
    package_name: { type: String, required: true },
    is_allowed: { type: Boolean, required: true }
});

module.exports = mongoose.model('AppManagement', AppManagementSchema);
