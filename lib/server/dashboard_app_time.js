const express = require('express');
const router = express.Router();
const { ObjectId } = require('mongodb');

console.log("Dashboard app time is running");

// Middleware to access the database connection
const getDbConnection = (req) => {
    const db = req.app.locals.db;
    if (!db) throw new Error('Database connection not established');
    return db;
};

// Route to fetch allowed time data for the specified child ID
router.get('/get-app-time/:child_id', async (req, res) => {
    let { child_id } = req.params;

    try {
        const db = getDbConnection(req);

        // Convert child_id to ObjectId if required
        if (ObjectId.isValid(child_id)) {
            child_id = new ObjectId(child_id);
        }

        // Fetch app time data from the 'app_time_management' collection
        const appTimeData = await db.collection('app_time_management').find({ child_id }).toArray();

        if (appTimeData.length === 0) {
            return res.status(404).json({ message: 'No app time data found for the specified child ID.' });
        }

        // Map the data to include allowed_time from time_slots
        const formattedAppTimeData = appTimeData.map(app => {
            return {
                app_name: app.app_name,
                time_slots: app.time_slots.map(slot => ({
                    start_time: slot.start_time,   // Make sure these fields exist
                    end_time: slot.end_time,
                    allowed_time: slot.allowed_time || 0 // Ensure this field exists
                }))
            };
        });

        res.status(200).json(formattedAppTimeData);
    } catch (error) {
        console.error('Error fetching app time data:', error.message);
        res.status(500).json({
            message: process.env.NODE_ENV === 'production' ? 'Internal Server Error' : `Error: ${error.message}`
        });
    }
});

module.exports = router;
