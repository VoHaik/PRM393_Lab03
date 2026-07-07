# Workspace Rules

## 1. Plan Documentation & Specific Naming Convention
Whenever the AI assistant creates or updates planning or progress tracking documents, it must mirror them directly in the project's source code under the directory `docs/plans/`.

To avoid conflicts with future tasks, all plan-related files stored in the repository must follow a specific naming convention:
* **Format:** `[XX]_[lowercase_snake_case_topic]_[file_type].md`
  * `[XX]` is a 2-digit sequential number starting at `01`.
  * `[file_type]` is one of: `plan`, `tasks`, `walkthrough`.
* **Examples for Topic "Migration to MVVM + Provider":**
  * Plan: `docs/plans/01_migration_to_mvvm_provider_plan.md`
  * Tasks: `docs/plans/01_migration_to_mvvm_provider_tasks.md`
  * Walkthrough: `docs/plans/01_migration_to_mvvm_provider_walkthrough.md`

*(Note: The internal files in the agent's conversation workspace will remain `implementation_plan.md`, `task.md`, and `walkthrough.md` for standard planning-mode compatibility, but their corresponding exported copies in `docs/plans/` must be renamed using this convention).*

## 2. Project Memory & Map Maintenance
To avoid scanning the entire project on every turn or when new agents join the project, the AI assistant must maintain a **`docs/PROJECT_MAP.md`** file.
* This file serves as the project's index and active memory.
* **Content:** High-level architecture, module responsibilities, core file mapping, and a log of completed migrations and additions.
* **Update Policy:** Every time a plan is completed (and a walkthrough is generated), the AI assistant **MUST** update `docs/PROJECT_MAP.md` to reflect the latest state of the codebase.
