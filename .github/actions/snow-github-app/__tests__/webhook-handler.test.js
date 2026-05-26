// 🧒 7-year-old explanation:
// Tests the telephone operator that talks between GitHub and ServiceNow.

// 🎯 SME explanation:
// Integration tests for webhook callback handling and status updates.

const { handleSnowCallback } = require('../webhook-handler');

describe('Webhook Handler', () => {
  let mockReq;
  let mockRes;
  let mockOctokit;

  beforeEach(() => {
    mockReq = {
      body: {
        shared_secret: 'test-secret',
        approval_state: 'approved',
        repo_name: 'test-owner/test-repo',
        deployment_id: '123',
        commit_sha: 'abc123',
        pr_link: 'https://github.com/test/repo/pull/1'
      }
    };
    
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis()
    };
    
    mockOctokit = {
      rest: {
        repos: {
          createCommitStatus: jest.fn().mockResolvedValue({})
        }
      }
    };
  });

  test('should update commit status for approved decision', async () => {
    await handleSnowCallback(mockReq, mockRes, { snSharedSecret: 'test-secret' }, mockOctokit);
    
    expect(mockOctokit.rest.repos.createCommitStatus).toHaveBeenCalledWith({
      owner: 'test-owner',
      repo: 'test-repo',
      sha: 'abc123',
      state: 'success',
      context: 'snow-approval',
      description: 'Approved in ServiceNow before merge',
      target_url: 'https://github.com/test/repo/pull/1'
    });
    
    expect(mockRes.status).toHaveBeenCalledWith(200);
  });

  test('should reject invalid shared secret', async () => {
    await handleSnowCallback(mockReq, mockRes, { snSharedSecret: 'wrong-secret' }, mockOctokit);
    
    expect(mockRes.status).toHaveBeenCalledWith(401);
    expect(mockRes.json).toHaveBeenCalledWith({ error: 'Invalid shared secret' });
  });
});
