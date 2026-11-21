# Risk tiers

The architect classifies the objective; the orchestrator applies the gates at task
level. When two tiers are plausible, take the higher one and record why.

| Tier | Typical work                                                                                           | Plan                                     | Design review | Task review  | Integration review and approval                      |
| ---- | ------------------------------------------------------------------------------------------------------ | ---------------------------------------- | ------------- | ------------ | ---------------------------------------------------- |
| T0   | Documentation, comments, formatting, or test-only changes with no behaviour impact                     | Short brief; no full plan or plan review | Not required  | Not required | Not required                                         |
| T1   | Behaviour change within one module, covered by existing tests                                          | Full plan; no plan review                | Optional      | Required     | Not required                                         |
| T2   | Public contract, data shape, CI or release configuration, security, dependencies, or several modules   | Full plan and review                     | Required      | Required     | Required                                             |
| T3   | History rewrite, deletion, migration, lockfile-changing dependency upgrade, or other irreversible work | Full plan and review                     | Required      | Required     | Required; irreversible actions approved individually |

## Gate semantics

- **Slice approval** is required at every tier before the orchestrator starts the
  slice. The user approves the slice, not each task inside it.
- **Design approval** is required at T1 and above, before implementation begins. T0
  uses a short objective and a short brief instead.
- **Task review** means an independent verdict from the reviewer. Self-assessment
  never substitutes for it.
- **Integration approval** routes through the architect at T2 and above, because the
  orchestrator has no channel to the user.
- An **irreversible action** requires separate, explicit approval immediately before
  it is taken, even when it appears inside an approved slice.

## Changing the tier

A discovery that raises the risk changes the tier: halt before the next write,
record a decision, and obtain approval. The orchestrator may not raise its own tier
silently; it escalates to the architect.

## Identifiers

| Format        | Meaning                  | Example  |
| ------------- | ------------------------ | -------- |
| `S<number>`   | Slice identifier         | `S1`     |
| `T<number>`   | Task identifier          | `T1`     |
| `FR-<number>` | Functional requirement   | `FR-001` |
| `SC-<number>` | Success criterion        | `SC-001` |
| `D<number>`   | Decision record          | `D1`     |
| `R<number>`   | Risk register entry      | `R1`     |
| `T0`–`T3`     | Risk tier, not a task ID | `T2`     |

Task IDs and risk tiers share the `T<number>` notation. Always label the field
**Task ID** or **Risk tier** so a value such as `T1` is unambiguous.
