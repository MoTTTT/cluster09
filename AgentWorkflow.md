# Agent Workflow Documentation

**Project**: cluster09  
**Repository**: https://github.com/MoTTTT/cluster09  
**Last Updated**: March 3, 2026

## Overview

This document defines the multi-agent development workflow for the cluster09 project, coordinating work between AI agents (OpenClaw and Claude Code) and human developers.

## Agents in Use

### OpenClaw ("trismegistus")
- **Role**: Planning, orchestration, documentation, system administration, task scheduling
- **Primary Tasks**: 
  - Requirements gathering and analysis
  - Architecture decisions and documentation
  - Task breakdown and prioritization
  - System administration and configuration
  - Process documentation
  - PR creation for documentation and config changes
  - **Task routing** - Deciding which agent handles which tasks
  - **Ollama scheduling** - Delegating simpler tasks to local Ollama models

### Claude Code
- **Role**: Code implementation and development (complex reasoning tasks)
- **Primary Tasks**:
  - Feature implementation based on requirements
  - Code refactoring and optimization
  - Complex bug fixes and debugging
  - Code review and testing
  - Technical implementation details requiring deep reasoning

### Ollama (Local LLM)
- **Role**: Execution of routine, less reasoning-intensive tasks
- **Scheduled by**: OpenClaw
- **Primary Tasks**:
  - Code formatting and linting
  - Simple code generation (boilerplate, templates)
  - Documentation generation from code
  - Log parsing and summarization
  - Simple text transformations
  - Routine file operations
  - Pattern-based code updates
  - Test data generation
- **Advantages**:
  - No API costs (runs locally)
  - No rate limits
  - Faster for simple tasks
  - Privacy (data stays local)

### Human Developer
- **Role**: Review, decision-making, coordination
- **Primary Tasks**:
  - Final approval on PRs
  - Strategic decisions
  - Conflict resolution
  - Production deployments

## Directory Structure

```
cluster09/
├── .openclaw/              # OpenClaw's working directory (gitignored)
│   └── <feature-branches>  # Separate working copies per feature
├── docs/                   # Shared documentation (source of truth)
│   ├── requirements/       # Requirements and user stories
│   ├── architecture/       # Architecture decisions and diagrams
│   ├── decisions/          # ADRs (Architecture Decision Records)
│   ├── tasks.md           # Current task tracking
│   ├── changelog.md       # Agent activity log
│   └── agentWorkflow.md   # This file
├── src/                    # Source code (primary workspace)
├── config/                 # Configuration files
│   └── ollama/            # Ollama model configs and task definitions
├── infrastructure/         # IaC, deployment configs
│   └── ollama/            # Ollama installation and setup
└── .git/
```

## Workflow Principles

### 1. Shared Context via Documentation
- All planning, requirements, and decisions are documented in `docs/`
- Both agents read from these shared markdown files
- Documentation is updated before code changes
- Task status tracked in `docs/tasks.md`

### 2. Isolated Working Copies
- OpenClaw works in `.openclaw/` directory (separate git worktree or clone)
- Claude Code works directly in main workspace
- Prevents merge conflicts and stepping on each other's work
- Clear separation of concerns

### 3. Pull Request Based Integration
- All OpenClaw changes go through PRs
- PRs provide audit trail and review gate
- Conventional commit messages for traceability
- Branch naming: `openclaw/<task-id>-<description>`

### 4. Clear Division of Labor
- **OpenClaw**: Docs, configs, planning, sysadmin, **task routing/scheduling**
- **Claude Code**: Complex source code, implementation, deep reasoning
- **Ollama**: Routine tasks, boilerplate, simple transformations
- Overlap only when necessary, with clear communication

### 5. Intelligent Task Routing
OpenClaw evaluates tasks and routes them based on complexity:
- **High reasoning** → Claude Code (via API)
- **Low reasoning** → Ollama (local, no cost)
- **Planning/orchestration** → OpenClaw itself
- **Decisions** → Human developer

**Task Complexity Criteria:**
```
Route to Ollama if task is:
- Pattern-based (formatting, linting)
- Template-driven (boilerplate generation)
- Repetitive (bulk operations)
- Well-defined with clear rules
- Low ambiguity

Route to Claude Code if task requires:
- Complex problem solving
- Architecture decisions
- Novel implementations
- Deep code understanding
- Ambiguity resolution
```

## OpenClaw Workflow

### Setup
```bash
# Create OpenClaw working directory
cd /path/to/cluster09
git worktree add .openclaw/main main

# Or separate clone
git clone https://github.com/MoTTTT/cluster09.git .openclaw
```

### Standard Process

1. **Planning Phase**
   - Update `docs/requirements/` with new features
   - Document architecture decisions in `docs/architecture/`
   - Create task breakdown in `docs/tasks.md`
   - Add entry to `docs/changelog.md`

2. **Implementation Phase**
   ```bash
   cd .openclaw
   git checkout -b openclaw/TASK-123-feature-name
   # Make changes to docs/, config/, infrastructure/
   git add .
   git commit -m "[OpenClaw] TASK-123: Description"
   git push origin openclaw/TASK-123-feature-name
   # Create PR via GitHub CLI or web
   ```

3. **PR Description Template**
   ```markdown
   ## [OpenClaw] TASK-123: Feature Name
   
   **Agent**: OpenClaw (trismegistus)
   **Type**: Documentation | Configuration | Infrastructure
   **Related Tasks**: TASK-123
   
   ### Changes
   - Updated requirements.md with new feature spec
   - Added architecture decision record
   - Modified terraform configs for new service
   
   ### Context for Review
   - Reasoning for decisions
   - Trade-offs considered
   - Next steps for implementation
   
   ### Checklist
   - [ ] Documentation updated
   - [ ] Tasks.md reflects changes
   - [ ] Changelog.md entry added
   - [ ] No conflicts with main branch
   ```

4. **Post-Merge**
   - Update `docs/changelog.md` with merge timestamp
   - Update `docs/tasks.md` to mark task complete
   - Sync working copy: `git pull origin main`

### OpenClaw Responsibilities

**Documentation**
- Requirements gathering and specification
- Architecture decision records (ADRs)
- Process documentation
- API documentation
- Runbooks and operational guides

**Configuration**
- Environment configs
- CI/CD pipeline definitions
- Infrastructure as Code (Terraform, CloudFormation)
- Docker/Kubernetes manifests
- Service configurations

**System Administration**
- Server setup and provisioning
- Access control and permissions
- Backup and recovery procedures
- Monitoring and alerting setup

**Planning & Coordination**
- Task breakdown and estimation
- Dependency mapping
- Risk assessment
- Sprint/milestone planning

## Claude Code Workflow

### Setup
```bash
# Work directly in main repository
cd /path/to/cluster09
code .  # Open in VS Code with Claude Code extension
```

### Standard Process

1. **Context Loading**
   - Read `docs/requirements/` for feature specs
   - Review `docs/architecture/` for design constraints
   - Check `docs/tasks.md` for current priorities
   - Review `docs/changelog.md` for recent changes

2. **Implementation**
   - Work directly on feature branches
   - Implement based on documented requirements
   - Follow architecture patterns in docs
   - Write tests alongside code

3. **Branch Naming**
   - `feature/<task-id>-<description>`
   - `bugfix/<task-id>-<description>`
   - `refactor/<description>`

4. **Commit Messages**
   ```
   [ClaudeCode] TASK-123: Implement user authentication
   
   - Add JWT token generation
   - Implement login endpoint
   - Add authentication middleware
   - Update tests
   
   Refs: docs/requirements/auth.md
   ```

5. **PR Creation**
   - Standard GitHub PR process
   - Reference requirements docs
   - Include test results
   - Request human review for merge

### Claude Code Responsibilities

**Implementation**
- Feature development
- Bug fixes
- Code refactoring
- Performance optimization

**Code Quality**
- Unit and integration tests
- Code documentation (inline comments)
- Linting and formatting
- Security best practices

**Review**
- Review OpenClaw's PRs when they touch code boundaries
- Validate configuration changes work with codebase
- Flag conflicts or issues

## Ollama Workflow

### Setup
```bash
# Ollama installation (typically in infrastructure/)
# Models configured in config/ollama/

# Example models:
# - codellama:7b - Code generation
# - llama2:7b - General tasks
# - mistral:7b - Fast inference
```

### Task Scheduling (by OpenClaw)

OpenClaw determines task routing and schedules Ollama tasks:

1. **Task Evaluation**
   ```markdown
   # In docs/tasks.md
   
   ### TASK-456: Generate API endpoint boilerplate
   - **Complexity**: Low
   - **Assigned**: Ollama (codellama:7b)
   - **Scheduled by**: OpenClaw
   - **Priority**: Medium
   - **Template**: config/ollama/templates/api-endpoint.json
   ```

2. **Ollama Invocation**
   OpenClaw creates task specification:
   ```json
   {
     "task_id": "TASK-456",
     "model": "codellama:7b",
     "type": "code_generation",
     "template": "api-endpoint",
     "parameters": {
       "endpoint_name": "getUserProfile",
       "method": "GET",
       "auth_required": true
     },
     "output_path": "src/api/endpoints/user-profile.ts",
     "validation": "lint_only"
   }
   ```

3. **Execution & Validation**
   - Ollama generates code based on template
   - Basic validation (syntax, linting)
   - Output committed to `ollama/<task-id>` branch
   - Creates PR for human/Claude Code review

4. **Commit Messages**
   ```
   [Ollama-codellama] TASK-456: Generate user profile endpoint
   
   Generated via template: config/ollama/templates/api-endpoint.json
   Scheduled by: OpenClaw
   Validation: Passed linting
   
   Requires: Human review before merge
   ```

### Ollama Responsibilities

**Code Generation**
- Boilerplate code (CRUD operations, API endpoints)
- Test fixtures and mock data
- Configuration file templates
- Database migrations (simple schema changes)

**Documentation**
- Generate JSDoc/docstrings from code
- README sections from templates
- API documentation from endpoint definitions
- Changelog entries from commit history

**Code Maintenance**
- Format code to style guide
- Run linters and auto-fix
- Update import statements
- Refactor repetitive patterns

**Data Processing**
- Parse and transform log files
- Generate reports from structured data
- Convert between data formats
- Extract metrics from code

### Ollama Task Types

**Template-Based Tasks**
Location: `config/ollama/templates/`
- API endpoint generation
- Component scaffolding
- Database model creation
- Test suite templates

**Pattern-Based Tasks**
Location: `config/ollama/patterns/`
- Code formatting rules
- Naming convention enforcement
- Import organization
- Error handling patterns

**Transformation Tasks**
Location: `config/ollama/transformations/`
- Data format conversions
- Log parsing rules
- Metric extraction patterns
- Documentation generation rules

## Context Synchronization

### docs/changelog.md Format
```markdown
# Agent Activity Changelog

## 2026-03-03

### OpenClaw (trismegistus)
- **14:30** - Created requirements for user authentication system
- **15:45** - PR #42 merged: Infrastructure updates for auth service
- **16:20** - Updated tasks.md with implementation breakdown
- **16:45** - Scheduled TASK-456 to Ollama (boilerplate generation)

### Claude Code
- **10:15** - Implemented user registration endpoint (PR #43)
- **13:00** - Fixed bug in token validation (PR #44)
- **16:45** - Started work on password reset flow

### Ollama (codellama:7b)
- **16:50** - Generated API endpoint boilerplate (TASK-456)
- **17:00** - PR #45 created: User profile endpoint scaffold
- **Status**: Awaiting review

### Ollama (llama2:7b)
- **15:00** - Formatted 45 source files to style guide
- **15:15** - Generated documentation for new modules

## 2026-03-02
...
```

### docs/tasks.md Format
```markdown
# Task Tracking

## In Progress

### TASK-123: User Authentication System
- **Status**: In Progress
- **Assigned**: Claude Code
- **Complexity**: High (deep reasoning required)
- **Started**: 2026-03-01
- **Requirements**: docs/requirements/auth.md
- **Architecture**: docs/architecture/auth-design.md
- **Blockers**: None
- **Subtasks**:
  - [x] Registration endpoint
  - [x] Login endpoint
  - [ ] Password reset flow
  - [ ] Email verification
  - [ ] Session management

### TASK-456: Generate API Endpoint Boilerplate
- **Status**: In Review
- **Assigned**: Ollama (codellama:7b)
- **Scheduled by**: OpenClaw
- **Complexity**: Low (template-based)
- **Started**: 2026-03-03 16:45
- **Template**: config/ollama/templates/api-endpoint.json
- **Output**: PR #45
- **Validation**: Linting passed
- **Reviewer**: Claude Code or Human

## Planned

### TASK-789: Format Codebase to New Style Guide
- **Status**: Planned
- **Assigned**: Ollama (llama2:7b)
- **Complexity**: Low (pattern-based)
- **Estimated**: 30 minutes
- **Scope**: All .ts and .tsx files in src/
- **Validation**: Automated linting check

## Completed
...
```

## Communication Protocol

### When OpenClaw Needs Claude Code
1. Document the requirement in `docs/requirements/`
2. Add task to `docs/tasks.md` with "Assigned: Claude Code"
3. Mark complexity as "High" or "Medium"
4. Add note in `docs/changelog.md`
5. Claude Code picks up from task list

### When OpenClaw Needs Ollama
1. Evaluate task complexity (use routing criteria)
2. Create task in `docs/tasks.md` with:
   - "Assigned: Ollama (model-name)"
   - "Scheduled by: OpenClaw"
   - Complexity: Low
   - Template or pattern reference
3. Generate task specification JSON in `config/ollama/tasks/`
4. Invoke Ollama via API or CLI
5. Log execution in `docs/changelog.md`

### When Claude Code Needs OpenClaw
1. Create issue in `docs/requirements/clarifications.md`
2. Add note in `docs/changelog.md`
3. Tag in commit message: `Needs: OpenClaw review on auth architecture`

### When Ollama Task Completes
1. OpenClaw validates output
2. Creates PR with `[Ollama-{model}]` prefix
3. Assigns reviewer (Claude Code or Human)
4. Updates `docs/changelog.md` and `docs/tasks.md`

### When Either Needs Human
1. Create PR with "HUMAN REVIEW REQUIRED" label
2. Document decision needed in PR description
3. Block merge until human approves

## Conflict Resolution

### Merge Conflicts
- **Prevention**: Clear domain separation
- **Resolution**: Human developer decides
- **Process**: 
  1. Agent documents reasoning in PR
  2. Alternative approaches in comments
  3. Human makes final call

### Overlapping Work
- **Check**: Review `docs/changelog.md` before starting
- **Communication**: Update `tasks.md` when starting work
- **Coordination**: Use task assignments to prevent collisions

### Disagreements
- Document both perspectives in `docs/decisions/`
- Present trade-offs clearly
- Human developer makes binding decision
- Update ADR with final decision and rationale

## Quality Gates

### Documentation Changes (OpenClaw)
- [ ] Markdown syntax valid
- [ ] Links work correctly
- [ ] References to code are accurate
- [ ] Diagrams render properly
- [ ] Changelog updated
- [ ] Tasks.md reflects current state

### Code Changes (Claude Code)
- [ ] Tests pass
- [ ] Linting passes
- [ ] Documentation updated
- [ ] Requirements met
- [ ] Architecture patterns followed
- [ ] No breaking changes (or documented)

### Configuration Changes (OpenClaw)
- [ ] Validated in non-prod environment
- [ ] Rollback plan documented
- [ ] Secrets properly handled
- [ ] Dependencies documented
- [ ] Runbook updated if needed

### Ollama-Generated Code
- [ ] Template/pattern correctly applied
- [ ] Linting passes (automated)
- [ ] Syntax validation passes
- [ ] Output matches specification
- [ ] No hallucinated dependencies
- [ ] Human or Claude Code review completed
- [ ] Integration tests pass (if applicable)

## Best Practices

### For OpenClaw
1. **Be verbose in documentation** - Claude Code can't ask questions
2. **Document the "why"** - Not just what, but reasoning
3. **Keep changelog current** - Real-time activity tracking
4. **Clear task descriptions** - Include acceptance criteria
5. **Update on changes** - Even small updates to docs matter
6. **Smart task routing** - Evaluate complexity before assigning
7. **Validate Ollama output** - Always check generated code before PR
8. **Template maintenance** - Keep Ollama templates updated and tested

### For Claude Code
1. **Read docs first** - Don't assume, verify against requirements
2. **Reference docs in commits** - Show traceability
3. **Flag ambiguities** - Add to clarifications.md
4. **Keep humans informed** - PR descriptions explain decisions
5. **Test thoroughly** - Automated tests reduce review burden
6. **Review Ollama PRs** - Quick validation of generated code
7. **Update templates** - Improve Ollama templates based on patterns you see

### For Ollama Tasks (OpenClaw Scheduling)
1. **Clear specifications** - Provide complete, unambiguous task specs
2. **Template quality** - Maintain high-quality, tested templates
3. **Validation first** - Always validate output before creating PR
4. **Appropriate scope** - Don't over-rely on Ollama for complex tasks
5. **Model selection** - Choose appropriate model for task type
6. **Fallback plan** - If Ollama fails, reassign to Claude Code
7. **Cost awareness** - Ollama is free, but costs developer time to review

### For Human Developers
1. **Review changelog daily** - Stay aware of agent activity
2. **Merge PRs promptly** - Don't let agents get blocked
3. **Provide clear decisions** - Agents need unambiguous direction
4. **Update workflow** - Improve this doc based on experience
5. **Trust but verify** - Agents are tools, you're responsible
6. **Monitor Ollama quality** - Tune templates and routing as needed
7. **Balance automation** - Find right mix of Ollama vs Claude Code

## Troubleshooting

### OpenClaw Can't See Claude Code's Work
- **Check**: Is code committed and pushed?
- **Solution**: Claude Code commits with clear messages
- **Workaround**: Human syncs context manually

### Claude Code Missing Requirements
- **Check**: Is documentation in `docs/requirements/`?
- **Solution**: OpenClaw ensures docs are complete before assigning
- **Workaround**: Human provides additional context

### Ollama Generated Incorrect Code
- **Check**: Is template specification accurate?
- **Solution**: Update template in `config/ollama/templates/`
- **Workaround**: Reassign to Claude Code for complex implementation
- **Prevention**: Better task routing evaluation by OpenClaw

### Ollama Task Validation Fails
- **Check**: Linting rules, syntax validation
- **Solution**: Fix template or adjust validation rules
- **Escalate**: If pattern is too complex, route to Claude Code instead
- **Document**: Add failure case to template documentation

### Task Routing Ambiguity
- **Check**: Is complexity truly low/high?
- **Solution**: Document edge cases in routing criteria
- **Ask**: Human developer makes final routing decision
- **Update**: Refine routing guidelines in this doc

### Conflicting Changes
- **Prevention**: Clear domain separation (docs vs code)
- **Detection**: Regular git pull and PR review
- **Resolution**: Human mediates and decides

### Rate Limit Issues
- **Monitor**: Check API usage at console.anthropic.com
- **Optimize**: Use Claude Code for coding (better caching)
- **Leverage Ollama**: Route simple tasks to Ollama (no API cost)
- **Escalate**: Request rate limit increase if needed
- **Workaround**: Stagger agent work, prioritize critical tasks

## API Usage Optimization

### Prompt Caching (Claude Code)
- Automatically caches file context
- ~90% token savings on repeated files
- Works best with consistent workspace structure

### Efficient Context (OpenClaw)
- Reference docs by filename, not full content
- Use summarized task lists
- Batch related documentation updates

### Ollama for Cost Reduction
- **Zero API cost** - Runs locally, no Anthropic charges
- **No rate limits** - Process unlimited simple tasks
- **Use cases**: Formatting, boilerplate, documentation generation
- **Trade-off**: Less capable than Claude, needs good templates
- **Recommendation**: Route 30-50% of tasks to Ollama where appropriate

### Rate Limit Management
- **Claude Code**: Primary for complex coding (better optimization)
- **OpenClaw**: For planning and non-coding tasks
- **Ollama**: For routine, template-based tasks (no limits!)
- **Monitor**: https://console.anthropic.com/settings/usage
- **Upgrade**: Request higher limits if hitting frequently

### Cost Comparison
```
Typical 100-task sprint:
- All tasks via Claude API: ~$15-20
- Smart routing (60 Claude, 40 Ollama): ~$9-12
- Savings: ~40% on API costs
```

## Version Control

### .gitignore Additions
```
# OpenClaw working directory
.openclaw/

# Agent temporary files
docs/.agent-temp/
*.agent.tmp

# Local agent configs (don't commit API keys!)
.openclaw-config
.claude-code-config
```

### Branch Protection
- `main`: Require PR review, block direct commits
- `dev`: Require PR, allow agent auto-merge for docs
- `openclaw/*`: Agents can commit directly
- `feature/*`: Developers can commit directly

## Monitoring & Metrics

### Track in docs/metrics.md
- PR merge frequency
- Time from planning to implementation
- Agent vs human commit ratio
- Documentation coverage
- Task completion rate
- **Ollama task success rate** (% passing validation first time)
- **API cost savings** (vs routing all tasks to Claude)
- **Task routing accuracy** (% correctly routed)
- **Ollama model performance** (by model and task type)

### Review Weekly
- What's working well?
- Where are bottlenecks?
- Are agents effective?
- Is Ollama routing optimal?
- Which templates need improvement?
- Update this workflow doc accordingly

### Ollama-Specific Metrics
```markdown
# Sample metrics tracking

## Week of 2026-03-03

### Task Distribution
- Total tasks: 100
- Claude Code: 55 (55%)
- Ollama: 40 (40%)
- Human: 5 (5%)

### Ollama Performance
- Success rate (first pass): 85%
- Rework needed: 15%
- Models used:
  - codellama:7b - 25 tasks (88% success)
  - llama2:7b - 15 tasks (80% success)

### Cost Analysis
- Estimated API cost if all tasks via Claude: $18
- Actual API cost (with Ollama): $11
- Savings: $7 (39%)
- Time savings: 3 hours (routine tasks automated)
```

## Evolution

This workflow will evolve. Update this document when:
- New patterns emerge
- Conflicts reveal gaps
- Better practices are discovered
- Tools or capabilities change
- Team composition changes

**Document Owner**: Human Developer  
**Review Cadence**: Monthly or after major changes  
**Feedback**: Create issues or PRs to suggest improvements

---

## Quick Reference

### OpenClaw Commands
```bash
# Start new feature
cd .openclaw && git checkout -b openclaw/TASK-XXX-description

# Update after merge
git pull origin main && git worktree sync

# Create PR
gh pr create --title "[OpenClaw] TASK-XXX: Description"

# Schedule Ollama task
# Create task spec in config/ollama/tasks/TASK-XXX.json
# Invoke: ollama run codellama < task-spec.json > output.txt
# Or via OpenClaw's task scheduler
```

### Claude Code Workflow
```bash
# Start feature
git checkout -b feature/TASK-XXX-description

# Reference docs
# "Review docs/requirements/feature.md and implement"

# Commit
git commit -m "[ClaudeCode] TASK-XXX: Implementation"
```

### Ollama Task Scheduling (OpenClaw)
```bash
# Example task specification
cat > config/ollama/tasks/TASK-456.json << EOF
{
  "task_id": "TASK-456",
  "model": "codellama:7b",
  "type": "code_generation",
  "template": "api-endpoint",
  "parameters": { ... },
  "output_path": "src/api/endpoints/...",
  "validation": "lint_only"
}
EOF

# Execute
ollama run codellama < config/ollama/tasks/TASK-456.json

# Or use OpenClaw's scheduler API
```

### Task Routing Decision Tree
```
Is the task well-defined with clear rules? → YES
  └─ Is it pattern/template based? → YES
      └─ Requires deep reasoning? → NO
          └─ ASSIGN TO OLLAMA

Otherwise → Evaluate complexity
  └─ High complexity → CLAUDE CODE
  └─ Medium complexity → CLAUDE CODE (be conservative)
  └─ Planning/orchestration → OPENCLAW
  └─ Strategic decision → HUMAN
```

### Human Review Checklist
- [ ] Does this align with project goals?
- [ ] Are requirements clear and complete?
- [ ] Is the implementation sound?
- [ ] Are there security concerns?
- [ ] Is documentation updated?
- [ ] Can this be safely merged?
- [ ] If Ollama-generated: Does output match specification?
- [ ] If Ollama-generated: Are there hallucinations or errors?

---

**Remember**: Agents are tools to amplify your productivity. You remain the decision-maker, architect, and ultimately responsible for the codebase. Use this workflow to coordinate effectively while maintaining quality and control.

## Ollama Integration Benefits

The addition of Ollama to your multi-agent workflow provides:

✅ **Cost savings** - 30-50% reduction in API costs for routine tasks  
✅ **No rate limits** - Process unlimited template-based tasks locally  
✅ **Privacy** - Sensitive data stays on your infrastructure  
✅ **Speed** - Fast local inference for simple tasks  
✅ **Flexibility** - Mix of cloud (Claude) and local (Ollama) capabilities  

**Optimal usage**: Let OpenClaw intelligently route tasks based on complexity, use Ollama for 30-40% of routine work, reserve Claude Code for tasks requiring deep reasoning and complex problem-solving.
