#!/usr/bin/env zx

const linesToArray = (lines) =>
  lines.stdout
    .split("\n")
    .map((b) => b.trim())
    .filter((b) => b.length > 0);

const neverDelete =
  "^\\*\\|master\\|main\\|develop\\|hotfix\\|temp\\|[0-9]task";

try {
  await $`git branch --merged | grep  -v ${neverDelete} | xargs -n 1 git branch -d`;
} catch (p) {
  console.log(`No merged branches to delete (${p.exitCode})`);
}

try {
  await $`git branch -r --merged | sd 'origin/' '' | grep  -v ${neverDelete} | xargs -n 1 git push origin --delete`;
} catch (p) {
  console.log(`No remote merged branches to delete (${p.exitCode})`);
}

const deleteBranches = async (getBranches, deleteBranch) => {
  const branchLines = await $`${getBranches.split(
    " "
  )} | grep  -v ${neverDelete}`;

  const branches = linesToArray(branchLines);

  if (branches.length > 0) {
    console.warn("Deleting branches: ", branches);
    for (const branch of branches) {
      await $`git log origin/main..${branch}`;
      const shouldDelete = await question(`delete "${branch}"? [y/N] `);
      if (shouldDelete && shouldDelete[0].toLowerCase() === "y") {
        await $`${deleteBranch.split(" ")} ${branch}`;
      }
    }
  } else {
    console.log(`No branches to delete`);
  }
};

console.log("-----------------> Delete unmerged");
deleteBranches("git branch --no-merged", "git branch -D");
