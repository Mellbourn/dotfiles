#!/usr/bin/env zx

const neverDelete = "master\\|main\\|develop\\|hotfix\\|temp\\|[0-9]task";

await $`git branch --merged | grep  -v ${neverDelete} | xargs -n 1 git branch -d`;
