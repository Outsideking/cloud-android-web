import React, { useState } from 'react';
import Login from './Login';
import AndroidScreen from './AndroidScreen';

function App(){
  const [podName,setPodName] = useState(null);
  return podName ? <AndroidScreen podName={podName}/> : <Login onLogin={setPodName}/>;
}

export default App;

