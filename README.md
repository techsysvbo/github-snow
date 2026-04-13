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


#############################################################
