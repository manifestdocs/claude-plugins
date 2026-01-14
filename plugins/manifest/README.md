# Manifest Claude Code Plugin

Living feature documentation for AI-assisted development.

## Installation

```bash
# Install the plugin
/install-plugin rocket-tycoon/claude-plugins manifest
```

## What it does

Manifest provides MCP tools for managing features as living documentation:

- **Project Management**: Create projects and associate directories
- **Feature Tracking**: Define features as system capabilities (not work items)
- **Session Workflow**: Create sessions and tasks for implementing features
- **Agent Coordination**: Get task context, start/complete tasks

## Tools Available (18 total)

**Setup Tools:**
| Tool | Description |
|------|-------------|
| `create_project` | Create a project container for features |
| `add_project_directory` | Link a filesystem path to a project |
| `create_feature` | Define a single system capability |
| `plan_features` | Define an entire feature tree in one call |

**Discovery Tools:**
| Tool | Description |
|------|-------------|
| `get_project_context` | Get project info from a directory path |
| `list_features` | Browse features with filters (returns summaries) |
| `search_features` | Find features by keyword |
| `get_feature` | Get full details of a specific feature |
| `get_feature_history` | View past implementation sessions |
| `update_feature_state` | Transition feature through lifecycle |

**Orchestrator Tools:**
| Tool | Description |
|------|-------------|
| `create_session` | Start work session on a leaf feature |
| `create_task` | Create a task within a session |
| `breakdown_feature` | Create session + tasks in one call |
| `list_session_tasks` | Monitor progress of all tasks |
| `complete_session` | Finalize session, create history entry |

**Agent Tools:**
| Tool | Description |
|------|-------------|
| `get_task_context` | Get assigned task with full feature context |
| `start_task` | Signal work is beginning |
| `complete_task` | Signal task is finished |

## Philosophy

Features are **living documentation** of system capabilities - not work items to close.

- Name by capability: "Router", "Authentication", "Validation"
- NOT by phase: "Phase 1", "Step 2", "Sprint 3"
- Features persist and evolve with the codebase
