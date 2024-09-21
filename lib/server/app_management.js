//filename:server/app_mangement.js
const express = require('express');
const router = express.Router();
const { ObjectId } = require('mongodb'); // Ensure ObjectId is imported correctly

// Fetch apps from app_list for a specific child and include is_allowed from app_management
router.get('/app_list', async (req, res) => {
    const childId = req.query.child_id;

    try {
        // Fetch from the app_list collection
        const appListCollection = req.app.locals.db.collection('app_list');
        const appManagementCollection = req.app.locals.db.collection('app_management');

        // Use 'new' when creating ObjectId
        const apps = await appListCollection.find({ child_id: new ObjectId(childId) }).toArray();

        // Fetch the app management data for the same child
        const appManagement = await appManagementCollection.find({ child_id: new ObjectId(childId) }).toArray();

        // Combine app_list data with the is_allowed status from app_management
        const combinedApps = apps.map(app => {
            const managementEntry = appManagement.find(m => m.app_id.equals(app._id));
            return {
                _id: app._id,
                app_name: app.app_name,
                package_name: app.package_name,
                is_allowed: managementEntry ? managementEntry.is_allowed : false // Default to false if no entry found
            };
        });

        return res.status(200).json(combinedApps);
    } catch (error) {
        console.error('Error fetching app list:', error);
        return res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;
