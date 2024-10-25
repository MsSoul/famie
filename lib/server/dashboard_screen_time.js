//filename:server/dashboard_screen_time.js
const express = require('express');
const { MongoClient, ObjectId } = require('mongodb');
const WebSocket = require('ws');
const router = express.Router();

let wss;

// Initialize WebSocket server
function initWebSocket(server) {
  wss = new WebSocket.Server({ server });

  wss.on('connection', (ws) => {
    console.log('Client connected to WebSocket');

    ws.on('close', () => {
      console.log('Client disconnected');
    });
  });
}

// Broadcast updates to all connected clients
function broadcastToClients(data) {
  if (wss && wss.clients) {
    wss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify(data));
      }
    });
  }
}

// Watch MongoDB changes for real-time updates
async function watchTimeScheduleChanges(db) {
  const timeManagementCollection = db.collection('time_management');
  const remainingTimeCollection = db.collection('remaining_time');

  const timeScheduleChangeStream = timeManagementCollection.watch();
  const remainingTimeChangeStream = remainingTimeCollection.watch();

  // Watch for changes in the time_management collection
  timeScheduleChangeStream.on('change', (change) => {
    console.log('Time Schedule Change detected:', change);
    broadcastToClients({ type: 'time_schedule_update', data: change });
  });

  // Watch for changes in the remaining_time collection
  remainingTimeChangeStream.on('change', (change) => {
    console.log('Remaining Time Change detected:', change);
    broadcastToClients({ type: 'remaining_time_update', data: change });
  });
}

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

    // Log the retrieved remaining time document for debugging
    console.log('Retrieved remaining time:', remainingTime);

    // Check if remainingTime is found and has a time_slots property
    if (!remainingTime || !remainingTime.time_slots) {
      return res.status(404).json({ message: 'No remaining time slots found.' });
    }

    // Respond with detailed information about the remaining time
    res.status(200).json({
      message: 'Remaining time fetched successfully',
      remaining_time: remainingTime.time_slots,
      total_time: remainingTime.total_time || 'No total time defined',
      last_updated: remainingTime.last_updated || 'Not available',
      // Add any other relevant fields from remainingTime as needed
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


module.exports = { router, initWebSocket, watchTimeScheduleChanges };


/*const express = require('express');
const router = express.Router();
const { ObjectId } = require('mongodb');

// Route to fetch time schedule (time_slots from time_management)
// Route to fetch time schedule
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
    res.status(200).json(remainingTime);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
*/