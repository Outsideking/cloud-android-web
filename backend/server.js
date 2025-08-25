const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const Docker = require('dockerode');
const User = require('./models/User');

const app = express();
app.use(cors());
app.use(express.json());

const docker = new Docker();
const SECRET = 'RufioSecretKey123';
const PORT_RANGE_START = 5902; // dynamic port start

mongoose.connect('mongodb://mongo:27017/cloudandroid');

let portCounter = PORT_RANGE_START;
const userContainers = {}; // userId → container info

// Register
app.post('/api/register', async (req, res) => {
  const { username, password } = req.body;
  try {
    const user = new User({ username, password });
    await user.save();
    res.json({ message: 'User created' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Login
app.post('/api/login', async (req, res) => {
  const { username, password } = req.body;
  const user = await User.findOne({ username });
  if (!user) return res.status(400).json({ error: 'Invalid credentials' });
  const valid = await bcrypt.compare(password, user.password);
  if (!valid) return res.status(400).json({ error: 'Invalid credentials' });

  // สร้าง Android Emulator container สำหรับ user
  const vncPort = portCounter++;
  const webPort = portCounter++;
  const container = await docker.createContainer({
    Image: 'cloud-android-image', // Dockerfile ของ Android Emulator
    ExposedPorts: {
      "5901/tcp": {},
      "6080/tcp": {}
    },
    HostConfig: {
      PortBindings: {
        "5901/tcp": [{ HostPort: `${vncPort}` }],
        "6080/tcp": [{ HostPort: `${webPort}` }]
      }
    }
  });
  await container.start();

  userContainers[user._id] = { containerId: container.id, vncPort, webPort };

  const token = jwt.sign({ id: user._id }, SECRET, { expiresIn: '12h' });
  res.json({ token, webPort });
});

// Logout / Stop container
app.post('/api/logout', async (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'No token' });
  const decoded = jwt.verify(token, SECRET);
  const info = userContainers[decoded.id];
  if (info) {
    const container = docker.getContainer(info.containerId);
    await container.stop();
    await container.remove();
    delete userContainers[decoded.id];
  }
  res.json({ message: 'Logged out' });
});

app.listen(5000, () => console.log('Backend running on port 5000'));
