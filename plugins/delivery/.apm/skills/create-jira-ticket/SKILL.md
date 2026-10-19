---
name: create-jira-ticket
description: Create Jira issues from structured or free-form engineering requests using the Atlassian MCP integration. Use when asked to create a Jira Story, Bug, Task, Epic, Spike or Sub-task, or to turn requirements into a delivery-ready ticket with testable acceptance criteria.
---

# Create Jira Ticket

Create a Jira issue that can be understood and delivered without the original conversation. Write in UK English; be precise, concise and engineering-focused.

## Prerequisites and boundaries

- Require a working Atlassian MCP integration with permission to inspect Jira metadata and create issues. The canonical server is `https://mcp.atlassian.com/v1/mcp`. Discover the available tools in the current session; do not assume a particular tool name exists.
- If Jira access is unavailable, do not pretend to create an issue. Explain the limitation and, if useful, provide a draft the user can submit manually.
- Apply this skill to **new issues** only. Use a separate update workflow for existing issues.
- Never claim an issue was created until the Jira create operation succeeds.

## 1. Establish the target

Use details already stated in the request and conversation. Resolve, in order:

1. **Project**: accept a project key or unambiguous project name. If not provided, ask; use a previously established project only when context makes the choice unambiguous. Do not hard-code a project.
2. **Issue type**: honour an explicit choice. Otherwise infer from intent (Bug = defect, Spike = time-boxed investigation, Epic = larger body of work, Sub-task = child work, Story = user-facing capability, Task = other delivery work). If ambiguous, suggest `Story` and ask for confirmation when it matters.
3. **Summary and scope**: infer a specific, action-led title and content from the request. Ask for essential missing context rather than fabricating it.
4. **Parent**: ask up front whether the issue should be linked to a parent (Epic or other parent-capable type), regardless of issue type. Set a parent only when the user requests one or has established a project-specific default, and only when the selected issue type supports it. Sub-tasks normally require one. Do not assume every issue type supports a parent.
5. **Assignee**: honour the user's instruction; otherwise leave unassigned or allow Jira's configured default. Do not assume the requester is the current authenticated Jira user.
6. **Optional metadata** (labels, priority, estimate, MoSCoW and other fields): apply explicitly requested values and valid established defaults. Do not assume any custom fields exist.

If a default has been proposed but not approved, ask the user to confirm it before creation. Do not repeatedly reconfirm defaults the user has already accepted. Ask for missing required metadata together when a structured question tool is available; otherwise use a concise conversational question. Avoid collecting nonessential metadata merely because a previous project used it.

## 2. Discover and validate Jira metadata

Use the available Atlassian MCP tools from `https://mcp.atlassian.com/v1/mcp`, or their equivalents, as needed:

1. Resolve the Jira cloud/site if not known.
2. Find/validate the target project.
3. Inspect the project's issue types.
4. Inspect the selected type's create metadata and required fields. Confirm names, identifiers, permitted values, field formats and parent constraints.
5. Resolve an assignee only when required.
6. Retrieve parent issue details when validation is needed (existence, project, type and compatibility).

Tool names vary by MCP server revision. Adapt to the signatures actually provided by the server. Do not invent field IDs, option values, Jira URLs, issue-type support or tool capabilities. If metadata cannot be verified, omit **optional** uncertain fields and tell the user; stop and ask if a **required** field cannot be resolved.

See [jira-fields.md](references/jira-fields.md) for project-specific field guidance (labels, priority, MoSCoW, T-shirt size, components).

## 3. Author the ticket

Prefer `should` for requirements; keep acceptance criteria independently verifiable and separate from implementation notes. Do not invent file paths, endpoint names, logging requirements, retries or other specifics. Retain links and engineering details supplied by the user.

Use the structure in [jira-description-template.md](references/jira-description-template.md), which defines the standard sections and the per-issue-type adaptations for Bug, Spike, Epic and Sub-task. Adapt rather than force sections that do not apply.

Omit empty sections unless the missing content must be clarified for delivery. Distinguish facts, proposed approaches and open questions. Ask focused follow-ups when required to make scope or acceptance criteria meaningful; otherwise proceed with the information available.

## 4. Confirm before writing

- Show a short preview of the summary, project, issue type, parent (if any), key acceptance criteria and any requested metadata when material details were inferred or remain uncertain.
- Ask for confirmation **once** before the write if the user has not already explicitly authorised creation using the final proposed details.
- A direct, sufficiently detailed request to create the issue counts as authorisation; avoid an unnecessary extra approval loop.

Do not create a duplicate after a timeout or ambiguous tool failure without checking whether the previous request succeeded.

## 5. Create the issue

Call the available Jira issue-creation tool with the verified project, issue type, summary and description.

- Supply `contentFormat: "markdown"` when supported and consistent with the connector contract; otherwise use the expected description representation.
- Include only validated required and requested optional fields. Use the tool's actual payload schema, including its approach to additional fields, parent, labels and assignee.
- Do not force `To Do` or any other status unless explicitly requested, allowed and supported by the workflow. Jira generally selects the initial workflow status.
- On validation errors, revisit create metadata and correct the relevant field; never guess an option ID.

## 6. Report the result

When creation succeeds, provide the **issue key** and **clickable Jira URL**, along with project, type, summary, parent if set and applied optional metadata. State any requested fields that were omitted or rejected. Construct the URL only from a verified Jira site base URL and the returned key, or use a URL returned by the tool.

If creation fails, explain the error and leave the user with the complete ticket draft; do not fabricate an issue key or URL.
