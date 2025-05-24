#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo "----------------------------------------------------"
echo "  Automated Node.js Server Setup & Dev Launch"
echo "  (Frontend in root, server/server.js in 'server' folder)"
echo "----------------------------------------------------"

# --- Create Frontend Files in Project Root (if they don't exist) ---
echo "Ensuring basic frontend files (index.html, style.css, script.js) exist in the project root..."

# Create index.html if it doesn't exist
# Check and create in the current directory (assuming script is run from project root)
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
# Check and create in the current directory (assuming script is run from project root)
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
# Check and create in the current directory (assuming script is run from project root)
if [ ! -f "script.js" ]; then
    cat <<EOL > script.js
document.addEventListener('DOMContentLoaded', () => {
    const button = document.getElementById('myButton');
    if (button) {
        button.addEventListener('click', () => {
            // Using console.log instead of alert for better development experience
            console.log('JavaScript is running and button was clicked!');
        });
    }
});
EOL
fi

# --- Create and Setup Server Directory ---
echo "Creating and setting up the 'server/' directory..."
# This assumes you are running the script from your project's root folder.
mkdir -p server
cd server

# Create server/server.js with Browser-Sync integration
echo "Creating server/server.js with Browser-Sync integration..."
cat <<EOL > server.js
const express = require('express');
const path = require('path');
const app = express();
const port = 3000;

// Import Browser-Sync for live reloading
const browserSync = require('browser-sync');

// Determine the absolute path to the directory where static files are located.
// __dirname is the current directory of this server.js file (e.g., '/your-project/server')
// path.join(__dirname, '..') moves up one level to the parent directory ('/your-project')
const staticFilesPath = path.join(__dirname, '..');
console.log('Serving static files from:', staticFilesPath); // Added for debugging

// Initialize Browser-Sync AFTER your Express app is configured
// This will proxy requests to your Express app and watch for file changes
browserSync.init({
    proxy: \`http://localhost:\${port}\`, // Proxy your Express app
    files: [
        path.join(staticFilesPath, '**/*.html'), // Watch HTML files in the parent directory and its subfolders
        path.join(staticFilesPath, '**/*.css'),  // Watch CSS files
        path.join(staticFilesPath, '**/*.js')   // Watch JS files
    ],
    port: 3001, // Browser-Sync UI will run on this port (optional, can be same as proxy if not using UI)
    open: false // Set to true to automatically open browser on start
});

// Serve static files from the parent directory
app.use(express.static(staticFilesPath));

// Optional: Serve the index.html specifically for the root URL
app.get('/', (req, res) => {
  res.sendFile(path.join(staticFilesPath, 'index.html'));
});

// Start the Express server
app.listen(port, () => {
  console.log(\`Express server listening at http://localhost:\${port}\`);
  console.log(\`Serving static files from: \${staticFilesPath}\`);
  console.log(\`Browser-Sync UI available at http://localhost:3001 (if 'open' is false, visit manually)\`);
});
EOL

# Initialize npm and install Express, Nodemon, and Browser-Sync
echo "Initializing npm project in server/..."
npm init -y

echo "Installing Express.js, Nodemon, and Browser-Sync..."
npm install express nodemon browser-sync --save-dev

# --- Configure package.json for Nodemon ---
echo "Configuring package.json with 'start-dev' script..."
# Use jq to safely add or update the start-dev script
if command -v jq &> /dev/null
then
    jq '.scripts["start-dev"] = "nodemon server.js"' package.json > temp.json && mv temp.json package.json
else
    # Fallback for systems without jq (less robust)
    echo "jq not found. Attempting to manually add start-dev script. Please verify package.json."
    # Read package.json, add script, write back.
    # This is a simplified approach and might not handle all edge cases.
    PKG_JSON_CONTENT=$(cat package.json)
    if [[ ! "$PKG_JSON_CONTENT" =~ \"start-dev\": ]]; then
        # If start-dev doesn't exist, add it.
        NEW_PKG_JSON_CONTENT=$(echo "$PKG_JSON_CONTENT" | sed -E 's/("scripts": \{[^}]*\})/\1,\n    "start-dev": "nodemon server.js"/')
        echo "$NEW_PKG_JSON_CONTENT" > package.json
    else
        # If start-dev exists, update it.
        NEW_PKG_JSON_CONTENT=$(echo "$PKG_JSON_CONTENT" | sed -E 's/("start-dev":\s*)"[^"]*"/\1"nodemon server.js"/')
        echo "$NEW_PKG_JSON_CONTENT" > package.json
    fi
fi


# --- Start Server with Nodemon ---
echo "Starting Node.js server with Nodemon for automatic refreshes..."
echo "----------------------------------------------------"
echo "  Server is now running and will auto-refresh on file changes!"
echo "  Open your web browser and navigate to: http://localhost:3000/"
echo "----------------------------------------------------"
npm run start-dev
