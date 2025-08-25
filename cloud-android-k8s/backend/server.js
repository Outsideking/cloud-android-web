const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const User = require('./models/User');
const { createAndroidPod, deleteAndroidPod } = require('./k8s');

const app = express();
app.use(cors());
app.use(express.json());

const SECRET = 'RufioSecretKey123';
mongoose.connect('mongodb://mongo:27017/cloudandroid');

const userPods = {}; // userId -> podName

app.post('/api/register', async (req,res)=>{
  const { username, password } = req.body;
  try {
    const user = new User({username,password});
    await user.save();
    res.json({message:'User created'});
  } catch(err){
    res.status(400).json({error:err.message});
  }
});

app.post('/api/login', async (req,res)=>{
  const { username,password } = req.body;
  const user = await User.findOne({username});
  if(!user) return res.status(400).json({error:'Invalid credentials'});
  const valid = await bcrypt.compare(password,user.password);
  if(!valid) return res.status(400).json({error:'Invalid credentials'});

  const podName = await createAndroidPod(user._id);
  userPods[user._id] = podName;

  const token = jwt.sign({id:user._id},SECRET,{expiresIn:'12h'});
  res.json({token,podName});
});

app.post('/api/logout', async (req,res)=>{
  const token = req.headers.authorization?.split(' ')[1];
  if(!token) return res.status(401).json({error:'No token'});
  const decoded = jwt.verify(token,SECRET);
  if(userPods[decoded.id]){
    await deleteAndroidPod(userPods[decoded.id]);
    delete userPods[decoded.id];
  }
  res.json({message:'Logged out'});
});

app.listen(5000,()=>console.log('Backend running on port 5000'));
