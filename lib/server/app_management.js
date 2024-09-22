//filename:server/app_mangement.js
const express = require('express');
const router = express.Router();
const { ObjectId } = require('mongodb');

// Sync apps from app_list to app_management
router.get('/sync_app_management', async (req, res) => {
    const childId = req.query.child_id;
    const parentId = req.query.parent_id;

    try {
        const appListCollection = req.app.locals.db.collection('app_list');
        const appManagementCollection = req.app.locals.db.collection('app_management');

        const apps = await appListCollection.find({ child_id: new ObjectId(childId) }).toArray();
        console.log("Apps fetched from app_list:", apps);

        if (apps.length > 0) {
            // Sync apps into app_management
            for (const app of apps) {
                const existingEntry = await appManagementCollection.findOne({
                    child_id: new ObjectId(childId),
                    package_name: app.package_name
                });

                if (!existingEntry) {
                    console.log(`Inserting ${app.app_name} into app_management for child ${childId}`);
                    await appManagementCollection.insertOne({
                        child_id: new ObjectId(childId),
                        parent_id: new ObjectId(parentId),
                        app_name: app.app_name,
                        package_name: app.package_name,
                        is_allowed: true
                    });
                }
            }

            return res.status(200).json(apps);
        } else {
            return res.status(404).json({ message: 'No apps found for this child in app_list' });
        }
    } catch (error) {
        console.error('Error syncing apps:', error);
        return res.status(500).json({ message: 'Internal server error' });
    }
});

// Fetch apps from app_management for a specific child
router.get('/fetch_app_management', async (req, res) => {
    const childId = req.query.child_id;

    try {
        const appManagementCollection = req.app.locals.db.collection('app_management');

        const apps = await appManagementCollection.find({ child_id: new ObjectId(childId) }).toArray();

        if (apps.length > 0) {
            return res.status(200).json(apps);
        } else {
            return res.status(404).json({ message: 'No apps found for this child in app_management' });
        }
    } catch (error) {
        console.error('Error fetching app_management list:', error);
        return res.status(500).json({ message: 'Internal server error' });
    }
});

// Update app_management based on toggle click
router.post('/update_app_management/:package_name', async (req, res) => {
    const { package_name } = req.params; // Use package_name as identifier
    const { childId, isAllowed, parentId } = req.body;

    try {
        const appManagementCollection = req.app.locals.db.collection('app_management');

        // Find the app in app_management based on childId and package_name
        const appEntry = await appManagementCollection.findOne({
            child_id: new ObjectId(childId),
            package_name: package_name
        });

        if (appEntry) {
            // Update the is_allowed field when the toggle is clicked
            await appManagementCollection.updateOne(
                { child_id: new ObjectId(childId), package_name: package_name },
                { $set: { is_allowed: isAllowed, parent_id: new ObjectId(parentId) } }
            );

            console.log(`Toggle status for ${package_name} updated to ${isAllowed ? 'true' : 'false'} for child ${childId}`);
            return res.status(200).json({ message: 'App toggle status updated successfully' });
        } else {
            // Handle case where app is not found in app_management
            return res.status(404).json({ message: 'App not found in app_management' });
        }
    } catch (error) {
        console.error('Error updating app toggle status:', error);
        return res.status(500).json({ message: 'Internal server error' });
    }
});


module.exports = router;

/*
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
// POST route to update app's is_allowed status in app_management
// POST route to update app's is_allowed status in app_management
router.post('/:appId', async (req, res) => {
    const appId = new ObjectId(req.params.appId);
    const { childId, isAllowed, appName, packageName, parentId } = req.body;

    try {
        const collection = req.app.locals.db.collection('app_management');

        const appEntry = await collection.findOne({ app_id: appId, child_id: new ObjectId(childId) });

        if (appEntry) {
            // Update the is_allowed status if the entry exists
            await collection.updateOne(
                { app_id: appId, child_id: new ObjectId(childId) },
                { $set: { is_allowed: isAllowed } }
            );
            return res.status(200).json({ message: 'App toggle status updated successfully' });
        } else {
            // Insert a new entry if none exists in app_management
            await collection.insertOne({
                app_id: appId,
                child_id: new ObjectId(childId),
                is_allowed: isAllowed,
                app_name: appName, // Ensure app_name is saved
                package_name: packageName, // Ensure package_name is saved
                parent_id: parentId // Ensure parent_id is saved if provided
            });
            return res.status(201).json({ message: 'App added to app_management and toggle status set' });
        }
    } catch (error) {
        console.error('Error updating app toggle status:', error);
        return res.status(500).json({ message: 'Internal server error' });
    }
});



module.exports = router;
*/