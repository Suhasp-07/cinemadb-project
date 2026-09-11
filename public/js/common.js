// Fetches an API endpoint and renders it as a table inside the given container.
async function loadTable(url, wrapId, countId){
  const wrap = document.getElementById(wrapId);
  const countEl = countId ? document.getElementById(countId) : null;
  wrap.innerHTML = `<div class="state-msg">Loading…</div>`;
  try{
    const res = await fetch(url);
    if (!res.ok) throw new Error("Server responded with " + res.status);
    const data = await res.json();
    if (countEl) countEl.textContent = Array.isArray(data) ? `${data.length} record${data.length === 1 ? "" : "s"}` : "";
    renderTable(wrapId, data);
  }catch(err){
    wrap.innerHTML = `<div class="state-msg error">Couldn't load this data. Is the server running? (${err.message})</div>`;
  }
}

function renderTable(wrapId, rows){
  const wrap = document.getElementById(wrapId);
  if (!Array.isArray(rows) || rows.length === 0){
    wrap.innerHTML = `<div class="state-msg">No records found.</div>`;
    return;
  }
  const cols = Object.keys(rows[0]);
  const thead = `<thead><tr>${cols.map(c => `<th>${c.replace(/_/g," ")}</th>`).join("")}</tr></thead>`;
  const tbody = `<tbody>${rows.map((r, i) =>
    `<tr style="--row-i:${Math.min(i, 20)}">${cols.map(c => `<td>${r[c] === null || r[c] === undefined ? "—" : r[c]}</td>`).join("")}</tr>`
  ).join("")}</tbody>`;
  wrap.innerHTML = `<table>${thead}${tbody}</table>`;
}

// Wires up a simple JSON POST form: reads every input inside the form by its
// id (minus a prefix), sends it as JSON, shows success/error, resets, reloads
// the table above it. Use for plain (non-file) add-data forms.
function wireJsonForm({ formId, endpoint, feedbackId, fieldMap, reload }) {
  const form = document.getElementById(formId);
  const feedback = document.getElementById(feedbackId);

  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    feedback.className = "form-feedback full";
    feedback.textContent = "Submitting…";

    const payload = {};
    for (const [key, inputId] of Object.entries(fieldMap)) {
      const el = document.getElementById(inputId);
      let val = el.value;
      if (val === "") continue; // skip empty optional fields
      if (el.type === "number") val = Number(val);
      payload[key] = val;
    }

    try {
      const res = await fetch(endpoint, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload)
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || "Failed to save");

      feedback.textContent = data.message || "Added successfully!";
      feedback.className = "form-feedback full ok";
      form.reset();
      if (reload) reload();
    } catch (err) {
      feedback.textContent = err.message;
      feedback.className = "form-feedback full error";
    }
  });
}
