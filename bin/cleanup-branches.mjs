#!/usr/bin/env zx

await $`git branch --merged | grep  -v '\\*\\|master\\|main\\|develop\\|hotfix\\|temp\\|[0-9]task' | xargs -n 1 git branch -d`;
