#!/usr/bin/env zx

// suppress quoting, it doesn't allow for dynamic commands
const q = $.quote;
$.quote = (v) => v;

const linesToArray = (lines) =>
  lines.stdout
    .split("\n")
    .map((b) => b.trim())
    .filter((b) => b.length > 0);

const neverDelete =
  "'^\\*\\|master\\|main\\|develop\\|hotfix\\|temp\\|[0-9]task'";

const deleteBranches = async ({ merged, remote, ask }) => {
  const getBranches = `git branch ${remote ? "-r" : ""} ${
    merged ? "--merged" : "--no-merged"
  }${remote ? ' | sd origin/ ""' : ""}`;

  const cmd = `${getBranches} | grep  -v ${neverDelete}`;

  let branches = [];
  try {
    const branchLines = await $`${cmd}`;
    branches = linesToArray(branchLines);
  } catch (p) {
    if (p.exitCode !== 1) {
      throw p;
    }
  }
  if (branches.length === 0) {
    console.log(`No branches to delete`);
    return;
  }

  const deleteBranch = remote
    ? "git push origin --delete"
    : "git branch " + (merged ? "-d" : "-D");

  console.warn("Deleting branches: ", branches);
  for (const branch of branches) {
    await $`git log origin/main..${(remote ? "origin/" : "") + branch}`;
    const shouldDelete = ask
      ? await question(`delete "${branch}"? [y/N] `)
      : "y";
    if (shouldDelete && shouldDelete[0].toLowerCase() === "y") {
      await $`${deleteBranch.split(" ")} ${branch}`;
    }
  }
};

console.log("-----------------> Delete local merged");
await deleteBranches({
  merged: true,
  remote: false,
  ask: false,
});
console.log(chalk.bold("-----------------> Delete remote merged"));
await deleteBranches({
  merged: true,
  remote: true,
  ask: false,
});
console.log(chalk.yellow("-----------------> Delete unmerged"));
await deleteBranches({
  merged: false,
  remote: false,
  ask: true,
});
console.log(chalk.yellow.bold("-----------------> Delete unmerged remote"));
await deleteBranches({
  merged: false,
  remote: true,
  ask: true,
});
