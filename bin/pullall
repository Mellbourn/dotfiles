#!/usr/bin/env zx

import { readdirSync } from "fs";
import path from "path";

const getDirectories = (source) =>
  readdirSync(source, { withFileTypes: true })
    .filter((dirent) => dirent.isDirectory())
    .filter((dirent) => dirent.name !== ".bare" && dirent.name !== ".vscode")
    .map((dirent) => dirent.name);

const baseDir = path.join($.env.CODE_DIR, "firstvet/monorepo");

const repos = getDirectories(baseDir).map((repo) => path.join(baseDir, repo));

for (const repo of repos) {
  console.log(`Pulling ${repo}`);
  try {
    await $`pushd ${repo} && git pull; popd`;
  } catch (e) {
    console.warn(`Failed to pull ${repo}, error: ${e.stderr}`);
  }
}
