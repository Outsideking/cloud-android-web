export async function getCloudAndroidURL() {
  try {
    const response = await fetch("/api/ecs-status");
    const data = await response.json();
    return data.url;
  } catch (err) {
    console.error("Failed to fetch ECS info:", err);
    return null;
  }
}
