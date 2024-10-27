//filename:famie/server/app_time.js
const express = require('express');
const router = express.Router();
const { ObjectId } = require('mongodb');

// Helper function to calculate allowed_time in seconds
function calculateAllowedTime(start_time, end_time) {
    const [startHour, startMinute] = start_time.split(':').map(Number);
    const [endHour, endMinute] = end_time.split(':').map(Number);

    const startDate = new Date(1970, 0, 1, startHour, startMinute);
    let endDate = new Date(1970, 0, 1, endHour, endMinute);

    // Handle cases where the end time is past midnight
    if (endDate < startDate) {
        endDate.setDate(endDate.getDate() + 1); // Add a day to endDate if it's past midnight
    }

    // Calculate the allowed_time in seconds
    return (endDate - startDate) / 1000; // Return the allowed time in seconds
}

// Save time schedule for the app
router.post('/save_schedule/:appName', async (req, res) => {
    const appName = String(req.params.appName);
    const { childId, timeSlots, slotIdentifier } = req.body;

    // Validate childId and timeSlots
    if (!childId || !ObjectId.isValid(childId)) {
        return res.status(400).json({ message: 'Valid childId is required' });
    }

    if (!timeSlots || !Array.isArray(timeSlots) || timeSlots.length === 0) {
        return res.status(400).json({ message: 'Valid timeSlots array is required' });
    }

    try {
        const appTimeManagementCollection = req.app.locals.db.collection('app_time_management');
        const timeManagementCollection = req.app.locals.db.collection('time_management');

        // Fetch screen time for the child
        const screenTime = await timeManagementCollection.findOne({
            child_id: new ObjectId(childId),
        });

        if (!screenTime || !screenTime.time_slots) {
            return res.status(400).json({ message: 'No screen time available for this child' });
        }

        const validTimeSlots = screenTime.time_slots;

        // Ensure all provided time slots fall within the allowed screen time slots
        const isValidTime = timeSlots.every(appSlot => {
            return validTimeSlots.some(screenSlot => {
                const appStart = new Date(`1970-01-01T${appSlot.start_time}:00Z`);
                const appEnd = new Date(`1970-01-01T${appSlot.end_time}:00Z`);
                const screenStart = new Date(`1970-01-01T${screenSlot.start_time}:00Z`);
                const screenEnd = new Date(`1970-01-01T${screenSlot.end_time}:00Z`);
                return appStart >= screenStart && appEnd <= screenEnd;
            });
        });

        if (!isValidTime) {
            return res.status(400).json({ message: 'App time must fall within allowed screen time ranges' });
        }

        // Prepare time slots data for saving
        const timeSlotsData = timeSlots.map(slot => ({
            start_time: slot.start_time,
            end_time: slot.end_time,
            allowed_time: calculateAllowedTime(slot.start_time, slot.end_time), // Use the helper function to calculate allowed_time
            slot_identifier: new ObjectId(slotIdentifier || new ObjectId())
        }));

        // Check if the app already has a time schedule
        const existingEntry = await appTimeManagementCollection.findOne({
            child_id: new ObjectId(childId),
            app_name: appName
        });

        if (existingEntry) {
            // Update existing time slots
            const updateResult = await appTimeManagementCollection.updateOne(
                { child_id: new ObjectId(childId), app_name: appName },
                { $push: { time_slots: { $each: timeSlotsData } }, $set: { is_allowed: true } }
            );
            return updateResult.matchedCount > 0
                ? res.status(200).json({ message: 'Time schedule updated successfully' })
                : res.status(500).json({ message: 'Failed to update time schedule' });
        } else {
            // Insert new time schedule for the app
            const insertResult = await appTimeManagementCollection.insertOne({
                child_id: new ObjectId(childId),
                app_name: appName,
                is_allowed: true,
                time_slots: timeSlotsData
            });
            return insertResult.acknowledged
                ? res.status(201).json({ message: 'Time schedule saved successfully' })
                : res.status(500).json({ message: 'Failed to save time schedule' });
        }
    } catch (error) {
        console.error('Error saving time schedule:', error);
        return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// Fetch app time schedules
router.get('/fetch_app_time_schedule/:appName', async (req, res) => {
    const { appName } = req.params;
    const { child_id } = req.query;

    // Validate child_id
    if (!child_id || !ObjectId.isValid(child_id)) {
        console.error("Invalid or missing child_id");
        return res.status(400).json({ message: "Valid child_id is required" });
    }

    try {
        const appTimeManagementCollection = req.app.locals.db.collection('app_time_management');

        // Fetch time schedules for the given app and child
        const appTimeData = await appTimeManagementCollection.findOne({
            child_id: new ObjectId(child_id),
            app_name: appName
        });

        if (appTimeData) {
            console.log(`Time slots found for childId: ${child_id}, appName: ${appName}`);
            res.status(200).json(appTimeData.time_slots);
        } else {
            console.log(`No time schedules found for appName: ${appName} and childId: ${child_id}`);
            res.status(404).json({ message: 'No time schedules found for this app and child' });
        }
    } catch (error) {
        console.error('Error fetching app time schedules:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// Delete a specific time slot
router.delete('/delete_schedule/:appName/:index', async (req, res) => {
    const { appName, index } = req.params;
    const { child_id } = req.query;

    // Validate child_id
    if (!ObjectId.isValid(child_id)) {
        return res.status(400).json({ message: 'Invalid child_id' });
    }

    try {
        const appTimeManagementCollection = req.app.locals.db.collection('app_time_management');

        // Ensure index is an integer
        const timeSlotIndex = parseInt(index, 10);

        // Find the app entry for the given child and app
        const appEntry = await appTimeManagementCollection.findOne({
            child_id: new ObjectId(child_id),
            app_name: appName,
        });

        // Validate time slot index
        if (!appEntry || !appEntry.time_slots || appEntry.time_slots.length <= timeSlotIndex) {
            return res.status(404).json({ message: 'Time slot not found' });
        }

        // Remove the specific time slot
        const updatedTimeSlots = appEntry.time_slots.filter((_, i) => i !== timeSlotIndex);

        // Update the document
        const result = await appTimeManagementCollection.updateOne(
            { child_id: new ObjectId(child_id), app_name: appName },
            { $set: { time_slots: updatedTimeSlots } }
        );

        return result.modifiedCount > 0
            ? res.status(200).json({ message: 'Time slot deleted successfully' })
            : res.status(500).json({ message: 'Failed to delete time slot' });
    } catch (error) {
        console.error('Error deleting time slot:', error);
        return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

module.exports = router;

/*
const express = require('express');
const router = express.Router();
const { ObjectId } = require('mongodb');

// Save time schedule for the app
router.post('/save_schedule/:appName', async (req, res) => {
    const appName = String(req.params.appName);
    const { childId, timeSlots, allowedTime, slotIdentifier } = req.body;

    if (!childId) {
        return res.status(400).json({ message: 'childId is required' });
    }

    if (!timeSlots || !Array.isArray(timeSlots) || timeSlots.length === 0) {
        return res.status(400).json({ message: 'Valid timeSlots array is required' });
    }

    try {
        const appTimeManagementCollection = req.app.locals.db.collection('app_time_management');
        const timeManagementCollection = req.app.locals.db.collection('time_management');

        const screenTime = await timeManagementCollection.findOne({
            child_id: new ObjectId(childId),
        });

        if (!screenTime || !screenTime.time_slots) {
            return res.status(400).json({ message: 'No screen time available for this child' });
        }

        const validTimeSlots = screenTime.time_slots;

        const isValidTime = timeSlots.every(appSlot => {
            return validTimeSlots.some(screenSlot => {
                const appStart = new Date(`1970-01-01T${appSlot.start_time}:00Z`);
                const appEnd = new Date(`1970-01-01T${appSlot.end_time}:00Z`);
                const screenStart = new Date(`1970-01-01T${screenSlot.start_time}:00Z`);
                const screenEnd = new Date(`1970-01-01T${screenSlot.end_time}:00Z`);

                return appStart >= screenStart && appEnd <= screenEnd;
            });
        });

        if (!isValidTime) {
            return res.status(400).json({ message: 'App time must fall within allowed screen time ranges' });
        }

        const timeSlotsData = timeSlots.map(slot => ({
            start_time: slot.start_time,
            end_time: slot.end_time,
            allowed_time: allowedTime || 3600,
            slot_identifier: new ObjectId(slotIdentifier || new ObjectId())
        }));

        const existingEntry = await appTimeManagementCollection.findOne({
            child_id: new ObjectId(childId),
            app_name: appName
        });

        if (existingEntry) {
            const updateResult = await appTimeManagementCollection.updateOne(
                { child_id: new ObjectId(childId), app_name: appName },
                { $push: { time_slots: { $each: timeSlotsData } }, $set: { is_allowed: true } }
            );
            return updateResult.matchedCount > 0
                ? res.status(200).json({ message: 'Time schedule updated successfully' })
                : res.status(500).json({ message: 'Failed to update time schedule' });
        } else {
            const insertResult = await appTimeManagementCollection.insertOne({
                child_id: new ObjectId(childId),
                app_name: appName,
                is_allowed: true,
                time_slots: timeSlotsData
            });

            return insertResult.acknowledged
                ? res.status(201).json({ message: 'Time schedule saved successfully' })
                : res.status(500).json({ message: 'Failed to save time schedule' });
        }
    } catch (error) {
        console.error('Error saving time schedule:', error);
        return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// Fetch app time schedules
router.get('/fetch_app_time_schedule/:appName', async (req, res) => {
    const { appName } = req.params;
    const { child_id } = req.query;

    console.log(`Received request to fetch time schedule for appName: ${appName} and childId: ${child_id}`);

    // Validate child_id
    if (!child_id) {
        console.error("Missing child_id in request");
        return res.status(400).json({ message: "child_id is required" });
    }

    try {
        const appTimeManagementCollection = req.app.locals.db.collection('app_time_management');

        // Ensure child_id is valid
        if (!ObjectId.isValid(child_id)) {
            console.error(`Invalid child_id format: ${child_id}`);
            return res.status(400).json({ message: "Invalid child_id format" });
        }

        // Query to find the app time schedule
        const appTimeData = await appTimeManagementCollection.findOne({
            child_id: new ObjectId(child_id),
            app_name: appName
        });

        if (appTimeData) {
            console.log(`Time slots found for childId: ${child_id}, appName: ${appName}`, appTimeData.time_slots);
            res.status(200).json(appTimeData.time_slots);
        } else {
            console.error(`No time schedules found for appName: ${appName} and childId: ${child_id}`);
            res.status(404).json({ message: 'No time schedules found for this app and child' });
        }
    } catch (error) {
        console.error('Error fetching app time schedules:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});
// Delete a specific time slot
router.delete('/delete_schedule/:appName/:index', async (req, res) => {
    const { appName, index } = req.params;
    const { child_id } = req.query;
  
    try {
      const appTimeManagementCollection = req.app.locals.db.collection('app_time_management');
  
      // Ensure index is an integer
      const timeSlotIndex = parseInt(index, 10);
  
      // Validate child_id
      if (!ObjectId.isValid(child_id)) {
        return res.status(400).json({ message: 'Invalid child_id' });
      }
  
      // Find the app and child time schedule entry
      const appEntry = await appTimeManagementCollection.findOne({
        child_id: new ObjectId(child_id),
        app_name: appName,
      });
  
      if (!appEntry || !appEntry.time_slots || appEntry.time_slots.length <= timeSlotIndex) {
        return res.status(404).json({ message: 'Time slot not found' });
      }
  
      // Remove the time slot at the given index
      const updatedTimeSlots = appEntry.time_slots.filter((_, i) => i !== timeSlotIndex);
  
      // Update the document in the collection
      const result = await appTimeManagementCollection.updateOne(
        { child_id: new ObjectId(child_id), app_name: appName },
        { $set: { time_slots: updatedTimeSlots } }
      );
  
      if (result.modifiedCount > 0) {
        return res.status(200).json({ message: 'Time slot deleted successfully' });
      } else {
        return res.status(500).json({ message: 'Failed to delete time slot' });
      }
    } catch (error) {
      console.error('Error deleting time slot:', error);
      return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
  });
  
module.exports = router;
*/
/*
const express = require('express');
const router = express.Router();
const { ObjectId } = require('mongodb');

// saving schedules to app time management
router.post('/save_schedule/:appName', async (req, res) => {
    const appName = String(req.params.appName); // Ensure app_name is a string
    const { childId, timeSlots, allowedTime, slotIdentifier } = req.body; // removed isAllowed from the body
  
    // Validate the input
    if (!childId) {
      return res.status(400).json({ message: 'childId is required' });
    }
  
    if (!timeSlots || !Array.isArray(timeSlots) || timeSlots.length === 0) {
      return res.status(400).json({ message: 'Valid timeSlots array is required' });
    }
  
    try {
      const appTimeManagementCollection = req.app.locals.db.collection('app_time_management');
      const timeManagementCollection = req.app.locals.db.collection('time_management');
  
      // Fetch the allowed screen time from the time_management collection
      const screenTime = await timeManagementCollection.findOne({
        child_id: new ObjectId(childId),
      });
  
      if (!screenTime || !screenTime.time_slots) {
        return res.status(400).json({ message: 'No screen time available for this child' });
      }
  
      // Validate the app time against the screen time
      const validTimeSlots = screenTime.time_slots;
  
      const isValidTime = timeSlots.every(appSlot => {
        return validTimeSlots.some(screenSlot => {
          const appStart = new Date(`1970-01-01T${appSlot.start_time}:00Z`);
          const appEnd = new Date(`1970-01-01T${appSlot.end_time}:00Z`);
          const screenStart = new Date(`1970-01-01T${screenSlot.start_time}:00Z`);
          const screenEnd = new Date(`1970-01-01T${screenSlot.end_time}:00Z`);
  
          return appStart >= screenStart && appEnd <= screenEnd;
        });
      });
  
      if (!isValidTime) {
        return res.status(400).json({ message: 'App time must fall within the allowed screen time ranges' });
      }
  
      // Check if the app time management entry for this app and child already exists
      const existingEntry = await appTimeManagementCollection.findOne({
        child_id: new ObjectId(childId),
        app_name: appName  // This is where the actual app name should go
      });
  
      const timeSlotsData = timeSlots.map(slot => ({
        start_time: slot.start_time,
        end_time: slot.end_time,
        allowed_time: allowedTime || 3600,
        slot_identifier: new ObjectId(slotIdentifier || new ObjectId())
      }));
  
      if (existingEntry) {
        console.log('Existing entry found, updating...');
        const updateResult = await appTimeManagementCollection.updateOne(
          { child_id: new ObjectId(childId), app_name: appName },
          { 
            $push: { time_slots: { $each: timeSlotsData } },
            $set: { is_allowed: true } // Always set to true when updating
          }
        );
  
        if (updateResult.matchedCount > 0) {
          return res.status(200).json({ message: 'Time schedule updated successfully' });
        } else {
          return res.status(500).json({ message: 'Failed to update time schedule' });
        }
      } else {
        // Insert a new document with the correct app name and is_allowed set to true
        const insertResult = await appTimeManagementCollection.insertOne({
          child_id: new ObjectId(childId),
          app_name: appName,  
          is_allowed: true,  // Always set to true when inserting
          time_slots: timeSlotsData
        });
  
        if (insertResult.acknowledged) {
          return res.status(201).json({ message: 'Time schedule saved successfully' });
        } else {
          return res.status(500).json({ message: 'Failed to save time schedule' });
        }
      }
    } catch (error) {
      // Catch any errors and log them
      console.error('Error saving time schedule:', error);
      return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
  });
  // Fetch app time schedules for a specific app and child
// Fetch app time schedule
router.get('/fetch_app_time_schedule/:appId', async (req, res) => {
    const { appId } = req.params;
    const { child_id } = req.query; // Fetch child_id from the query parameter

    try {
        const appTimeManagementCollection = req.app.locals.db.collection('app_time_management');
        
        const appTimeData = await appTimeManagementCollection.findOne({
            child_id: new ObjectId(child_id),
            app_name: appId // Match the appId with app_name
        });

        if (appTimeData) {
            res.status(200).json(appTimeData.time_slots);
        } else {
            res.status(404).json({ message: 'No time schedules found for this app and child' });
        }
    } catch (error) {
        console.error('Error fetching app time schedules:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});
module.exports = router;
*/