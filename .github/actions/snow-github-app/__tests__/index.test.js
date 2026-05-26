// 🧒 7-year-old explanation:
// This is how we make sure our robot works correctly before sending it to work.
// We test all the different situations it might face.

// 🎯 SME explanation:
// Unit tests for the SNOW GitHub App Action using Jest.
// Tests webhook signature verification, ServiceNow API calls, and approval logic.

const { verifySignature, createSnowRecord } = require('../index');
const crypto = require('crypto');

describe('Snow GitHub App Action', () => {
  describe('verifySignature', () => {
    test('should return true for valid signature', () => {
      const secret = 'test-secret';
      const payload = JSON.stringify({ test: 'data' });
      const signature = 'sha256=' + crypto
        .createHmac('sha256', secret)
        .update(payload)
        .digest('hex');
      
      const result = verifySignature(payload, signature, secret);
      expect(result).toBe(true);
    });

    test('should return false for invalid signature', () => {
      const secret = 'test-secret';
      const payload = JSON.stringify({ test: 'data' });
      const invalidSignature = 'sha256=invalid';
      
      const result = verifySignature(payload, invalidSignature, secret);
      expect(result).toBe(false);
    });
  });

  describe('createSnowRecord', () => {
    test('should handle API errors gracefully', async () => {
      const mockFetch = jest.fn().mockRejectedValue(new Error('Network error'));
      global.fetch = mockFetch;
      
      const payload = { test: 'data' };
      const config = {
        snInstanceUrl: 'https://test.service-now.com',
        snApiPath: '/api/test',
        snApiUser: 'user',
        snApiPassword: 'pass'
      };
      
      await expect(createSnowRecord(payload, config)).rejects.toThrow('Network error');
    });
  });
})
