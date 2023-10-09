import { mkdir, readFile, readdir, writeFile } from "fs/promises";
import { join } from "path";

const outDir = "dist";

try {
  await mkdir(outDir);
} catch (_) {}

await writeFile(
  join(outDir, "CMWCODER.em"),
  await Promise.all(
    (
      await readdir("src")
    ).map((file) => readFile(join("src", file), { flag: "r" }))
  )
);
