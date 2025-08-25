import React, { useEffect, useRef } from 'react';
import RFB from 'novnc/core/rfb.js';

export default function AndroidScreen({ webPort }) {
  const vncRef = useRef(null);

  useEffect(() => {
    const rfb = new RFB(vncRef.current, `ws://localhost:${webPort}`);
    rfb.viewOnly = false;
    rfb.scaleViewport = true;

    return () => rfb.disconnect();
  }, [webPort]);

  return (
    <div>
      <h2>Your Cloud Android</h2>
      <div ref={vncRef} style={{ width: '1280px', height: '720px', border: '2px solid black' }}></div>
    </div>
  );
    }
