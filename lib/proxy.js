const express = require('express');
const fetch = require('node-fetch');
const app = express();
const port = 3000;

const jiraToken = 'Basic TU_TOKEN_BASE64'; // Usa el token que generaste

app.get('/jira-projects', async (req, res) => {
  try {
    const response = await fetch('https://jiraupn.atlassian.net/rest/api/2/project', {
      headers: {
        'Authorization': jiraToken,
        'Accept': 'application/json',
      },
    });
    const data = await response.json();
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: 'Error al conectarse a Jira', details: err.toString() });
  }
});

app.listen(port, () => {
  console.log(`Servidor proxy en http://localhost:${port}`);
});
