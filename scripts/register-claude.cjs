// Registers the After Effects MCP ("after-effects-local") at user scope in Claude Code's config.
// Usage: node register-claude.cjs <claudeConfigPath> <installRoot> <afterFxExe> <dispatcherPath> <readOnly 0|1>
// Backs up the config first, writes atomically, and changes only the after-effects-local entry.
"use strict";
const fs = require("fs");
const path = require("path");

const [configPath, installRoot, aeExe, dispatcher, readOnly] = process.argv.slice(2);
if (!configPath || !installRoot || !aeExe || !dispatcher || !["0", "1"].includes(readOnly)) {
  console.error("usage: register-claude.cjs <claudeConfig> <installRoot> <AfterFX.exe> <dispatcher.jsx> <0|1>");
  process.exit(2);
}
const slash = (p) => p.replace(/\\/g, "/");
for (const p of [path.join(installRoot, "runtime", "node.exe"), path.join(installRoot, "server.mjs"), aeExe, dispatcher]) {
  if (!fs.existsSync(p)) { console.error("missing required file: " + p); process.exit(3); }
}

let config = {};
if (fs.existsSync(configPath)) {
  const raw = fs.readFileSync(configPath, "utf8");
  try { config = raw.trim() ? JSON.parse(raw) : {}; }
  catch (e) { console.error("Claude config is not valid JSON; nothing changed: " + e.message); process.exit(4); }
  const stamp = new Date().toISOString().replace(/[:.]/g, "-");
  const backup = `${configPath}.before-after-effects-mcp-${stamp}`;
  fs.copyFileSync(configPath, backup);
  console.log("config backup: " + backup);
}

config.mcpServers = config.mcpServers || {};
const previous = config.mcpServers["after-effects-local"];
const entry = {
  type: "stdio",
  command: slash(path.join(installRoot, "runtime", "node.exe")),
  args: [slash(path.join(installRoot, "server.mjs"))],
  env: {
    AE_MCP_EXE: slash(aeExe),
    AE_MCP_DISPATCHER: slash(dispatcher),
    AE_MCP_READONLY: readOnly,
    AE_MCP_ENABLE_EVAL: "0",
    AE_MCP_ALLOW_CATEGORIES: "",
    AE_MCP_RUNTIME_DIR: ""
  }
};
if (previous) console.log("replacing existing after-effects-local entry: " + JSON.stringify(previous));
config.mcpServers["after-effects-local"] = entry;

fs.mkdirSync(path.dirname(configPath), { recursive: true });
const tmp = configPath + ".after-effects-mcp.tmp";
fs.writeFileSync(tmp, JSON.stringify(config, null, 2));
fs.renameSync(tmp, configPath);

const check = JSON.parse(fs.readFileSync(configPath, "utf8")).mcpServers["after-effects-local"];
console.log("registered after-effects-local (read-only " + (check.env.AE_MCP_READONLY === "1" ? "ON" : "OFF") + ")");
