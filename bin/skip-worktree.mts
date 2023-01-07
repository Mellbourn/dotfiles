#!/usr/bin/env ts-node --swc --esm

// running ts-node via npx
//#!/usr/bin/env npx --yes ts-node --swc --esm

// running ts-node -directly
// #!/usr/bin/env ts-node --swc --esm

import { spawnSync, SpawnSyncOptions } from "child_process";

const run = (command: string): string => {
  const options: SpawnSyncOptions = {
    encoding: "utf8",
  };
  const commandParts = command.split(" ");
  const [cmd, ...rest] = commandParts;
  const child = spawnSync(cmd, rest, options);
  if (child.error) {
    throw child.error;
  }
  if (child.status !== 0) {
    console.log(child.stdout);
    console.error(`stderr: ${child.stderr.toString()}`);
    process.exit(child.status || 1);
  }
  if (typeof child.stdout !== "string")
    throw new Error("child.stdout is not a string: " + child.stdout);
  return child.stdout.trim();
};

const toplevel = run("git rev-parse --show-toplevel");
const stdout = run(
  `git update-index --skip-worktree ${toplevel}/.vscode/settings.json`
);
if (stdout) {
  console.log(stdout);
}
