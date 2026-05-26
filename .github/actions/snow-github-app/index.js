// Add this at the end of your index.js file:

// Export functions for testing
if (process.env.NODE_ENV === 'test') {
  module.exports = {
    verifySignature,
    createSnowRecord,
    pollSnowApproval,
    run
  };
}

// Also add the verifySignature function if not already present:
function verifySignature(reqBody, signature, secret) {
  const hmac = crypto.createHmac('sha256', secret);
  const digest = 'sha256=' + hmac.update(reqBody).digest('hex');
  return crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(digest));
}

// Make sure createSnowRecord is also exported style function:
async function createSnowRecord(payload, config) {
  const url = `${config.snInstanceUrl}${config.snApiPath}`;
  const auth = Buffer.from(`${config.snApiUser}:${config.snApiPassword}`).toString('base64');
  
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${auth}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(payload)
  });
  
  if (!response.ok) {
    throw new Error(`SNOW API error: ${response.status}`);
  }
  
  return response.json();
}
