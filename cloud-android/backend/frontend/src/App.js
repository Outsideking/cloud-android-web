import React, { useState } from 'react';
import Login from './Login';
import AndroidScreen from './AndroidScreen';

function App() {
  const [loggedIn, setLoggedIn] = useState(false);

  return (
    <div className="App">
      {loggedIn ? <AndroidScreen /> : <Login onLogin={setLoggedIn} />}
    </div>
  );
}

export default App;
