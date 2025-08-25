import React, { useState } from 'react';
import axios from 'axios';

export default function Login({ onLogin }) {
  const [username,setUsername] = useState('');
  const [password,setPassword] = useState('');

  const handleLogin = async () => {
    const res = await axios.post('http://localhost:5000/api/login',{username,password});
    localStorage.setItem('token',res.data.token);
    onLogin(res.data.podName);
  };

  return (
    <div>
      <h2>Login</h2>
      <input placeholder="Username" onChange={e=>setUsername(e.target.value)}/>
      <input type="password" placeholder="Password" onChange={e=>setPassword(e.target.value)}/>
      <button onClick={handleLogin}>Login</button>
    </div>
  );
}

frontend/src/AndroidScreen.js

import React, { useEffect, useRef } from 'react';
import RFB from 'novnc/core/rfb.js';

export default function AndroidScreen({ podName }) {
  const vncRef = useRef(null);

  useEffect(()=>{
    const rfb = new RFB(vncRef.current, `wss://${podName}.example.com:6080`);
    rfb.viewOnly = false;
    rfb.scaleViewport = true;
    return ()=>rfb.disconnect();
  },[podName]);

  return <div ref={vncRef} style={{width:'1280px',height:'720px',border:'2px solid black'}} />;
    }
