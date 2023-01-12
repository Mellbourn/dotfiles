#!/usr/bin/env ts-node --swc --esm

// running ts-node via npx
//#!/usr/bin/env npx --yes ts-node --swc --esm

// running ts-node -directly
// #!/usr/bin/env ts-node --swc --esm

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
  `git update-index --skip-worktree ${toplevel}/.vscode/settings.json`
);
if (stdout) {
  console.log(stdout);
}
