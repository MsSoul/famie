const express = require('express');
const { ObjectId } = require('mongodb');
const router = express.Router();

// Log that the file is running
console.log('theme.js is running');

// Route to fetch theme based on adminId
router.get('/theme/:adminId', async (req, res) => {
    const db = req.app.locals.db;
    const { adminId } = req.params;

    if (!ObjectId.isValid(adminId)) {
      return res.status(400).json({ message: 'Invalid adminId format' });
    }

    try {
      const themeData = await db.collection('theme_management').findOne({
        admin_id: new ObjectId(adminId)
      });

      if (!themeData) {
        return res.status(404).json({ message: 'Theme not found' });
      }

      res.status(200).json(themeData);
    } catch (error) {
      res.status(500).json({ message: 'Internal server error' });
    }
  });
module.exports = router;
