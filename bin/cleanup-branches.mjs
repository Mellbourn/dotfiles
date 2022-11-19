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

try {
  await $`git branch --merged | grep  -v ${neverDelete} | xargs -n 1 git branch -d`;
} catch (p) {
  console.log(`No merged branches to delete (${p.exitCode})`);
}

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
    if (p.exitCode === 1) {
      console.log(`No branches to delete`);
    } else {
      throw p;
    }
  }

  const deleteBranch = remote
    ? "git push origin --delete"
    : "git branch " + (merged ? "-d" : "-D");

  if (branches.length > 0) {
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
  } else {
    console.log(`No branches to delete`);
  }
};

console.log("-----------------> Delete remote merged");
await deleteBranches({
  merged: true,
  remote: true,
  ask: false,
});
console.log("-----------------> Delete unmerged");
await deleteBranches({
  merged: false,
  remote: false,
  ask: true,
});
