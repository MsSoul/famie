// filename: server/dashboard_app_time.js
const express = require('express');
const router = express.Router();
const { ObjectId } = require('mongodb');

// WebSocket server setup (you can integrate it with your server)
let appTimeWebSocket = null;
function setAppTimeWebSocket(ws) {
    appTimeWebSocket = ws;
}

// Function to calculate remaining app time
function calculateRemainingTime(startTime, allowedTime) {
    const now = new Date();
    const startTimeDate = new Date(`1970-01-01T${startTime}:00`);
    const endTimeDate = new Date(startTimeDate.getTime() + allowedTime * 1000); // allowedTime is in seconds

    if (now >= endTimeDate) {
        return 0; // No remaining time
    }
    const remainingTime = (endTimeDate - now) / 1000; // Convert milliseconds to seconds
    return remainingTime > 0 ? remainingTime : 0;
}

// Route to fetch app time management data
router.get('/get-app-time/:child_id', async (req, res) => {
    const { child_id } = req.params;
    const db = req.app.locals.db;

    try {
        const filter = ObjectId.isValid(child_id) ? { child_id: new ObjectId(child_id) } : { child_id };
        const appTimeData = await db.collection('app_time_management').find(filter).toArray();

        if (!appTimeData || appTimeData.length === 0) {
            return res.status(404).json({ message: 'No app time data found.' });
        }

        res.status(200).json(appTimeData);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Route to fetch and calculate remaining app time
router.get('/get-remaining-app-time/:child_id', async (req, res) => {
    const { child_id } = req.params;
    const db = req.app.locals.db;

    try {
        const filter = ObjectId.isValid(child_id) ? { child_id: new ObjectId(child_id) } : { child_id };
        const appTimeData = await db.collection('app_time_management').find(filter).toArray();

        if (!appTimeData || appTimeData.length === 0) {
            return res.status(404).json({ message: 'No app time data found.' });
        }

        const remainingAppTimeData = appTimeData.map(app => {
            const remainingTimes = app.time_slots.map(slot => {
                const remainingTime = calculateRemainingTime(slot.start_time, slot.allowed_time);
                return { ...slot, remaining_time: remainingTime };
            });
            return { ...app, time_slots: remainingTimes };
        });

        res.status(200).json(remainingAppTimeData);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// WebSocket notification for real-time updates
function notifyAppTimeUpdate(child_id) {
    if (appTimeWebSocket && appTimeWebSocket.readyState === 1) {
        appTimeWebSocket.send(JSON.stringify({ type: 'app-time-update', child_id }));
    }
}

module.exports = { router, setAppTimeWebSocket, notifyAppTimeUpdate };
