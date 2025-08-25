import React, { useEffect, useRef } from 'react';
import RFB from 'novnc/core/rfb.js';

export default function AndroidScreen() {
  const vncRef = useRef(null);

  useEffect(() => {
    const rfb = new RFB(vncRef.current, 'ws://localhost:6080');
    rfb.viewOnly = false;
    rfb.scaleViewport = true;

    return () => rfb.disconnect();
  }, []);

  return (
    <div>
      <h1>Cloud Android</h1>
      <div ref={vncRef} style={{ width: '1280px', height: '720px', border: '2px solid black' }}></div>
    </div>
  );
      }
