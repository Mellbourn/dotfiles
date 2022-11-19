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
    const { exitCode } = await $`git show-ref --quiet refs/heads/ ${name}`;
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

await addCommittedFile("firstFile.txt");
await $`git push -u origin main`;

await createBranch("unmerged1", false);
await createBranch("merged1");
await createBranch("unmergedPushed1", false, true);
await createBranch("mergedPushed1", true, true);

await $`cleanup-branches.mjs`;
