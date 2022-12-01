#!/usr/bin/env npx --yes tsx

import { spawnSync, SpawnSyncOptions } from "child_process";

const run = (command: string) => {
  const options: SpawnSyncOptions = {
    encoding: "utf8",
  };
  const commandParts = command.split(" ");
  const [cmd, ...rest] = commandParts;
  const ls = spawnSync(cmd, rest, options);
  if (ls.error) {
    throw ls.error;
  }
  if (ls.stderr) {
    console.log(`stderr: ${ls.stderr.toString()}`);
    process.exit(1);
  }
  if (ls.stdout) {
    console.log(`stdout: ${ls.stdout.toString()}`);
  }
  return ls.stdout;
};

run("git update-index --no-skip-worktree .vscode/settings.json");
