const express = require("express");
const bodyParser = require("body-parser");
const paypalRoute = require("./routes/paypal");
const omiseRoute = require("./routes/omise");

const app = express();

// Middleware
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
app.use("/webhook/paypal", paypalRoute);
app.use("/webhook/omise", omiseRoute);

app.get("/", (req, res) => {
  res.send("Cloud-Android Web Backend Running ✅");
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Backend running on port ${PORT}`));
