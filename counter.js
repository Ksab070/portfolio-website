async function incrementAndShowCount() {
  // Will change the url in prod 
  const apiUrl = "https://vhejrsn9y2.execute-api.us-east-1.amazonaws.com/api";

  try {
    const resp = await fetch(apiUrl, {
      method: "GET",
      headers: { "Content-Type": "application/json" }
    });

    if (!resp.ok) {
      console.error("API error", resp.status);
      return;
    }

    const data = await resp.json();
    const el = document.getElementById("viewCount");
    if (el) el.innerText = `Viewer Count : ${data.views ?? 0}`;
  } catch (err) {
    console.error("Network error", err);
  }
}

incrementAndShowCount();
