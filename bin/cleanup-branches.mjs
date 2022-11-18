#!/usr/bin/env zx

const neverDelete = "master\\|main\\|develop\\|hotfix\\|temp\\|[0-9]task";

try {
  await $`git branch --merged | grep  -v ${neverDelete} | xargs -n 1 git branch -d`;
} catch (p) {
  console.log(`No merged branches to delete (${p.exitCode})`);
}

let branches = [];

try {
  branches = await $`git branch --no-merged | grep  -v ${neverDelete}`;
} catch (p) {
  console.log(`No unmerged branches to delete (${p.exitCode})`);
  process.exit(0);
}

console.log(chalk.blue(`Branches to delete: ${branches.stdout}`));

// branches.forEach((branch) => {
//   console.log(`delete ${branch}`);
// });
