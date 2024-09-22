// filename: server.js (main node file)
require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');
const cors = require('cors');
const { MongoClient, ObjectId } = require('mongodb');
const morgan = require('morgan');

const settingsRoutes = require('./settings.js');
const timeManagementRoutes = require('./time_management');
const appManagementRoutes = require('./app_management');
const appTimeRoutes = require('./app_time');

const app = express();
const port = process.env.PORT || 15014;

// MongoDB connection URL
const uri = process.env.MONGODB_URI;
const dbName = process.env.DB_NAME;

// Initialize MongoDB client
const client = new MongoClient(uri);

// Connect to MongoDB
async function connectToDatabase() {
  try {
    await client.connect();
    console.log('Connected to MongoDB');
    const db = client.db(dbName);
    app.locals.db = db;  // Make the db instance globally accessible to all routes
  } catch (err) {
    console.error('Error connecting to MongoDB:', err.message);
    process.exit(1);
  }
}

// Middleware
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors());
app.use(morgan('dev'));

// Load routes
app.use('/api/settings', settingsRoutes);
app.use('/api/time_management', timeManagementRoutes);
app.use('/api/app_management', appManagementRoutes);
app.use('/api/app_time_management', appTimeRoutes);

// Start the server after connecting to MongoDB
connectToDatabase().then(() => {

  // Signup route
  app.post('/signup', async (req, res) => {
    const { email, username, password, confirmPassword } = req.body;
    const db = req.app.locals.db;  // Access the db from app.locals

    if (!email || !username || !password || !confirmPassword) {
      return res.status(400).json({ message: 'Missing fields' });
    }

    if (password !== confirmPassword) {
      return res.status(400).json({ message: 'Passwords do not match' });
    }

    try {
      const userCollection = db.collection('parent_registration');

      const emailExists = await userCollection.findOne({ email });
      if (emailExists) {
        return res.status(400).json({ message: 'Email already in use' });
      }

      const usernameExists = await userCollection.findOne({ username });
      if (usernameExists) {
        return res.status(400).json({ message: 'Username already in use' });
      }

      const hashedPassword = await bcrypt.hash(password, 10);
      await userCollection.insertOne({ email, username, password: hashedPassword });
      res.status(201).json({ message: 'User created successfully' });
    } catch (error) {
      console.error('Error during signup:', error.message);
      res.status(500).json({ message: 'Internal server error' });
    }
  });

  // Login route
  app.post('/login', async (req, res) => {
    const { username, password } = req.body;
    const db = req.app.locals.db;  // Access the db from app.locals

    if (!username || !password) {
      return res.status(400).json({ message: 'Missing fields' });
    }

    try {
      const userCollection = db.collection('parent_registration');
      const user = await userCollection.findOne({ username });

      if (!user) {
        return res.status(401).json({ message: 'Login failed: User not found' });
      }

      const isValid = await bcrypt.compare(password, user.password);
      if (!isValid) {
        return res.status(401).json({ message: 'Login failed: Invalid password' });
      }

      res.status(200).json({ message: 'Login successful', parentId: user._id });
    } catch (error) {
      console.error('Login error:', error.message);
      res.status(500).json({ message: 'Internal server error' });
    }
  });

  // Route to add/register a child
  app.post('/add-child', async (req, res) => {
    const { parentId, childId, name, avatar, deviceName, macAddress } = req.body;
    const db = req.app.locals.db;  // Access the db from app.locals
  
    if (!parentId || !childId || !name || !avatar || !deviceName || !macAddress) {
      return res.status(400).json({ message: 'Missing fields' });
    }
  
    if (!ObjectId.isValid(parentId)) {
      return res.status(400).json({ message: 'Invalid parentId format' });
    }
  
    try {
      await db.collection('child_profile').insertOne({
        parent_id: new ObjectId(parentId),
        childId: new ObjectId(childId),
        name,
        avatar,
        device_name: deviceName,
        mac_address: macAddress,
      });
  
      res.status(201).json({ message: 'Child profile created successfully' });
    } catch (err) {
      console.error('Error adding child:', err.message);
      res.status(500).json({ message: 'Internal server error' });
    }
  });

  // Route to retrieve children by parentId
  app.get('/get-children/:parentId', async (req, res) => {
    const db = req.app.locals.db;  // Access the db from app.locals
    const { parentId } = req.params;

    if (!ObjectId.isValid(parentId)) {
      return res.status(400).json({ message: 'Invalid parentId format' });
    }

    try {
      const children = await db.collection('child_profile').find({ parent_id: new ObjectId(parentId) }).toArray();
      if (children.length > 0) {
        res.status(200).json(children);
      } else {
        res.status(404).json({ message: 'No children found for this parent.' });
      }
    } catch (error) {
      console.error('Error fetching children:', error.message);
      res.status(500).json({ message: 'Internal server error' });
    }
  });

  // Theme management route
  app.get('/theme/:adminId', async (req, res) => {
    const db = req.app.locals.db;  // Access the db from app.locals
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
      console.error('Error fetching theme:', error.message);
      res.status(500).json({ message: 'Internal server error' });
    }
  });

  // Start the server
  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });
});

/*
require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');
const cors = require('cors');
const { MongoClient, ObjectId } = require('mongodb');
const morgan = require('morgan');

const app = express();
const port = process.env.PORT || 10156;

// MongoDB connection URL
const uri = process.env.MONGODB_URI;
const dbName = process.env.DB_NAME;

// Initialize MongoDB client
const client = new MongoClient(uri);
let db;

async function connectToDatabase() {
  try {
    await client.connect();
    console.log('Connected to MongoDB');
    db = client.db(dbName);
  } catch (err) {
    console.error('Error connecting to MongoDB:', err.message);
    process.exit(1);
  }
}

// Connect to the database before starting the server
connectToDatabase().then(() => {
  app.use(bodyParser.json());
  app.use(bodyParser.urlencoded({ extended: true }));
  app.use(cors());
  app.use(morgan('dev'));

  // Signup route
  app.post('/signup', async (req, res) => {
    const { email, username, password, confirmPassword } = req.body;

    console.log('Received signup request:', { email, username, password, confirmPassword });

    if (!email || !username || !password || !confirmPassword) {
      return res.status(400).json({ message: 'Missing fields' });
    }

    if (password !== confirmPassword) {
      return res.status(400).json({ message: 'Passwords do not match' });
    }

    try {
      const userCollection = db.collection('parent_registration');
      console.log('Checking if email exists:', email);

      const emailExists = await userCollection.findOne({ email });
      if (emailExists) {
        return res.status(400).json({ message: 'Email already in use' });
      }

      const usernameExists = await userCollection.findOne({ username });
      if (usernameExists) {
        return res.status(400).json({ message: 'Username already in use' });
      }

      const hashedPassword = await bcrypt.hash(password, 10);
      await userCollection.insertOne({ email, username, password: hashedPassword });
      console.log('User created successfully:', { email, username });

      res.status(201).json({ message: 'User created successfully' });
    } catch (error) {
      console.error('Error during signup:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  });

  // Login route
  app.post('/login', async (req, res) => {
    const { username, password } = req.body;

    console.log('Received login request:', { username, password });

    if (!username || !password) {
      return res.status(400).json({ message: 'Missing fields' });
    }

    try {
      const userCollection = db.collection('parent_registration');
      console.log('Searching for username:', username);

      const user = await userCollection.findOne({ username });
      if (!user) {
        return res.status(401).json({ message: 'Login failed' });
      }

      const isValid = await bcrypt.compare(password, user.password);
      if (!isValid) {
        return res.status(401).json({ message: 'Login failed' });
      }

      console.log('Login successful for user:', username);
      res.status(200).json({ message: 'Login successful', parentId: user._id });
    } catch (error) {
      console.error('Error during login:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  });

  // Route to add/register a child
  app.post('/add-child', async (req, res) => {
    const { parentId, childId, name, avatar, deviceName, macAddress } = req.body;

    console.log('Received add-child request:', {
      parentId,
      childId,
      name,
      avatar,
      deviceName,
      macAddress
    });

    if (!parentId || !childId || !name || !avatar || !deviceName || !macAddress) {
      return res.status(400).json({ message: 'Missing fields' });
    }

    try {
      await db.collection('child_profile').insertOne({
        parent_id: new ObjectId(parentId),
        child_id: childId,
        name,
        avatar,
        device_name: deviceName,
        mac_address: macAddress
      });

      console.log('Child profile added successfully');
      res.status(201).json({ message: 'Child profile created successfully' });
    } catch (err) {
      console.error('Error inserting child profile:', err.message);
      res.status(500).json({ message: 'Internal server error' });
    }
  });

  // Route to retrieve children by parentId
  app.get('/get-children/:parentId', async (req, res) => {
    try {
      const { parentId } = req.params;

      // Convert parentId to ObjectId to match MongoDB document
      const children = await db.collection('child_profile').find({ parent_id: new ObjectId(parentId) }).toArray();

      if (children.length > 0) {
        console.log('Children found:', children);
        return res.status(200).json(children);
      } else {
        console.log('No children found for parentId:', parentId);
        return res.status(404).json({ message: 'No children found for this parent.' });
      }
    } catch (error) {
      console.error('Error fetching children:', error);
      return res.status(500).json({ message: 'Server error' });
    }
  });

  // Theme management route
  app.get('/theme/:adminId', async (req, res) => {
    try {
      const { adminId } = req.params;

      console.log(`Received request for theme with adminId: ${adminId}`);

      const themeData = await db.collection('theme_management').findOne({
        admin_id: new ObjectId(adminId)
      });

      if (!themeData) {
        console.log('Theme not found for adminId:', adminId);
        return res.status(404).json({ message: 'Theme not found' });
      }

      console.log('Theme data found:', themeData);
      res.status(200).json(themeData);
    } catch (error) {
      console.error('Error fetching theme:', error.message);
      res.status(500).json({ message: 'Internal server error' });
    }
  });

  // Start the server
  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });
});
*/