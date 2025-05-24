// server.js (inside the 'server' directory)
const express = require('express');
const path = require('path'); // Node.js built-in module
const app = express();
const port = 3000;

// Determine the absolute path to the directory where static files are located.
// __dirname is '/my-project/server'
// path.join(__dirname, '..') moves up one level to '/my-project'
const staticFilesPath = path.join(__dirname, '..');

// Serve static files from the parent directory
app.use(express.static(staticFilesPath));

// Optional: Serve the index.html specifically for the root URL
app.get('/', (req, res) => {
  res.sendFile(path.join(staticFilesPath, 'index.html'));
});

// Start the server
app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
  console.log(`Serving static files from: ${staticFilesPath}`);
});