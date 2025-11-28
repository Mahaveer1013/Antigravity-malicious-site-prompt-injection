const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware to parse JSON bodies
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files from public directory
app.use(express.static('public'));

// Route to serve HTML file on root path
app.get('/', (req, res) => {
    const filePath = path.join(__dirname, 'public', 'index.html');
    
    fs.readFile(filePath, 'utf8', (err, data) => {
        if (err) {
            console.error('Error reading HTML file:', err);
            return res.status(500).send('Error loading page');
        }
        res.send(data);
    });
});

// Route to handle GET requests for data
app.get('/data', (req, res) => {
    console.log('GET /data - Query parameters:', req.query);
    console.log('GET /data - Headers:', req.headers);
    
    // Sample response data
    const responseData = {
        message: 'Data received via GET',
        timestamp: new Date().toISOString(),
        queryParams: req.query,
        method: 'GET'
    };
    
    console.log('Sending response:', responseData);
    res.json(responseData);
});

// Route to handle POST requests for data
app.post('/data', (req, res) => {
    console.log('POST /data - Request body:', req.body);
    console.log('POST /data - Headers:', req.headers);
    
    // Sample response data
    const responseData = {
        message: 'Data received via POST',
        timestamp: new Date().toISOString(),
        receivedData: req.body,
        method: 'POST'
    };
    
    console.log('Sending response:', responseData);
    res.json(responseData);
});

// Route to handle PUT requests for data
app.put('/data', (req, res) => {
    console.log('PUT /data - Request body:', req.body);
    console.log('PUT /data - Headers:', req.headers);
    
    const responseData = {
        message: 'Data received via PUT',
        timestamp: new Date().toISOString(),
        receivedData: req.body,
        method: 'PUT'
    };
    
    console.log('Sending response:', responseData);
    res.json(responseData);
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
    console.log(`- Visit http://localhost:${PORT} for the HTML page`);
    console.log(`- Test data endpoints at http://localhost:${PORT}/data`);
});

// Handle graceful shutdown
process.on('SIGINT', () => {
    console.log('\nServer shutting down...');
    process.exit(0);
});
