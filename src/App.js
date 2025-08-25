import React, { useState } from 'react';
import Login from './Login';
import AndroidScreen from './AndroidScreen';

function App() {
  const [webPort, setWebPort] = useState(null);

  return (
    <div className="App">
      {webPort ? <AndroidScreen webPort={webPort} /> : <Login onLogin={setWebPort} />}
    </div>
  );
}

export default App;
