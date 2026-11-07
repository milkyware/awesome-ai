# GitHub type, size and priority labels

Apply exactly one label from each family to every issue, except `type:epic`, which
takes no size label. Values are single lowercase tokens so filters such as
`--label "type:story"` and `--label "size:m"` work unchanged.

## Canonical set

**Type** uses one hue family so the six labels scan as a group in a label list. Size
uses a blue scale and priority a red-to-grey scale, so the three families never look
alike.

| Label          | Colour   | Description                                                 |
| -------------- | -------- | ----------------------------------------------------------- |
| `type:epic`    | `3E1F79` | Body of work that must be split into sub-issues             |
| `type:feature` | `553098` | Capability delivered across several stories                 |
| `type:story`   | `6E40C9` | User story: one deliverable slice of user value             |
| `type:task`    | `8250DF` | Engineering work with no direct user-facing outcome         |
| `type:bug`     | `9867E8` | Defect in existing behaviour                                |
| `type:spike`   | `AF7BF2` | Time-boxed investigation; output is a decision              |
| `size:xs`      | `DDF4FF` | Isolated change within one function or file; no design work |
| `size:s`       | `A5D6FF` | Contained change in one component using an existing pattern |
| `size:m`       | `54AEFF` | Few components or a new pattern, with tests                 |
| `size:l`       | `0969DA` | Cross-cutting change, migration or new integration          |
| `size:xl`      | `0A3069` | Larger than one issue can deliver; split into sub-issues    |
| `priority:p0`  | `82071E` | Outage, data loss or unpatched security exposure            |
| `priority:p1`  | `CF222E` | Blocks current delivery or affects many users               |
| `priority:p2`  | `BF8700` | Planned work for the current cycle                          |
| `priority:p3`  | `6E7781` | Worth doing, not time-critical                              |
| `priority:p4`  | `D0D7DE` | Parked or speculative; no commitment to deliver             |

Interpretation notes:

- Priority is urgency and impact, not effort or sequence. Size is effort, not duration
  unless the repository defines its own mapping.
- `size:xl` means the issue must be split. `type:epic` means it is deliberately a
  container. They are different judgements and should rarely overlap.
- Colours are cosmetic. Names and descriptions are the contract.

## Reconcile before creating

Labels must exist before the issue is created, because GitHub rejects an issue that
references an unknown label. List the current labels first, using a limit high enough
to exceed the default of 30:

```bash
gh label list --repo <owner/repo> --json name,color,description --limit 200
```

Create only the labels this issue needs, then create the issue. Use the canonical name
matched exactly as it appears in the table above.

```bash
gh label create "type:story" --repo <owner/repo> --color "6E40C9" --description "User story: one deliverable slice of user value"
```

Never recreate or recolour an existing label without explicit approval, because
renaming a label breaks saved filters, links and historical queries. `--force` updates
an existing label in place; use it only when the user asks for a convention change.

## Provision the whole vocabulary

Offer this block when the user wants the complete set in a repository that has none of
these labels. Run it from the repository directory and drop the `--repo` placeholder.

```bash
gh label create "type:epic" --color "3E1F79" --description "Body of work that must be split into sub-issues"
gh label create "type:feature" --color "553098" --description "Capability delivered across several stories"
gh label create "type:story" --color "6E40C9" --description "User story: one deliverable slice of user value"
gh label create "type:task" --color "8250DF" --description "Engineering work with no direct user-facing outcome"
gh label create "type:bug" --color "9867E8" --description "Defect in existing behaviour"
gh label create "type:spike" --color "AF7BF2" --description "Time-boxed investigation; output is a decision"
gh label create "size:xs" --color "DDF4FF" --description "Isolated change within one function or file; no design work"
gh label create "size:s" --color "A5D6FF" --description "Contained change in one component using an existing pattern"
gh label create "size:m" --color "54AEFF" --description "Few components or a new pattern, with tests"
gh label create "size:l" --color "0969DA" --description "Cross-cutting change, migration or new integration"
gh label create "size:xl" --color "0A3069" --description "Larger than one issue can deliver; split into sub-issues"
gh label create "priority:p0" --color "82071E" --description "Outage, data loss or unpatched security exposure"
gh label create "priority:p1" --color "CF222E" --description "Blocks current delivery or affects many users"
gh label create "priority:p2" --color "BF8700" --description "Planned work for the current cycle"
gh label create "priority:p3" --color "6E7781" --description "Worth doing, not time-critical"
gh label create "priority:p4" --color "D0D7DE" --description "Parked or speculative; no commitment to deliver"
```

Keep the descriptions identical to the table. They are what a reader sees when hovering
a label, and drift between the two invites inconsistent labelling.

## Repository overrides

- If the repository documents its own type, size or priority scheme, that scheme wins.
  Apply it and say which convention was followed.
- If the repository tracks these values as GitHub Projects single-select fields, apply
  the same values to the project fields after creation with
  `gh project item-edit`. Labels remain the canonical record, because they are
  searchable and portable across repositories.
- If the repository already uses a conflicting family, such as `size:S` or
  `P1-critical`, match what exists rather than creating a parallel set.
