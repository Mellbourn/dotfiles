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

const deleteBranches = async (getBranches, deleteBranch, remote, ask) => {
  const cmd = `${getBranches} | grep  -v ${neverDelete}`;
  const branchLines = await $`${cmd.split(" ")}`;

  const branches = linesToArray(branchLines);

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
await deleteBranches(
  'git branch -r --merged | sd origin/ ""',
  "git push origin --delete",
  true,
  false
);
console.log("-----------------> Delete unmerged");
await deleteBranches("git branch --no-merged", "git branch -D", false, true);
