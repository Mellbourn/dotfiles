#!/usr/bin/env zx

cd(`${$.env.HOME}/code/experiments/`);
const repo = "cleanup-branches-test";

// the following was an attempt to delete the repo, but that was too difficult
// try {
//   await $`trash ${repo}`;
//   await $`gh auth refresh -h github.com -s delete_repo`;
//   await $`gh repo delete --confirm ${repo}`;
// } catch (p) {
//   console.log(`No repo to delete (${p.exitCode})`);
// }

await $`mkdir -p ${repo}`;
let repoExists = false;
try {
  await $`gh repo view ${repo}`;
  repoExists = true;
} catch (p) {}
if (!repoExists) {
  await $`gh repo create ${repo} --public -c -d 'repo for testing cleanup-branches.mjs'`;
}
cd(repo);

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
  await $`git switch main`;
  if (await branchExists(name)) {
    try {
      await $`git push origin --delete ${name}`;
    } catch (p) {
      console.log(`No branch to delete (${p.exitCode})`);
    }
    await $`git branch -D ${name}`;
  }
  await $`git switch -c ${name}`;
  if (!isMerged) {
    await addCommittedFile(`${name}.txt`);
  }
  if (isPushed) {
    await $`git push --force -u origin ${name}`;
  }
  await $`git switch main`;
};

if (await branchExists("main")) {
  await $`git switch main`;
}
await $`git reset --hard $(git log --reverse --format=%H|head -1)`;
await $`git cleanup-all`;
await addCommittedFile("firstFile.txt");
await $`git push -u origin main`;

await createBranch("unmerged1", false);
await createBranch("merged1");
await createBranch("unmergedPushed1", false, true);
await createBranch("mergedPushed1", true, true);

await createBranch("current");
await $`git switch current`;

console.log(chalk.bold("****************** ACT **********************"));

await $`echo $(yes n | cleanup-branches.mjs)`;

console.log(chalk.bold("****************** ASSERT *******************"));

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

console.log(chalk.bold("****************** REPORT ********************"));
await $`git lol --color=always`;
