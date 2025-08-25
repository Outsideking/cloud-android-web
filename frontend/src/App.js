import React, { useEffect, useState } from "react";
import { getCloudAndroidURL } from "./ecsStatus";

function App() {
  const [url, setUrl] = useState(null);

  useEffect(() => {
    async function fetchURL() {
      const ecsUrl = await getCloudAndroidURL();
      setUrl(ecsUrl);
    }
    fetchURL();
  }, []);

  return (
    <div style={{ textAlign: "center", marginTop: "50px" }}>
      <h1>Cloud Android Web</h1>
      {!url ? (
        <p>Loading ECS container status...</p>
      ) : (
        <>
          <p>Click below to open Android Emulator</p>
          <a href={url} target="_blank" rel="noopener noreferrer">
            <button style={{ padding: "10px 20px", fontSize: "16px" }}>
              Open Emulator
            </button>
          </a>
        </>
      )}
    </div>
  );
}

export default App;
