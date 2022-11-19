#!/usr/bin/env zx

cd(`${$.env.HOME}/code/experiments/git/branch-experiment`);

const addCommittedFile = async (name) => {
  if (!fs.existsSync(name)) {
    fs.writeFileSync(name, `content of ${name}`);
    await $`git add ${name}`;
    await $`git commit -m "commit ${name}"`;
  }
};

const branchExists = async (name) => {
  try {
    const { exitCode } = await $`git show-ref --quiet refs/heads/${name}`;
    return exitCode === 0;
  } catch (p) {
    return false;
  }
};

const createBranch = async (name, isMerged = true, isPushed = false) => {
  if (!(await branchExists(name))) {
    await $`git switch -c ${name}`;
    if (!isMerged) {
      addCommittedFile(`${name}.txt`);
    }
    if (isPushed) {
      await $`git push -u origin ${name}`;
    }
    await $`git switch main`;
  }
};

await $`git switch main`;
await addCommittedFile("firstFile.txt");
await $`git push -u origin main`;

await createBranch("unmerged1", false);
await createBranch("merged1");
await createBranch("unmergedPushed1", false, true);
await createBranch("mergedPushed1", true, true);

await createBranch("current");
await $`git switch current`;
await $`cleanup-branches.mjs`;

if (!(await branchExists("current"))) {
  console.log(
    chalk.red(
      "current branch should not have been deleted, since it is currently checked out"
    )
  );
}

if (await branchExists("merged1")) {
  console.log(
    chalk.red("merged1 should have been deleted, since it is merged")
  );
}
