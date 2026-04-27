const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 8080;
const ENV = process.env.APP_ENVIRONMENT || 'dev';

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.get('/', (req, res) => {
  const html = require('fs').readFileSync(path.join(__dirname, 'public', 'index.html'), 'utf8');
  res.send(html.replace('__ENV__', ENV));
});

app.use(express.static(path.join(__dirname, 'public')));

app.listen(PORT, () => {
  console.log(`MK Market running on port ${PORT} [${ENV}]`);
});