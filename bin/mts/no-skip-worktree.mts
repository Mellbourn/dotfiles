#!/usr/bin/env tsx

// running tsx directly
// #!/usr/bin/env tsx

// non-install alternative
// #!/usr/bin/env npx --yes tsx

import { run } from "./common.mjs";

import yargs from "yargs/yargs";

const argv = yargs(process.argv.slice(2)).options({
  a: { type: "boolean", default: false },
  b: { type: "string", demandOption: true },
  c: { type: "number", alias: "chill" },
  d: { type: "array" },
  e: { type: "count" },
  f: { choices: ["1", "2", "3"] },
}).argv;

console.log("argv", argv);

const toplevel = run("git rev-parse --show-toplevel");
const stdout = run(
  `git update-index --no-skip-worktree ${toplevel}/.vscode/settings.json`
);
if (stdout) {
  console.log(stdout);
}
