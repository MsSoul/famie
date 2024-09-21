// filename: settings.js
const express = require('express');
const router = express.Router();
const { ObjectId } = require('mongodb');

// Update app status function
router.post('/updateAppStatus', async (req, res) => {
  const { childId, appName, isAllowed } = req.body;
  const db = req.app.locals.db; // Access the shared db connection from server.js

  try {
    const result = await db.collection('app_management').updateOne(
      { child_id: new ObjectId(childId), app_name: appName },
      { $set: { is_allowed: isAllowed } }
    );

    if (result.modifiedCount > 0) {
      res.status(200).json({ message: 'App status updated successfully' });
    } else {
      res.status(404).json({ message: 'App not found or no changes made' });
    }
  } catch (error) {
    console.error('Error updating app status:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

module.exports = router;
