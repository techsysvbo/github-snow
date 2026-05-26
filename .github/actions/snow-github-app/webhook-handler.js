// 🧒 7-year-old explanation:
// This is the telephone operator for our robot. It listens for calls from ServiceNow
// and passes messages back to GitHub about whether the code is approved or not.

// 🎯 SME explanation:
// This module handles incoming webhook callbacks from ServiceNow when approval decisions are made.
// It validates the shared secret, extracts approval state, and updates GitHub commit statuses.
// This provides real-time feedback without requiring polling.

const crypto = require('crypto');

async function handleSnowCallback(req, res, config, octokit) {
  try {
    const body = req.body;
    
    // Validate shared secret
    if (body.shared_secret !== config.snSharedSecret) {
      return res.status(401).json({ error: 'Invalid shared secret' });
    }
    
    const approvalState = body.approval_state;
    const repoName = body.repo_name;
    const [owner, repo] = repoName.split('/');
    const deploymentId = body.deployment_id;
    const commitSha = body.commit_sha || body.deployment_sha;
    const prUrl = body.pr_link || '';
    
    const state = approvalState === 'approved' ? 'success' : 'failure';
    const description = approvalState === 'approved' 
      ? 'Approved in ServiceNow before merge'
      : 'Rejected in ServiceNow; merge blocked';
    
    // Update commit status
    await octokit.rest.repos.createCommitStatus({
      owner,
      repo,
      sha: commitSha,
      state,
      context: 'snow-approval',
      description,
      target_url: prUrl
    });
    
    return res.status(200).json({
      result: 'GitHub snow-approval status updated',
      approval_state: approvalState
    });
    
  } catch (error) {
    console.error('Callback error:', error);
    return res.status(500).json({ error: error.message });
  }
}

module.exports = { handleSnowCallback };
