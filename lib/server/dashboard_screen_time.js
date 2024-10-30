// filename: server/dashboard_screen_time.js
const express = require('express');
const { ObjectId } = require('mongodb');
const router = express.Router();

// Route to fetch time schedule (time_slots from time_management)
router.get('/get-time-schedule/:child_id', async (req, res) => {
    const { child_id } = req.params;
    const db = req.app.locals.db;

    try {
        const filter = ObjectId.isValid(child_id) ? { child_id: new ObjectId(child_id) } : { child_id };
        const schedule = await db.collection('time_management').findOne(filter);

        if (!schedule) {
            return res.status(404).json({ message: 'No time schedule found.' });
        }
        res.status(200).json(schedule);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Route to fetch remaining time (time_slots from remaining_time)
router.get('/get-remaining-time/:child_id', async (req, res) => {
    const { child_id } = req.params;
    const db = req.app.locals.db;

    try {
        const filter = ObjectId.isValid(child_id) ? { child_id: new ObjectId(child_id) } : { child_id };
        const remainingTime = await db.collection('remaining_time').findOne(filter);

        if (!remainingTime || !remainingTime.time_slots) {
            return res.status(404).json({ message: 'No remaining time slots found.' });
        }

        res.status(200).json({
            message: 'Remaining time fetched successfully',
            remaining_time: remainingTime.time_slots,
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Route to fetch allowed time (from time_management)
router.get('/get-allowed-time/:child_id', async (req, res) => {
    const { child_id } = req.params;
    const db = req.app.locals.db;

    try {
        const filter = ObjectId.isValid(child_id) ? { child_id: new ObjectId(child_id) } : { child_id };
        const schedule = await db.collection('time_management').findOne(filter);

        if (!schedule || !schedule.time_slots) {
            return res.status(404).json({ message: 'No allowed time found.' });
        }

        const allowedTime = schedule.time_slots.map(slot => ({
            allowed_time: slot.allowed_time,
        }));

        res.status(200).json({
            message: 'Allowed time fetched successfully',
            allowed_time: allowedTime,
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
