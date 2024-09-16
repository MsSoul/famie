const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const AppTimeManagementSchema = new Schema({
    app_id: { type: Schema.Types.ObjectId, ref: 'AppManagement', required: true },
    child_id: { type: Schema.Types.ObjectId, ref: 'ChildProfile', required: true },
    start_time: { type: String, required: true },
    end_time: { type: String, required: true }
});

module.exports = mongoose.model('AppTimeManagement', AppTimeManagementSchema);
