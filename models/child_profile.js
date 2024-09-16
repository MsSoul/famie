const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const ChildProfileSchema = new Schema({
    parent_id: { type: Schema.Types.ObjectId, ref: 'ParentRegistration', required: true },
    child_registration_id: { type: Schema.Types.ObjectId, ref: 'ChildRegistration', required: true },
    name: { type: String, required: true },
    avatar: { type: String, required: true },
    device_name: { type: String, required: true },
    mac_address: { type: String, required: true, unique: true }
});

module.exports = mongoose.model('ChildProfile', ChildProfileSchema);
