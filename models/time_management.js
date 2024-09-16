const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const TimeManagementSchema = new Schema({
    child_id: { type: Schema.Types.ObjectId, ref: 'ChildProfile', required: true },
    start_time: { type: String, required: true },
    end_time: { type: String, required: true },
    is_allowed: { type: Boolean, required: true }
});

module.exports = mongoose.model('TimeManagement', TimeManagementSchema);
