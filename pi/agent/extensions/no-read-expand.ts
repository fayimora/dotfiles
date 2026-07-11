import type { ExtensionAPI, ToolRenderResultOptions } from "@earendil-works/pi-coding-agent";
import { createReadToolDefinition } from "@earendil-works/pi-coding-agent";

/**
 * Force the read tool to render as collapsed, even when Pi's global tool
 * expansion state is enabled. This affects only TUI rendering; the tool still
 * returns the full normal result to the model/session.
 */
export default function noReadExpand(pi: ExtensionAPI) {
	const read = createReadToolDefinition(process.cwd());

	pi.registerTool({
		...read,
		renderCall(args, theme, context) {
			return read.renderCall?.(args, theme, {
				...context,
				expanded: false,
			});
		},
		renderResult(result, options, theme, context) {
			return read.renderResult?.(
				result,
				forceCollapsed(options),
				theme,
				{
					...context,
					expanded: false,
				},
			);
		},
	});
}

function forceCollapsed(options: ToolRenderResultOptions): ToolRenderResultOptions {
	return {
		...options,
		expanded: false,
	};
}
