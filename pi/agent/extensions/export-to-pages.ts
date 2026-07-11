/**
 * /export-to-pages [title] — export the CURRENT session to HTML and publish it
 * to ~/Code/html-pages/src/pi-exports/, updating the index page.
 *
 * Uses ctx.sessionManager.getSessionFile() so it always targets the session
 * it runs in — no "most recent file" guessing.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("export-to-pages", {
    description: "Export current session to HTML into html-pages and update the index",
    handler: async (args, ctx) => {
      const sessionFile = ctx.sessionManager.getSessionFile();
      if (!sessionFile) {
        ctx.ui.notify("Session is ephemeral (--no-session) — nothing to export.", "error");
        return;
      }

      const title = args?.trim();
      pi.sendUserMessage(
        `Export this session to HTML and publish it to my html-pages site.

The current session file is exactly: ${sessionFile}

Steps:
1. Derive a short kebab-case slug${title ? ` from the title "${title}"` : " from the session topic"}.
2. Run: pi --export "${sessionFile}" ~/Code/html-pages/src/pi-exports/<slug>.html
3. Update ~/Code/html-pages/src/pi-exports/index.html:
   - Read it first, then add an entry for the new export at the top of the list, following whatever format the existing entries use.
   - Title it ${title ? `"${title}"` : "with a concise human-readable title derived from the session topic"}.
   - Keep any counts or metadata on the page consistent.
4. In ~/Code/html-pages, commit the new export and index change with a short descriptive message, and push.
5. Confirm the final path and index entry. Note that the export only includes messages up to the export moment.`,
      );
    },
  });
}
