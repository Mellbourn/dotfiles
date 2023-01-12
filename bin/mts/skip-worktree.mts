#!/usr/bin/env ts-node --swc --esm

// running ts-node via npx
//#!/usr/bin/env npx --yes ts-node --swc --esm

// running ts-node -directly
// #!/usr/bin/env ts-node --swc --esm

import { run } from "./common.mjs";

const toplevel = run("git rev-parse --show-toplevel");
const stdout = run(
  `git update-index --skip-worktree ${toplevel}/.vscode/settings.json`
);
if (stdout) {
  console.log(stdout);
}
