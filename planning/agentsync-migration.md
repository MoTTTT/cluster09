# AgentSync Repository Migration Plan

## Overview
Create a new repository called `agentsync` to house reusable agent workflow patterns, planning tools, and multi-agent coordination documentation that can be used across multiple projects.

## Goals
1. **Reusability**: Extract agent workflow patterns from cluster09 for use in any project.
2. **Centralization**: Single source of truth for agent coordination best practices.
3. **Version Control**: Track evolution of agent workflows independently from project code.
4. **Cost Management**: Preserve API cost optimization strategies and task routing logic.

## Proposed Repository Structure

```
agentsync/
├── README.md                          # Overview and quick start
├── docs/
│   ├── getting-started.md            # How to adopt agentsync in your project
│   ├── task-routing.md               # Task complexity evaluation guide
│   ├── cost-optimization.md          # API usage and Ollama strategies
│   └── examples/                     # Sample workflows from real projects
├── workflows/
│   ├── AgentWorkflow.md              # Core multi-agent workflow doc (from cluster09)
│   ├── planning-template.md          # Reusable Planning.md template
│   └── changelog-template.md         # Reusable changelog template
├── templates/
│   ├── tasks.md                      # Task tracking template with routing
│   ├── requirements/                 # Requirement doc templates
│   ├── architecture/                 # Architecture decision templates
│   └── decisions/                    # ADR templates
├── config/
│   ├── ollama/                       # Ollama model configs
│   │   ├── templates/                # Task templates (boilerplate, etc.)
│   │   ├── patterns/                 # Code patterns for Ollama tasks
│   │   └── transformations/          # Data transformation rules
│   └── routing-rules.yaml            # Task routing decision matrix
├── scripts/
│   ├── init-project.sh               # Initialize agentsync in a new project
│   ├── sync-context.sh               # Sync agent context files
│   └── validate-tasks.sh             # Validate task.md format
└── .github/
    └── workflows/                    # CI/CD for agentsync itself
```

## Migration Tasks

### Phase 1: Repository Setup (🏠 Ollama)
- [ ] Create GitHub repository: `MoTTTT/agentsync`
- [ ] Initialize with README and LICENSE
- [ ] Set up basic directory structure
- [ ] Create .gitignore for agent temp files

### Phase 2: Extract Core Patterns (🦉 OpenClaw)
- [ ] Extract `AgentWorkflow.md` from cluster09 → `workflows/AgentWorkflow.md`
- [ ] Generalize cluster09-specific references to project-agnostic patterns
- [ ] Create `workflows/planning-template.md` based on cluster09 Planning.md structure
- [ ] Create `workflows/changelog-template.md` based on cluster09 changelog

### Phase 3: Create Templates (🏠 Ollama)
- [ ] Generate `templates/tasks.md` with routing legend and structure
- [ ] Create requirement doc template (`templates/requirements/requirement-template.md`)
- [ ] Create architecture template (`templates/architecture/architecture-template.md`)
- [ ] Create ADR template (`templates/decisions/adr-template.md`)

### Phase 4: Ollama Integration (🧠 Claude Code)
- [ ] Port Ollama task templates from cluster09 (if any exist)
- [ ] Create sample templates:
  - API endpoint boilerplate generator
  - Documentation generator from code
  - Code formatting rules
  - Test fixture generator
- [ ] Document Ollama setup and model selection guide

### Phase 5: Tooling & Scripts (🧠 Claude Code)
- [ ] Write `init-project.sh` to set up agentsync in a new project:
  - Clone/copy templates into project
  - Create planning/ directory structure
  - Initialize tasks.md and changelog.md
- [ ] Write `sync-context.sh` to keep agent context files in sync
- [ ] Write `validate-tasks.sh` to check task.md format and routing

### Phase 6: Documentation (🦉 OpenClaw)
- [ ] Write comprehensive README with:
  - What is agentsync?
  - Why use it?
  - Quick start guide
  - Links to key docs
- [ ] Write `docs/getting-started.md` step-by-step adoption guide
- [ ] Write `docs/task-routing.md` with decision tree and examples
- [ ] Write `docs/cost-optimization.md` with API budget management strategies
- [ ] Create example workflows in `docs/examples/` from cluster09 experience

### Phase 7: Integration Back to cluster09 (🦉 OpenClaw)
- [ ] Add agentsync as a git submodule or vendored copy to cluster09
- [ ] Update cluster09 to reference agentsync for workflow docs
- [ ] Symlink or copy templates into cluster09/planning/
- [ ] Update cluster09 Planning.md to reference agentsync patterns
- [ ] Archive cluster09-specific workflow docs (keep for reference)

## Key Decisions

### Repository Hosting
- **Recommendation**: GitHub public repository
- **Rationale**: 
  - Easily shareable across projects
  - CI/CD integration
  - Community contributions possible
  - Free for public repos

### Template Format
- **Markdown**: Primary format for documentation and templates
- **YAML**: Configuration files (routing rules, model configs)
- **Shell scripts**: Cross-platform compatibility where possible

### Versioning
- **Semantic versioning**: Major.Minor.Patch
- **Tags**: Version tags for stable releases
- **Branches**: 
  - `main`: Stable, production-ready
  - `dev`: Active development
  - Feature branches for new patterns

### Integration Methods
Multiple options for projects to use agentsync:

1. **Git Submodule** (Recommended for versioning)
   ```bash
   git submodule add https://github.com/MoTTTT/agentsync.git .agentsync
   ```

2. **Direct Copy** (Simpler, but manual updates)
   ```bash
   curl -L https://github.com/MoTTTT/agentsync/archive/main.tar.gz | tar xz
   ```

3. **Init Script** (Easiest for new projects)
   ```bash
   curl -s https://raw.githubusercontent.com/MoTTTT/agentsync/main/scripts/init-project.sh | bash
   ```

## Benefits

### For cluster09
- Cleaner repository (agent docs separated from cluster code)
- Easier to update workflow patterns without cluttering project history
- Can version-pin agentsync for stability

### For Future Projects
- Copy-paste AgentWorkflow.md into every new project → Just reference agentsync
- Consistent agent coordination across all projects
- Accumulated best practices from multiple projects
- Community can contribute improvements

### For API Cost Management
- Centralized cost optimization strategies
- Reusable Ollama templates reduce development of each new template
- Task routing rules can evolve based on real usage data

## Timeline Estimate

- **Phase 1-2**: 1 hour (repo setup + extract core patterns)
- **Phase 3**: 30 minutes (Ollama templates)
- **Phase 4**: 1 hour (Ollama integration)
- **Phase 5**: 1-2 hours (tooling/scripts)
- **Phase 6**: 1-2 hours (documentation)
- **Phase 7**: 30 minutes (integrate back to cluster09)

**Total**: ~5-7 hours of work (can be spread across multiple sessions)

## Routing Recommendation

- **Phase 1, 3**: 🏠 Ollama (directory creation, template boilerplate)
- **Phase 2, 6**: 🦉 OpenClaw (documentation, patterns, planning)
- **Phase 4, 5**: 🧠 Claude Code (scripting, Ollama integration logic)
- **Phase 7**: 🦉 OpenClaw (integration, coordination)

## Next Steps

1. **Human Decision Required**:
   - Approve repository name: `agentsync` or alternative?
   - Public or private repository?
   - When to start migration? (Now or after cluster09 is stable?)

2. **Preparation** (can do now):
   - Review cluster09 AgentWorkflow.md for generalization opportunities
   - Identify cluster09-specific sections to abstract
   - List additional templates that would be useful

3. **Execution**:
   - Start with Phase 1 (repo setup) when approved
   - Work through phases incrementally
   - Test integration back to cluster09
   - Document lessons learned for future projects

---

**Status**: 📋 Awaiting approval  
**Estimated Effort**: 5-7 hours  
**Blocking**: None (can start anytime)  
**Priority**: Medium (valuable long-term, not urgent)
