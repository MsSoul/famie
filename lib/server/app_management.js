//filename:server/app_mangement.js
const express = require('express');
const router = express.Router();
const { ObjectId } = require('mongodb');

// Sync apps from app_list to app_management
router.get('/sync_app_management', async (req, res) => {
    const childId = req.query.child_id;

    try {
        const appListCollection = req.app.locals.db.collection('app_list');
        const appManagementCollection = req.app.locals.db.collection('app_management');

        // Fetch the apps from app_list for the given child_id
        const apps = await appListCollection.findOne({ child_id: new ObjectId(childId) });
        console.log("Apps fetched from app_list:", apps);

        // Check if there are system or user apps to sync
        if (apps && (apps.system_apps.length > 0 || apps.user_apps.length > 0)) {
            // Prepare the system apps and user apps arrays
            const systemAppsArray = apps.system_apps.map(app => ({
                app_name: app.appName,
                package_name: app.packageName,
                is_system_app: true,
                is_allowed: true // Default to true when syncing
            }));

            const userAppsArray = apps.user_apps.map(app => ({
                app_name: app.appName,
                package_name: app.packageName,
                is_system_app: false,
                is_allowed: true // Default to true when syncing
            }));

            // Check if app_management document exists for the child
            const existingDoc = await appManagementCollection.findOne({ child_id: new ObjectId(childId) });

            if (!existingDoc) {
                // Insert a new app_management document if it doesn't exist
                await appManagementCollection.insertOne({
                    child_id: new ObjectId(childId),
                    system_apps: systemAppsArray,
                    user_apps: userAppsArray
                });
                console.log(`Inserted new app_management document for child ${childId}`);
            } else {
                // Ensure that system_apps and user_apps exist in the document
                existingDoc.system_apps = existingDoc.system_apps || [];
                existingDoc.user_apps = existingDoc.user_apps || [];

                // Sync system_apps
                for (const app of systemAppsArray) {
                    const existingApp = existingDoc.system_apps.find(a => a.package_name === app.package_name);
                    if (!existingApp) {
                        await appManagementCollection.updateOne(
                            { child_id: new ObjectId(childId) },
                            { $push: { system_apps: app } }
                        );
                    }
                }

                // Sync user_apps
                for (const app of userAppsArray) {
                    const existingApp = existingDoc.user_apps.find(a => a.package_name === app.package_name);
                    if (!existingApp) {
                        await appManagementCollection.updateOne(
                            { child_id: new ObjectId(childId) },
                            { $push: { user_apps: app } }
                        );
                    }
                }

                console.log(`Updated app_management document for child ${childId}`);
            }

            return res.status(200).json({ message: 'Apps synced successfully' });
        } else {
            console.log(`No apps found for child ${childId} in app_list`);
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

        // Fetch the document containing the apps for the given child
        const doc = await appManagementCollection.findOne({ child_id: new ObjectId(childId) });

        if (doc && (doc.system_apps.length > 0 || doc.user_apps.length > 0)) {
            console.log(`Apps found for child ${childId}`);
            return res.status(200).json({
                system_apps: doc.system_apps,
                user_apps: doc.user_apps
            });
        } else {
            console.log(`No apps found for child ${childId} in app_management`);
            return res.status(404).json({ message: 'No apps found for this child in app_management' });
        }
    } catch (error) {
        console.error('Error fetching app_management list:', error);
        return res.status(500).json({ message: 'Internal server error' });
    }
});

// Update app_management based on toggle click
router.post('/update_app_management/:package_name', async (req, res) => {
    const { package_name } = req.params;
    const { childId, isAllowed } = req.body;

    try {
        const appManagementCollection = req.app.locals.db.collection('app_management');

        // Update the specific app's is_allowed status inside system_apps or user_apps
        const result = await appManagementCollection.updateOne(
            { child_id: new ObjectId(childId), "system_apps.package_name": package_name },
            { $set: { "system_apps.$.is_allowed": isAllowed } }
        );

        if (result.matchedCount === 0) {
            const resultUserApp = await appManagementCollection.updateOne(
                { child_id: new ObjectId(childId), "user_apps.package_name": package_name },
                { $set: { "user_apps.$.is_allowed": isAllowed } }
            );

            if (resultUserApp.matchedCount > 0) {
                console.log(`User app ${package_name} isAllowed updated to ${isAllowed} for child ${childId}`);
                return res.status(200).json({ message: 'App toggle status updated successfully' });
            }
        }

        if (result.matchedCount > 0) {
            console.log(`System app ${package_name} isAllowed updated to ${isAllowed} for child ${childId}`);
            return res.status(200).json({ message: 'App toggle status updated successfully' });
        } else {
            console.log(`App with package_name ${package_name} not found for child ${childId}`);
            return res.status(404).json({ message: 'App not found in app_management' });
        }
    } catch (error) {
        console.error('Error updating app toggle status:', error);
        return res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;


/*mugana pero dli pa array ang applist ani
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

        // Fetch apps from app_list collection (individual documents)
        const apps = await appListCollection.find({ child_id: new ObjectId(childId) }).toArray();
        console.log("Apps fetched from app_list:", apps);

        if (apps.length > 0) {
            // Transform the fetched apps into an array of objects for the apps array
            const appsArray = apps.map(app => ({
                app_name: app.app_name,
                package_name: app.package_name,
                is_allowed: true // Default to true when syncing
            }));

            // Check if the app_management document exists for this child
            const existingDoc = await appManagementCollection.findOne({ child_id: new ObjectId(childId) });

            if (!existingDoc) {
                // If no document exists, insert a new document with the apps array
                await appManagementCollection.insertOne({
                    child_id: new ObjectId(childId),
                    parent_id: new ObjectId(parentId),
                    apps: appsArray
                });
                console.log(`Inserted new app_management document for child ${childId}`);
            } else {
                // Ensure the apps array exists in the existing document
                if (!Array.isArray(existingDoc.apps)) {
                    existingDoc.apps = [];
                }

                // If the document exists, update the apps array
                for (const app of appsArray) {
                    const existingApp = existingDoc.apps.find(a => a.package_name === app.package_name);
                    if (!existingApp) {
                        // Add the new app to the apps array
                        await appManagementCollection.updateOne(
                            { child_id: new ObjectId(childId) },
                            { $push: { apps: app } }
                        );
                    }
                }
                console.log(`Updated app_management document for child ${childId}`);
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

        // Fetch the document that holds apps array for this child
        const doc = await appManagementCollection.findOne({ child_id: new ObjectId(childId) });

        if (doc && doc.apps.length > 0) {
            return res.status(200).json(doc.apps); // Return the apps array
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
    const { package_name } = req.params;
    const { childId, isAllowed, parentId } = req.body;

    try {
        const appManagementCollection = req.app.locals.db.collection('app_management');

        // Update the specific app's is_allowed status inside the apps array
        const result = await appManagementCollection.updateOne(
            { child_id: new ObjectId(childId), "apps.package_name": package_name },
            { 
                $set: { 
                    "apps.$.is_allowed": isAllowed, // Update the is_allowed field
                    parent_id: new ObjectId(parentId) // Optional: update parent_id if needed
                } 
            }
        );

        if (result.matchedCount > 0) {
            console.log(`Toggle status for ${package_name} updated to ${isAllowed ? 'true' : 'false'} for child ${childId}`);
            return res.status(200).json({ message: 'App toggle status updated successfully' });
        } else {
            return res.status(404).json({ message: 'App not found in app_management' });
        }
    } catch (error) {
        console.error('Error updating app toggle status:', error);
        return res.status(500).json({ message: 'Internal server error' });
    }
});


module.exports = router;

*/
/*mugana kaso dli gina butang ang existing child id
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
*/
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