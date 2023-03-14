#!/usr/bin/env ts-node --swc --esm

// running ts-node via npx
//#!/usr/bin/env npx --yes ts-node --swc --esm

// running ts-node -directly
// #!/usr/bin/env ts-node --swc --esm

import { run } from "./common.mjs";

const toplevel = run("git rev-parse --show-toplevel");
[
  `git update-index --skip-worktree ${toplevel}/.vscode/settings.json`,
  `git update-index --skip-worktree ${toplevel}/packages/rn/features/identity/src/hooks/use-is-authenticated/use-is-authenticated.ts`,
].forEach((cmd) => {
  const stdout = run(cmd);
  if (stdout) {
    console.log(stdout);
  }
});
