# github-snow
## Text JavaScript that worked for test
(function process(request, response) {

    var body = request.body.data || {};

    // Read secret from request header
    var incomingSecret = request.getHeader("x-github-shared-secret");

    // Read expected secret from System Property
    var expectedSecret = gs.getProperty("x_github.shared_secret", "");

    // Check secret
    if (!incomingSecret || incomingSecret != expectedSecret) {
        response.setStatus(401);
        response.setBody({
            result: {
                message: "Unauthorized"
            }
        });
        return;
    }

    // Read incoming data
    var prNumber = body.pr_number || "";
    var repoName = body.repo_name || "";
    var prUrl = body.pr_url || "";
    var sourceBranch = body.source_branch || "";
    var targetBranch = body.target_branch || "";

    // Create Incident (temporary for testing)
    var gr = new GlideRecord('incident');
    gr.initialize();
    gr.short_description = "GitHub PR #" + prNumber;
    gr.description =
        "Repo: " + repoName + "\n" +
        "PR URL: " + prUrl + "\n" +
        "Source: " + sourceBranch + "\n" +
        "Target: " + targetBranch;

    var sysId = gr.insert();

    // Response
    response.setStatus(200);
    response.setBody({
        result: {
            message: "PR received in ServiceNow",
            incident_sys_id: sysId
        }
    });

})(request, response);

##############################
Production-like JavaScript
################################
(function process(request, response) {

    var body = request.body.data || {};

    var incomingSecret = request.getHeader("x-github-shared-secret");
    var expectedSecret = gs.getProperty("x_github.shared_secret", "");

    if (!incomingSecret || incomingSecret !== expectedSecret) {
        response.setStatus(401);
        response.setBody({
            result: {
                message: "Unauthorized"
            }
        });
        return;
    }

    var prNumber = body.pr_number || "";
    var repoName = body.repo_name || "";
    var repoFullName = body.repo_full_name || "";
    var prTitle = body.pr_title || "";
    var prUrl = body.pr_url || "";
    var prAuthor = body.pr_author || "";
    var sourceBranch = body.source_branch || "";
    var targetBranch = body.target_branch || "";
    var commitSha = body.commit_sha || "";
    var environment = body.environment || "unknown";

    var gr = new GlideRecord('incident');
    gr.initialize();
    gr.short_description = "GitHub PR #" + prNumber + " - " + repoName;
    gr.description =
        "Repository: " + repoName + "\n" +
        "Repository Full Name: " + repoFullName + "\n" +
        "PR Title: " + prTitle + "\n" +
        "PR URL: " + prUrl + "\n" +
        "PR Author: " + prAuthor + "\n" +
        "Source Branch: " + sourceBranch + "\n" +
        "Target Branch: " + targetBranch + "\n" +
        "Commit SHA: " + commitSha + "\n" +
        "Environment: " + environment;

    var sysId = gr.insert();

    response.setStatus(200);
    response.setBody({
        result: {
            message: "PR received in ServiceNow",
            incident_sys_id: sysId
        }
    });

})(request, response);


############################################################# Never tested the above one. Use this one below instead
(function process(request, response) {

    var body = request.body.data || {};

    var incomingSecret = request.getHeader("x-github-shared-secret");
    var expectedSecret = gs.getProperty("x_github.shared_secret", "");

    if (!incomingSecret || incomingSecret !== expectedSecret) {
        response.setStatus(401);
        response.setBody({
            result: {
                message: "Unauthorized"
            }
        });
        return;
    }

    var prNumber = body.pr_number || "";
    var repoName = body.repo_name || "";
    var repoFullName = body.repo_full_name || "";
    var prTitle = body.pr_title || "";
    var prUrl = body.pr_url || "";
    var prAuthor = body.pr_author || "";
    var sourceBranch = body.source_branch || "";
    var targetBranch = body.target_branch || "";
    var commitSha = body.commit_sha || "";
    var environment = body.environment || "prod";
    var approvalGate = body.approval_gate || "pending_ccoe_and_security";
    var checksSummary = body.checks_summary || "";

    var gr = new GlideRecord('incident');
    gr.initialize();
    gr.short_description = "GitHub PR #" + prNumber + " - " + repoName;
    gr.description =
        "Repository: " + repoName + "\n" +
        "Repository Full Name: " + repoFullName + "\n" +
        "PR Title: " + prTitle + "\n" +
        "PR URL: " + prUrl + "\n" +
        "PR Author: " + prAuthor + "\n" +
        "Source Branch: " + sourceBranch + "\n" +
        "Target Branch: " + targetBranch + "\n" +
        "Commit SHA: " + commitSha + "\n" +
        "Environment: " + environment + "\n" +
        "Approval Gate: " + approvalGate + "\n" +
        "Checks Summary: " + checksSummary;

    var sysId = gr.insert();

    response.setStatus(200);
    response.setBody({
        result: {
            message: "PR received in ServiceNow",
            incident_sys_id: sysId
        }
    });

})(request, response);

########################################################
This testing mode will leave or delete depending Testing
#####################################################
name: Send Approved PR to ServiceNow

on:
  pull_request_review:
    types: [submitted]

permissions:
  contents: read
  pull-requests: write
  statuses: write

jobs:
  send-to-snow:
    if: >
      github.event.review.state == 'approved' &&
      github.event.pull_request.base.ref == 'main' &&
      github.event.pull_request.state == 'open'
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Get all PR reviews
        id: reviews
        uses: actions/github-script@v7
        with:
          script: |
            const pr = context.payload.pull_request;
            const { owner, repo } = context.repo;

            const reviews = await github.paginate(
              github.rest.pulls.listReviews,
              {
                owner,
                repo,
                pull_number: pr.number,
                per_page: 100
              }
            );

            const latestByUser = new Map();
            for (const r of reviews) {
              if (r.user && r.user.login) {
                latestByUser.set(r.user.login, r.state);
              }
            }

            const approvedUsers = [...latestByUser.entries()]
              .filter(([user, state]) => state === 'APPROVED')
              .map(([user]) => user);

            core.setOutput('approved_count', approvedUsers.length.toString());
            core.setOutput('approved_users', JSON.stringify(approvedUsers));

      - name: Stop if no approval found
        if: steps.reviews.outputs.approved_count == '0'
        run: |
          echo "No valid approval found."
          exit 1

      - name: Check if payload already sent
        id: labelcheck
        uses: actions/github-script@v7
        with:
          script: |
            const labels = context.payload.pull_request.labels.map(l => l.name);
            core.setOutput('already_sent', labels.includes('snow-payload-sent') ? 'true' : 'false');

      - name: Stop if already sent
        if: steps.labelcheck.outputs.already_sent == 'true'
        run: |
          echo "Payload already sent before."
          exit 0

      - name: Set commit status to pending
        uses: actions/github-script@v7
        with:
          script: |
            const pr = context.payload.pull_request;
            const { owner, repo } = context.repo;

            await github.rest.repos.createCommitStatus({
              owner,
              repo,
              sha: pr.head.sha,
              state: 'pending',
              context: 'servicenow/prod-approval',
              description: 'Waiting for ServiceNow approval',
              target_url: pr.html_url
            });

      - name: Build payload
        id: payload
        run: |
          cat > payload.json <<EOF
          {
            "pr_number": ${{ github.event.pull_request.number }},
            "pr_url": "${{ github.event.pull_request.html_url }}",
            "repo_name": "${{ github.event.repository.name }}",
            "repo_owner": "${{ github.repository_owner }}",
            "source_branch": "${{ github.event.pull_request.head.ref }}",
            "target_branch": "${{ github.event.pull_request.base.ref }}",
            "commit_sha": "${{ github.event.pull_request.head.sha }}",
            "pr_title": "${{ github.event.pull_request.title }}",
            "pr_author": "${{ github.event.pull_request.user.login }}",
            "pr_approvers": ${{ steps.reviews.outputs.approved_users }},
            "requested_at": "${{ github.event.review.submitted_at }}",
            "environment": "production",
            "external_correlation_id": "${{ github.event.repository.name }}-${{ github.event.pull_request.number }}-${{ github.event.pull_request.head.sha }}"
          }
          EOF

          cat payload.json

      - name: Send payload to ServiceNow
        env:
          SNOW_URL: ${{ secrets.SNOW_URL }}
          SNOW_USER: ${{ secrets.SNOW_USER }}
          SNOW_PASSWORD: ${{ secrets.SNOW_PASSWORD }}
        run: |
          curl -i -X POST "$SNOW_URL" \
            -u "$SNOW_USER:$SNOW_PASSWORD" \
            -H "Content-Type: application/json" \
            -d @payload.json

      - name: Add sent label
        uses: actions/github-script@v7
        with:
          script: |
            const { owner, repo } = context.repo;
            const issue_number = context.payload.pull_request.number;

            await github.rest.issues.addLabels({
              owner,
              repo,
              issue_number,
              labels: ['snow-payload-sent']
            });
