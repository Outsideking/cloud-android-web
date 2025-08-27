const express = require("express");
const router = express.Router();
const crypto = require("crypto");

router.post("/", async (req, res) => {
  try {
    const body = req.body;

    console.log("📩 PayPal Webhook:", body);

    // ตรวจสอบลายเซ็น PayPal
    const transmissionId = req.header("Paypal-Transmission-Id");
    const transmissionSig = req.header("Paypal-Transmission-Sig");
    const certUrl = req.header("Paypal-Cert-Url");
    const authAlgo = req.header("Paypal-Auth-Algo");

    if (!transmissionId || !transmissionSig) {
      return res.status(400).send("Invalid PayPal headers");
    }

    // TODO: call PayPal API verify-webhook-signature
    // https://developer.paypal.com/docs/api/webhooks/#verify-webhook-signature_post

    res.status(200).send("✅ PayPal Webhook received");
  } catch (err) {
    console.error("❌ PayPal webhook error:", err);
    res.status(500).send("Server error");
  }
});

module.exports = router;
