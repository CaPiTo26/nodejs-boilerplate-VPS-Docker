// Import required modules
const express = require('express');

// Initialize Express app
const app = express();

// Define the port
const PORT = process.env.PORT || 3000;

// Middleware to parse JSON requests
app.use(express.json());

// Define a simple route
app.get('/', (req, res) => {
    res.json({ message: "Hello from my Node.js! Test modification 9" });
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
