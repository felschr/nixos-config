# Global instructions

These are personal defaults for every repository. A project-level `AGENTS.md` or
`CLAUDE.md` overrides anything here that conflicts with it.

## Working style

- Do the smallest change that fully solves the task. No speculative abstractions,
  configurability, or "while I'm here" cleanups.
- Match the conventions of the surrounding code: naming, structure, error
  handling, and comment density.
- Write comments only where they document non-obvious behavior or intent, and
  keep them brief. Never restate what the code already says.
- Do not add documentation, README sections, or new `AGENTS.md` files unless
  asked. Never write a summary of your own change into a doc.
- Do not use em dashes (—) in prose, comments, or commit messages. Use a comma,
  colon, or parentheses instead.
- Keep replies short. State assumptions and tradeoffs; ask when a decision is
  genuinely ambiguous instead of silently picking one.
- Report what actually happened, including failures. Do not claim a build, test,
  or command succeeded unless you ran it and saw it succeed; if it could not run,
  say why.

## Sandbox

- The session runs inside the `nono` sandbox. "Operation not permitted",
  "Permission denied", `EACCES`, and `EPERM` are usually sandbox denials, not Unix
  permission problems. Never suggest `sudo`, `chmod`, `chown`, or macOS Full Disk
  Access for them. Diagnose with
  `nono why --self --path <path> --op <read|write|readwrite>` and present the
  `nono run --allow` / profile-draft options from its output.
- Never print, echo, or move secrets, API keys, or tokens. Credentials are
  injected by the sandbox proxy; read them only through the tool that needs them.

## Git

- Write commit messages in Conventional Commits format and keep them brief: a
  short subject line, plus a body only when the reason for the change is not
  obvious from the diff.
- Never commit, amend, push, tag, or rewrite history unless explicitly asked.
  Never force-push or rewrite published history.
- Stage only files related to the requested change; leave unrelated working-tree
  edits alone.

## Tools

- Prefer the dedicated file tools (read, edit, write, glob, grep) over shell
  equivalents, and run independent commands in parallel.
- Do not chain shell commands with separators such as `echo "====";` purely to
  decorate output.
