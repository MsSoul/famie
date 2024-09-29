//filename:server/time_management.js
const express = require('express');
const { ObjectId } = require('mongodb');
const router = express.Router();

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

// POST request to update or create time management data for a child
router.post('/:childId', async (req, res) => {
    const childId = req.params.childId;
    const { time_slots } = req.body;  // New time slot(s) being added

    const db = req.app.locals.db;
    if (!db) {
        return res.status(500).json({ message: 'Database not initialized.' });
    }

    try {
        const timeManagementCollection = db.collection('time_management');
        const existingTimeManagement = await timeManagementCollection.findOne({ child_id: new ObjectId(childId) });

        // Calculate allowed_time for each time slot
        const updatedTimeSlots = time_slots.map(slot => {
            const allowedTimeInSeconds = calculateAllowedTime(slot.start_time, slot.end_time);
            return {
                ...slot,
                allowed_time: allowedTimeInSeconds // Add allowed_time to the slot
            };
        });

        // Merge with existing time slots if they exist
        let finalTimeSlots = updatedTimeSlots;
        if (existingTimeManagement && existingTimeManagement.time_slots) {
            finalTimeSlots = [...existingTimeManagement.time_slots, ...updatedTimeSlots];
        }

        // Update or create the time slots
        await timeManagementCollection.updateOne(
            { child_id: new ObjectId(childId) },
            { $set: { time_slots: finalTimeSlots } },  // Update the time slots array
            { upsert: true }  // Create a new document if it doesn't exist
        );

        res.status(200).json({ message: 'Time slots updated successfully.' });
    } catch (error) {
        res.status(500).json({ message: 'Error saving time management data.' });
    }
});

// GET request to fetch time slots for a child
router.get('/:childId', async (req, res) => {
    const childId = req.params.childId;

    console.log('Received GET request to /time_management/:childId');
    console.log('Child ID:', childId);

    const db = req.app.locals.db;
    if (!db) {
        console.error('Database not initialized.');
        return res.status(500).json({ message: 'Database not initialized.' });
    }

    try {
        const timeManagementCollection = db.collection('time_management');
        const timeManagementData = await timeManagementCollection.findOne({ child_id: new ObjectId(childId) });

        if (timeManagementData) {
            res.status(200).json(timeManagementData.time_slots);
        } else {
            res.status(404).json({ message: 'No time management data found for this child.' });
        }
    } catch (error) {
        console.error('Error fetching time management data:', error);
        res.status(500).json({ message: 'Error fetching time management data.' });
    }
});

// PATCH request to toggle is_allowed status
router.patch('/:childId/:slotIndex', async (req, res) => {
    const childId = req.params.childId;
    const slotIndex = parseInt(req.params.slotIndex);
    const { is_allowed } = req.body;

    console.log('Received PATCH request to /time_management/:childId/:slotIndex for toggling status');
    console.log('Child ID:', childId);
    console.log('Slot Index:', slotIndex);
    console.log('Is Allowed:', is_allowed);

    const db = req.app.locals.db;
    if (!db) {
        console.error('Database not initialized.');
        return res.status(500).json({ message: 'Database not initialized.' });
    }

    try {
        const timeManagementCollection = db.collection('time_management');
        const timeManagementData = await timeManagementCollection.findOne({ child_id: new ObjectId(childId) });

        if (timeManagementData && timeManagementData.time_slots && timeManagementData.time_slots[slotIndex]) {
            timeManagementData.time_slots[slotIndex].is_allowed = is_allowed;

            await timeManagementCollection.updateOne(
                { child_id: new ObjectId(childId) },
                { $set: { time_slots: timeManagementData.time_slots } }
            );

            res.status(200).json({ message: 'Allowed status toggled successfully.' });
        } else {
            res.status(404).json({ message: 'Time slot not found.' });
        }
    } catch (error) {
        console.error('Error toggling allowed status:', error);
        res.status(500).json({ message: 'Error toggling allowed status.' });
    }
});

// PUT request to edit a time slot
router.put('/:childId/:slotIndex', async (req, res) => {
    const childId = req.params.childId;
    const slotIndex = parseInt(req.params.slotIndex);
    const { start_time, end_time } = req.body;

    console.log('Received PUT request to /time_management/:childId/:slotIndex for editing time slot');
    console.log('Child ID:', childId);
    console.log('Slot Index:', slotIndex);
    console.log('Start Time:', start_time);
    console.log('End Time:', end_time);

    const db = req.app.locals.db;
    if (!db) {
        console.error('Database not initialized.');
        return res.status(500).json({ message: 'Database not initialized.' });
    }

    try {
        const timeManagementCollection = db.collection('time_management');
        const timeManagementData = await timeManagementCollection.findOne({ child_id: new ObjectId(childId) });

        if (timeManagementData && timeManagementData.time_slots && timeManagementData.time_slots[slotIndex]) {
            // Calculate the new allowed_time based on start_time and end_time
            const allowedTimeInSeconds = calculateAllowedTime(start_time, end_time);

            // Update the time slot at the specific index
            timeManagementData.time_slots[slotIndex].start_time = start_time;
            timeManagementData.time_slots[slotIndex].end_time = end_time;
            timeManagementData.time_slots[slotIndex].allowed_time = allowedTimeInSeconds; // Update allowed_time

            await timeManagementCollection.updateOne(
                { child_id: new ObjectId(childId) },
                { $set: { time_slots: timeManagementData.time_slots } }
            );

            res.status(200).json({ message: 'Time slot updated successfully.' });
        } else {
            res.status(404).json({ message: 'Time slot not found.' });
        }
    } catch (error) {
        console.error('Error updating time slot:', error);
        res.status(500).json({ message: 'Error updating time slot.' });
    }
});

// DELETE request to delete a time slot
router.delete('/:childId/:slotIndex', async (req, res) => {
    const childId = req.params.childId;
    const slotIndex = parseInt(req.params.slotIndex);

    console.log('Received DELETE request to /time_management/:childId/:slotIndex for deleting time slot');
    console.log('Child ID:', childId);
    console.log('Slot Index:', slotIndex);

    const db = req.app.locals.db;
    if (!db) {
        console.error('Database not initialized.');
        return res.status(500).json({ message: 'Database not initialized.' });
    }

    try {
        const timeManagementCollection = db.collection('time_management');
        const timeManagementData = await timeManagementCollection.findOne({ child_id: new ObjectId(childId) });

        if (timeManagementData && timeManagementData.time_slots && timeManagementData.time_slots[slotIndex]) {
            timeManagementData.time_slots.splice(slotIndex, 1); // Remove the slot

            await timeManagementCollection.updateOne(
                { child_id: new ObjectId(childId) },
                { $set: { time_slots: timeManagementData.time_slots } }
            );

            res.status(200).json({ message: 'Time slot deleted successfully.' });
        } else {
            res.status(404).json({ message: 'Time slot not found.' });
        }
    } catch (error) {
        console.error('Error deleting time slot:', error);
        res.status(500).json({ message: 'Error deleting time slot.' });
    }
});

module.exports = router;

/*
const express = require('express');
const { ObjectId } = require('mongodb');
const router = express.Router();

// POST request to update or create time management data for a child
router.post('/:childId', async (req, res) => {
    const childId = req.params.childId;
    const { time_slots } = req.body;  // New time slot(s) being added

    const db = req.app.locals.db;
    if (!db) {
        return res.status(500).json({ message: 'Database not initialized.' });
    }

    try {
        const timeManagementCollection = db.collection('time_management');
        const existingTimeManagement = await timeManagementCollection.findOne({ child_id: new ObjectId(childId) });

        let updatedTimeSlots = time_slots;

        // Check if the document for the child exists, and merge the new time slots with the existing ones
        if (existingTimeManagement && existingTimeManagement.time_slots) {
            updatedTimeSlots = [...existingTimeManagement.time_slots, ...time_slots];
        }

        // Ensure allowed_time is included and in seconds
        updatedTimeSlots = updatedTimeSlots.map(slot => {
            slot.allowed_time = parseInt(slot.allowed_time, 10);  // Ensure allowed_time is in integer form
            return slot;
        });

        const updateResult = await timeManagementCollection.updateOne(
            { child_id: new ObjectId(childId) },
            { $set: { time_slots: updatedTimeSlots } },  // Update the time slots array
            { upsert: true }  // Create a new document if it doesn't exist
        );

        res.status(200).json({ message: 'Time slots updated successfully.' });
    } catch (error) {
        res.status(500).json({ message: 'Error saving time management data.' });
    }
});


// GET request to fetch time slots for a child
router.get('/:childId', async (req, res) => {
    const childId = req.params.childId;

    console.log('Received GET request to /time_management/:childId');
    console.log('Child ID:', childId);

    const db = req.app.locals.db;
    if (!db) {
        console.error('Database not initialized.');
        return res.status(500).json({ message: 'Database not initialized.' });
    }

    try {
        const timeManagementCollection = db.collection('time_management');
        const timeManagementData = await timeManagementCollection.findOne({ child_id: new ObjectId(childId) });

        if (timeManagementData) {
            res.status(200).json(timeManagementData.time_slots);
        } else {
            res.status(404).json({ message: 'No time management data found for this child.' });
        }
    } catch (error) {
        console.error('Error fetching time management data:', error);
        res.status(500).json({ message: 'Error fetching time management data.' });
    }
});

// PATCH request to toggle is_allowed status
router.patch('/:childId/:slotIndex', async (req, res) => {
    const childId = req.params.childId;
    const slotIndex = parseInt(req.params.slotIndex);
    const { is_allowed } = req.body;

    console.log('Received PATCH request to /time_management/:childId/:slotIndex for toggling status');
    console.log('Child ID:', childId);
    console.log('Slot Index:', slotIndex);
    console.log('Is Allowed:', is_allowed);

    const db = req.app.locals.db;
    if (!db) {
        console.error('Database not initialized.');
        return res.status(500).json({ message: 'Database not initialized.' });
    }

    try {
        const timeManagementCollection = db.collection('time_management');
        const timeManagementData = await timeManagementCollection.findOne({ child_id: new ObjectId(childId) });

        if (timeManagementData && timeManagementData.time_slots && timeManagementData.time_slots[slotIndex]) {
            timeManagementData.time_slots[slotIndex].is_allowed = is_allowed;

            await timeManagementCollection.updateOne(
                { child_id: new ObjectId(childId) },
                { $set: { time_slots: timeManagementData.time_slots } }
            );

            res.status(200).json({ message: 'Allowed status toggled successfully.' });
        } else {
            res.status(404).json({ message: 'Time slot not found.' });
        }
    } catch (error) {
        console.error('Error toggling allowed status:', error);
        res.status(500).json({ message: 'Error toggling allowed status.' });
    }
});

// PUT request to edit a time slot
router.put('/:childId/:slotIndex', async (req, res) => {
    const childId = req.params.childId;
    const slotIndex = parseInt(req.params.slotIndex);
    const { start_time, end_time } = req.body;

    console.log('Received PUT request to /time_management/:childId/:slotIndex for editing time slot');
    console.log('Child ID:', childId);
    console.log('Slot Index:', slotIndex);
    console.log('Start Time:', start_time);
    console.log('End Time:', end_time);

    const db = req.app.locals.db;
    if (!db) {
        console.error('Database not initialized.');
        return res.status(500).json({ message: 'Database not initialized.' });
    }

    try {
        const timeManagementCollection = db.collection('time_management');
        const timeManagementData = await timeManagementCollection.findOne({ child_id: new ObjectId(childId) });

        if (timeManagementData && timeManagementData.time_slots && timeManagementData.time_slots[slotIndex]) {
            // Update the time slot at the specific index
            timeManagementData.time_slots[slotIndex].start_time = start_time;
            timeManagementData.time_slots[slotIndex].end_time = end_time;

            await timeManagementCollection.updateOne(
                { child_id: new ObjectId(childId) },
                { $set: { time_slots: timeManagementData.time_slots } }
            );

            res.status(200).json({ message: 'Time slot updated successfully.' });
        } else {
            res.status(404).json({ message: 'Time slot not found.' });
        }
    } catch (error) {
        console.error('Error updating time slot:', error);
        res.status(500).json({ message: 'Error updating time slot.' });
    }
});


// DELETE request to delete a time slot
router.delete('/:childId/:slotIndex', async (req, res) => {
    const childId = req.params.childId;
    const slotIndex = parseInt(req.params.slotIndex);

    console.log('Received DELETE request to /time_management/:childId/:slotIndex for deleting time slot');
    console.log('Child ID:', childId);
    console.log('Slot Index:', slotIndex);

    const db = req.app.locals.db;
    if (!db) {
        console.error('Database not initialized.');
        return res.status(500).json({ message: 'Database not initialized.' });
    }

    try {
        const timeManagementCollection = db.collection('time_management');
        const timeManagementData = await timeManagementCollection.findOne({ child_id: new ObjectId(childId) });

        if (timeManagementData && timeManagementData.time_slots && timeManagementData.time_slots[slotIndex]) {
            timeManagementData.time_slots.splice(slotIndex, 1);

            await timeManagementCollection.updateOne(
                { child_id: new ObjectId(childId) },
                { $set: { time_slots: timeManagementData.time_slots } }
            );

            res.status(200).json({ message: 'Time slot deleted successfully.' });
        } else {
            res.status(404).json({ message: 'Time slot not found.' });
        }
    } catch (error) {
        console.error('Error deleting time slot:', error);
        res.status(500).json({ message: 'Error deleting time slot.' });
    }
});

module.exports = router;
*/
/*
const express = require('express');
const { ObjectId } = require('mongodb');
const router = express.Router();

// POST request to update or create time management data for a child
router.post('/:childId', async (req, res) => {
    const childId = req.params.childId;
    const { time_slots } = req.body;

    console.log('Received POST request to /time_management/:childId');
    console.log('Child ID:', childId);
    console.log('Time Slots:', time_slots);

    const db = req.app.locals.db;
    if (!db) {
        console.error('Database not initialized.');
        return res.status(500).json({ message: 'Database not initialized.' });
    }

    try {
        const timeManagementCollection = db.collection('time_management');
        
        // Enrich time slots with additional default data
        const enrichedTimeSlots = time_slots.map(slot => ({
            ...slot,
            slot_identifier: new ObjectId(),
            allowed_time: 3600,
            is_allowed: true
        }));

        const updateResult = await timeManagementCollection.updateOne(
            { child_id: new ObjectId(childId) },
            { $push: { time_slots: { $each: enrichedTimeSlots } } },
            { upsert: true }
        );

        if (updateResult.matchedCount === 0) {
            res.status(201).json({ message: 'New time management document created.', result: updateResult });
        } else {
            res.status(200).json({ message: 'Time slots updated successfully.', result: updateResult });
        }
    } catch (error) {
        console.error('Error saving time management data:', error);
        res.status(500).json({ message: 'Error saving time management data.' });
    }
});

// GET request to fetch time slots for a child
router.get('/:childId', async (req, res) => {
    const childId = req.params.childId;

    console.log('Received GET request to /time_management/:childId');
    console.log('Child ID:', childId);

    const db = req.app.locals.db;
    if (!db) {
        console.error('Database not initialized.');
        return res.status(500).json({ message: 'Database not initialized.' });
    }

    try {
        const timeManagementCollection = db.collection('time_management');

        // Find the time management document for the child
        const timeManagementData = await timeManagementCollection.findOne({ child_id: new ObjectId(childId) });

        if (timeManagementData) {
            res.status(200).json(timeManagementData.time_slots);  // Return only the time slots
        } else {
            res.status(404).json({ message: 'No time management data found for this child.' });
        }
    } catch (error) {
        console.error('Error fetching time management data:', error);
        res.status(500).json({ message: 'Error fetching time management data.' });
    }
});

module.exports = router;
*/