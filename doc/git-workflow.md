This guide explains how to work with Git in this project. The `main` branch is protected — you cannot push directly to it. All changes go through feature branches and pull requests.

---

## Daily workflow

### 1. Always start from an updated main

Before starting any new work, make sure your local `main` is up to date:

```bash
git checkout main
git pull origin main
```

### 2. Create a feature branch

Create a new branch for each piece of work. Name it clearly:

```bash
git checkout -b feature/fetch-documents
```

Naming convention:

| Prefix | When to use |
|---|---|
| `feature/` | Adding new functionality |
| `fix/` | Fixing a bug |
| `chore/` | Non-code changes (docs, config) |

Examples:
```bash
feature/document-scraper
feature/temporal-workflow-parsing
fix/database-connection-timeout
chore/update-readme
```

### 3. Write your code

Make changes, test them locally, check logs with `make logs-app`.

### 4. Commit regularly

Commit small, logical pieces of work. Do not accumulate everything in one massive commit.

```bash
git add .
git commit -m "add fetch_document activity"
```

Write commit messages that describe what changed, not how:

```
# Good
add fetch_document activity
fix retry logic for failed downloads
update database model for DocumentSegments

# Bad
changes
fix stuff
wip
```

### 5. Push your branch

```bash
git push origin feature/fetch-documents
```

### 6. Open a pull request

Go to the GitHub repository. GitHub will show a prompt to create a pull request from your recently pushed branch. Click it, fill in a description of what you changed and why, and submit.

If there is a reviewer assigned to your team, wait for their feedback before merging.

### 7. After merge

Once your pull request is merged, switch back to main and pull the latest:

```bash
git checkout main
git pull origin main
```

Delete your local branch if you no longer need it:

```bash
git branch -d feature/fetch-documents
```

---

## Pre-commit hooks

This project uses pre-commit hooks — scripts that run automatically before every `git commit`. They check your code for formatting and style issues.

If the check fails, your commit is rejected. Fix the reported issues and try again.

You can also run the checks manually at any time:

```bash
make lint
make format
```

If pre-commit hooks are not running (e.g., after a fresh clone), install them:

```bash
uv run pre-commit install
```

This is done automatically by `make setup`.

---

## Common situations

### I made changes on main by mistake

Move your changes to a new branch without losing them:

```bash
git stash
git checkout -b feature/my-feature
git stash pop
```

### I need to update my branch with new changes from main

```bash
git checkout main
git pull origin main
git checkout feature/my-feature
git rebase main
```

If there are conflicts, Git will tell you which files to resolve. Open them, fix the conflicts, then:

```bash
git add .
git rebase --continue
```

### I want to undo my last commit (but keep the changes)

```bash
git reset --soft HEAD~1
```

### I want to see what changed before committing

```bash
git diff
git status
```