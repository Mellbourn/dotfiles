#!/usr/bin/env ts-node --swc --esm

// running ts-node via npx
//#!/usr/bin/env npx --yes ts-node --swc --esm

// running ts-node -directly
// #!/usr/bin/env ts-node --swc --esm

import { run } from "./common.mjs";

const toplevel = run("git rev-parse --show-toplevel");
[
  `git update-index --skip-worktree ${toplevel}/.vscode/settings.json`,
  `git update-index --skip-worktree ${toplevel}/.vscode/launch.json`,
  `git update-index --skip-worktree ${toplevel}/apps/flexiapp-e2e/.detoxrc.json`,
  `git update-index --skip-worktree ${toplevel}/apps/firstvet-auth/package-lock.json`,
  `git update-index --skip-worktree ${toplevel}/apps/flexiapp/ios/Podfile.lock`,
].forEach((cmd) => {
  const stdout = run(cmd);
  if (stdout) {
    console.log(stdout);
  }
});
