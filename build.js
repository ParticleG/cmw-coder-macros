import { copyFile, mkdir, readFile, readdir, writeFile } from "fs/promises";
import { join } from "path";

import packageJson from "./package.json" assert {type: "json"};

const outDir = "dist";

try {
  await mkdir(outDir);
} catch (_) { }

await writeFile(
  join(outDir, "CMWCODER.em"),
  (await Promise.all(
    (
      await readdir("src")
    ).map((file) => readFile(join("src", file), { flag: "r" }))
  )).join("\n").replace(/%PLUGIN_VERSION%/g, packageJson.version)
);

await copyFile("editorInfo.vbs", join(outDir, "editorInfo.vbs"));
