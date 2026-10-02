# Local Workshop Definition

This repo contains my local workshop definition and scripting around that solution.
Notably, you can find a setup script to initialize, launch, and setup mounts for the workshop to excel in agentic workflows.

This is a WIP, but the intent is that this `.workshop` directory will be ported via links or mounts to all of my local repos to avoid reproducing the same workshops with the same or slightly different actions.

## Using this workshop as a single-source
Bind mounts are extremely useful to re-deploy the same workshop definition while maintaining a single source of truth.

```sh
# Go to your new workspace
cd /path/to/workspace

ln -s /path/to/this/repo/.workshop/ .workshop
```

## Setting up the workshop
Run:
```sh
./.workshop/setup.sh
```

## Launching Copilot (YOLO Mode)
Source your Github PAT

i.e.:
```sh
export GITHUB_TOKEN=github_pat_<TOKEN_VALUE>
```

Your PAT needs to have `Copilot Requests` Account permission with at least `Read-only` access to use copilot.
Go [here](https://github.com/settings/personal-access-tokens) to setup a PAT.

Run:
```sh
./.workshop/run_copilot.sh
```
