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

// Route to fetch app time data
router.get('/get-app-time/:child_id', async (req, res) => {
    let { child_id } = req.params;

    try {
        const db = getDbConnection(req);

        // Convert child_id to ObjectId if required
        if (ObjectId.isValid(child_id)) {
            child_id = new ObjectId(child_id);
        }

        const appTimeData = await db.collection('remaining_app_time').find({ child_id }).toArray();

        if (appTimeData.length === 0) {
            return res.status(404).json({ message: 'No app time data found for the specified child ID.' });
        }

        res.status(200).json(appTimeData);
    } catch (error) {
        console.error('Error fetching app time data:', error.message);
        res.status(500).json({
            message: process.env.NODE_ENV === 'production' ? 'Internal Server Error' : `Error: ${error.message}`
        });
    }
});

// Route to fetch remaining app time data
router.get('/get-remaining-app-time/:child_id', async (req, res) => {
    let { child_id } = req.params;

    try {
        const db = getDbConnection(req);

        // Convert child_id to ObjectId if required
        if (ObjectId.isValid(child_id)) {
            child_id = new ObjectId(child_id);
        }

        const remainingAppTimeData = await db.collection('remaining_app_time').find({ child_id }).toArray();

        if (!remainingAppTimeData || remainingAppTimeData.length === 0) {
            return res.status(404).json({ message: 'No remaining app time data found for the specified child ID.' });
        }

        res.status(200).json(remainingAppTimeData);
    } catch (err) {
        console.error('Error fetching remaining app time data:', err.message);
        res.status(500).json({
            message: process.env.NODE_ENV === 'production' ? 'Internal Server Error' : `Error: ${err.message}`
        });
    }
});

module.exports = router;
