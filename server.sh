#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo "----------------------------------------------------"
echo "  Automated Node.js Server Setup & Dev Launch"
echo "  (Frontend in root, server/server.js in 'server' folder)"
echo "----------------------------------------------------"

# --- Create Frontend Files in Current Directory (if they don't exist) ---
echo "Ensuring basic frontend files (index.html, style.css, script.js) exist..."

# Create index.html if it doesn't exist
if [ ! -f "index.html" ]; then
    cat <<EOL > index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Auto-Refreshing Web App</title>
    <link rel="stylesheet" href="/style.css">
</head>
<body>
    <h1>Hello from Node.js (Auto-Refreshing)!</h1>
    <p>This page is served from your current directory, powered by Express and Nodemon.</p>
    <button id="myButton">Click Me</button>
    <script src="/script.js"></script>
</body>
</html>
EOL
fi

# Create style.css if it doesn't exist
if [ ! -f "style.css" ]; then
    cat <<EOL > style.css
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #e6f2ff;
    color: #333;
    text-align: center;
    padding-top: 50px;
}
h1 {
    color: #0056b3;
}
button {
    padding: 10px 20px;
    background-color: #007bff;
    color: white;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    font-size: 1rem;
    margin-top: 20px;
}
button:hover {
    background-color: #004d99;
}
EOL
fi

# Create script.js if it doesn't exist
if [ ! -f "script.js" ]; then
    cat <<EOL > script.js
document.addEventListener('DOMContentLoaded', () => {
    const button = document.getElementById('myButton');
    if (button) {
        button.addEventListener('click', () => {
            alert('JavaScript is running!');
        });
    }
});
EOL
fi

# --- Create and Setup Server Directory ---
echo "Creating and setting up the 'server/' directory..."
mkdir -p server
cd server

# Create server/server.js
echo "Creating server/server.js..."
cat <<EOL > server.js
const express = require('express');
const path = require('path');
const app = express();
const port = 3000;

// Determine the absolute path to the directory where static files are located.
// __dirname is the current directory of this server.js file (e.g., '/your-project/server')
// path.join(__dirname, '..') moves up one level to the parent directory ('/your-project')
const staticFilesPath = path.join(__dirname, '..');

// Serve static files from the parent directory
app.use(express.static(staticFilesPath));

// Optional: Serve the index.html specifically for the root URL
app.get('/', (req, res) => {
  res.sendFile(path.join(staticFilesPath, 'index.html'));
});

// Start the server
app.listen(port, () => {
  console.log(\`Server listening at http://localhost:\${port}\`);
  console.log(\`Serving static files from: \${staticFilesPath}\`);
});
EOL

# Initialize npm and install Express & Nodemon
echo "Initializing npm project in server/..."
npm init -y

echo "Installing Express.js and Nodemon..."
npm install express nodemon

# --- Configure package.json for Nodemon ---
echo "Configuring package.json with 'start-dev' script..."
# Use jq to safely add or update the start-dev script
if command -v jq &> /dev/null
then
    jq '.scripts["start-dev"] = "nodemon server.js"' package.json > temp.json && mv temp.json package.json
else
    # Fallback for systems without jq (less robust)
    sed -i '' -e '/"test": "echo \\"Error: no test specified\\" && exit 1"/a\
    "start-dev": "nodemon server.js",' package.json
    echo "Warning: 'jq' not found. Manually verify 'start-dev' script in package.json if it seems incorrect."
fi


# --- Start Server with Nodemon ---
echo "Starting Node.js server with Nodemon for automatic refreshes..."
echo "----------------------------------------------------"
echo "  Server is now running and will auto-refresh on file changes!"
echo "  Open your web browser and navigate to: http://localhost:3000/"
echo "----------------------------------------------------"
npm run start-dev
