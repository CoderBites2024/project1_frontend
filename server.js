const express = require('express');
const fs = require('fs');
const path = require('path');
const cors = require('cors');

const app = express();
const PORT = 3000;
const DB_FILE = path.join(__dirname, 'db.json');

// Middleware to parse JSON requests
app.use(express.json());

//CORS
app.use(cors());

// Helper function to read the database file
const readDB = () => {
  try {
    const data = fs.readFileSync(DB_FILE, 'utf8');
    return JSON.parse(data);
  } catch (err) {
    return [];
  }
};

// Helper function to write to the database file
const writeDB = (data) => {
  fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2));
};


// CRUD APIs

// Get all records
app.get('/api/users', (req, res) => {
  const data = readDB();
  res.json(data);
});

// Get a record by ID
app.get('/api/users/:id', (req, res) => {
  const { id } = req.params;
  const data = readDB();
  const user = data.find((item) => item.id === parseInt(id, 10));
  if (user) {
    res.json(user);
  } else {
    res.status(404).json({ message: 'User not found' });
  }
});

// Create a new record
app.post('/api/users', (req, res) => {
  const { name, email, sent_emails, activity_state } = req.body;

  if (!name || !email || !sent_emails || activity_state === undefined) {
    return res.status(400).json({ message: 'Missing required fields' });
  }

  const data = readDB();
  const newUser = {
    id: data.length ? data[data.length - 1].id + 1 : 1,
    name,
    email,
    sent_emails,
    activiti_time: new Date().toISOString(),
    activity_state,
  };

  data.push(newUser);
  writeDB(data);
  res.status(201).json(newUser);
});

// Update a record by ID
app.put('/api/users/:id', (req, res) => {
  const { id } = req.params;
  const { name, email, sent_emails, activity_state } = req.body;
  const data = readDB();
  const userIndex = data.findIndex((item) => item.id === parseInt(id, 10));

  if (userIndex === -1) {
    return res.status(404).json({ message: 'User not found' });
  }

  const updatedUser = {
    ...data[userIndex],
    name: name || data[userIndex].name,
    email: email || data[userIndex].email,
    sent_emails: sent_emails || data[userIndex].sent_emails,
    activity_state: activity_state !== undefined ? activity_state : data[userIndex].activity_state,
  };

  data[userIndex] = updatedUser;
  writeDB(data);
  res.json(updatedUser);
});

// Delete a record by ID
app.delete('/api/users/:id', (req, res) => {
  const { id } = req.params;
  const data = readDB();
  const filteredData = data.filter((item) => item.id !== parseInt(id, 10));

  if (data.length === filteredData.length) {
    return res.status(404).json({ message: 'User not found' });
  }

  writeDB(filteredData);
  res.status(204).send();
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
