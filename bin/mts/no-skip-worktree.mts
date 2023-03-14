#!/usr/bin/env tsx

// running tsx directly
// #!/usr/bin/env tsx

// non-install alternative
// #!/usr/bin/env npx --yes tsx

import { run } from "./common.mjs";

const toplevel = run("git rev-parse --show-toplevel");
[
  `git update-index --no-skip-worktree ${toplevel}/.vscode/settings.json`,
  `git update-index --no-skip-worktree ${toplevel}/packages/rn/features/identity/src/hooks/use-is-authenticated/use-is-authenticated.ts`,
].forEach((cmd) => {
  const stdout = run(cmd);
  if (stdout) {
    console.log(stdout);
  }
});
