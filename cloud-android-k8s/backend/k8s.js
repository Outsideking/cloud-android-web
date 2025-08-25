const { Client, config } = require('kubernetes-client');
const client = new Client({ config: config.fromKubeconfig(), version: '1.13' });

async function createAndroidPod(userId) {
  const podName = `android-${userId}`;
  const podManifest = {
    apiVersion: 'v1',
    kind: 'Pod',
    metadata: { name: podName, labels: { app: 'cloud-android', user: userId } },
    spec: {
      containers: [{
        name: 'android-emulator',
        image: 'cloud-android-image',
        ports: [{ containerPort: 5901 }, { containerPort: 6080 }]
      }]
    }
  };
  await client.api.v1.namespaces('default').pods.post({ body: podManifest });
  return podName;
}

async function deleteAndroidPod(podName){
  await client.api.v1.namespaces('default').pods(podName).delete();
}

module.exports = { createAndroidPod, deleteAndroidPod };
