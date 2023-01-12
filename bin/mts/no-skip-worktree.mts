#!/usr/bin/env tsx

// running tsx directly
// #!/usr/bin/env tsx

// non-install alternative
// #!/usr/bin/env npx --yes tsx

import { run } from "./common.mjs";

const toplevel = run("git rev-parse --show-toplevel");
const stdout = run(
  `git update-index --no-skip-worktree ${toplevel}/.vscode/settings.json`
);
if (stdout) {
  console.log(stdout);
}
