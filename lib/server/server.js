// filename: server.js
require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');
const cors = require('cors');
const { MongoClient, ObjectId } = require('mongodb');
const morgan = require('morgan');

const app = express();
const port = process.env.PORT || 3448;

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
    
    // Log the request body
    console.log('Received signup request:', { email, username, password, confirmPassword });
  
    if (!email || !username || !password || !confirmPassword) {
      return res.status(400).json({ message: 'Missing fields' });
    }
  
    if (password !== confirmPassword) {
      return res.status(400).json({ message: 'Passwords do not match' });
    }
  
    try {
      const userCollection = db.collection('parent_registration');
      
      // Additional logs for debugging
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
    
    // Log the login request
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
  
    // Keep the log for receiving the request (if you want)
    console.log('Received add-child request:', {
      parentId,
      childId, // Changed from childRegistrationId to childId
      name,
      avatar,
      deviceName,
      macAddress
    });
  
    if (!parentId || !childId || !name || !avatar || !deviceName || !macAddress) {
      return res.status(400).json({ message: 'Missing fields' });
    }
  
    try {
      const isObjectIdValid = ObjectId.isValid(childId);
  
      // Inserting child data with changed field name
      await db.collection('child_profile').insertOne({
        parent_id: new ObjectId(parentId),
        child_id: isObjectIdValid ? new ObjectId(childId) : childId, // Changed from child_registration_id to child_id
        name,
        avatar,
        device_name: deviceName,
        mac_address: macAddress,
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
    const { parentId } = req.params;

    try {
      const children = await db.collection('child_profile').find({ parent_id: new ObjectId(parentId) }).toArray();

      if (children.length === 0) {
        return res.status(404).json({ message: 'No children found' });
      }

      res.status(200).json(children);
    } catch (error) {
      res.status(500).json({ message: 'Internal server error' });
    }
  });


  const { ObjectId } = require('mongodb');
  
  app.get('/theme/:adminId', async (req, res) => {
    try {
      // Extract adminId from the request parameters
      const { adminId } = req.params;
      
      // Log for debugging purposes
      console.log(`Received request for theme with adminId: ${adminId}`);
      
      // Query MongoDB, ensuring adminId is treated as ObjectId if necessary
      const themeData = await db.collection('theme_management').findOne({
        admin_id: new ObjectId(adminId) // Replace with just `admin_id: adminId` if it's a string in MongoDB
      });
      
      // Handle case where no theme data is found
      if (!themeData) {
        console.log('Theme not found for adminId:', adminId);
        return res.status(404).json({ message: 'Theme not found' });
      }
  
      // Log the themeData for debugging purposes
      console.log('Theme data found:', themeData);
  
      // Send the theme data as a response
      res.status(200).json(themeData);
    } catch (error) {
      // Handle errors and log them
      console.error('Error fetching theme:', error.message);
      res.status(500).json({ message: 'Internal server error' });
    }
  });
  
  // Start the server
  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });
});