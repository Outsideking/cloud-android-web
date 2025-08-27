const express = require("express");
const router = express.Router();
const crypto = require("crypto");

router.post("/", (req, res) => {
  try {
    const body = req.body;
    console.log("📩 Omise Webhook:", body);

    // ตรวจสอบ Signature (X-Omise-Signature)
    const signature = req.header("X-Omise-Signature");
    const payload = JSON.stringify(body);

    const expectedSig = crypto
      .createHmac("sha256", process.env.OPN_SECRET_KEY)
      .update(payload)
      .digest("hex");

    if (signature !== expectedSig) {
      return res.status(400).send("Invalid Omise signature");
    }

    res.status(200).send("✅ Omise Webhook received");
  } catch (err) {
    console.error("❌ Omise webhook error:", err);
    res.status(500).send("Server error");
  }
});

module.exports = router;
