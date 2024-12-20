import { spawnSync, SpawnSyncOptions } from "child_process";

export const run = (command: string): string => {
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
