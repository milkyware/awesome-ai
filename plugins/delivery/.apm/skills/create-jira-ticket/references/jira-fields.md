# Jira project-specific fields

Use the Jira project's actual `labels` and `priority` fields where available; neither is necessarily required.

Discover `MoSCoW`, `T-shirt size`, story points, components and other custom fields from the selected project and issue type's create metadata. Match field IDs and options for the **selected project and issue type**, rather than reusing IDs from another Jira installation.

- If requested values such as `Must`, `Should`, `Could`, or `Won't` map to longer option labels, use only mappings confirmed by current Jira metadata or an explicit approved project convention. Do not assume `Won't` has a Jira value.
- **Do not automatically map MoSCoW to Jira Priority.** These convey different concepts. Apply a project-defined mapping only when the user requests it or an established convention is confirmed.
- Obtain T-shirt size definitions from the project or user; do not assume universal day/week ranges.
- If an explicitly requested field is unavailable, explain the mismatch and ask whether to proceed without it. Never silently drop user-requested metadata.
