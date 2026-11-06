/**
 * fold-runs: fold each agent run (the tool calls, thinking and turns between your
 * prompt and the final answer) into one summary line.
 *
 *   > your question
 *    ▸ 6 tool calls · 2 reasoning · 3 turns · 1m 12s · 2 files changed · $0.12   bash 3 · read 2 · edit · 48k in / 2.1k out
 *   final answer…
 *
 * Each prompt has three levels; click its summary line (fullscreen mode) to cycle them:
 *   ▸ folded   only the summary line, the final answer and any questions to you
 *   ▿ outline  plus one line per tool call
 *   ▾ full     every step as Pi normally renders it
 *
 * alt+h switches every prompt between folded and full. /fold opens a picker, and
 * /fold <folded|outline|full> sets the default for every prompt directly. Clicks
 * override the default per prompt until the next global change. The default persists in ~/.pi/agent/fold-runs.json.
 * A prompt that ended in an error or abort opens to the outline automatically.
 *
 * Display only: the model and the session file still see everything.
 *
 * Implementation note: wraps render/updateContent/handleMouse on Pi's exported
 * AssistantMessageComponent and ToolExecutionComponent and reads some of their
 * private fields. That is not part of the documented extension contract. If a Pi
 * update breaks those assumptions, the extension restores Pi's normal rendering,
 * shows a warning, and marks the footer "fold-runs off".
 */

import type { ExtensionAPI, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import {
	AssistantMessageComponent,
	getAgentDir,
	ToolExecutionComponent,
	UserMessageComponent,
} from "@earendil-works/pi-coding-agent";
import {
	type AutocompleteProvider,
	type Component,
	type TUI,
	type TuiMouseEvent,
	truncateToWidth,
	visibleWidth,
} from "@earendil-works/pi-tui";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

type Level = "folded" | "outline" | "full";
const LEVELS: readonly Level[] = ["folded", "outline", "full"];
const ARROWS: Record<Level, string> = { folded: "▸", outline: "▿", full: "▾" };

const STATE_FILE = join(getAgentDir(), "fold-runs.json");
const PROBE_WIDGET = "fold-runs-probe";
const STATUS_KEY = "fold-runs";
const MAX_OVERRIDES = 1000;
/**
 * Tools that talk to the user. Their calls, and the text of the message that makes them,
 * are part of the conversation, so they stay visible when folded. Calls that prompt the
 * user at runtime are detected too (see ui_prompt_start below).
 */
const INTERACTIVE_TOOLS = new Set(["ask_user_question", "question", "questionnaire"]);
/** Outline rows right-align their details within this many columns. */
const OUTLINE_WIDTH = 110;

// ---------------------------------------------------------------------------
// Process-wide state. Prototype patches outlive extension reloads, so the state
// and Pi's original methods live on globalThis and every load reuses them.

type State = {
	level: Level;
	busy: boolean;
	broken?: string;
	/** Per-prompt levels chosen by clicking, keyed by a stable id of the prompt's first step. */
	overrides: Map<string, Level>;
	/** Tool call ids that showed the user a prompt while they ran. */
	promptedCalls: Set<string>;
	tui?: TUI;
	getTheme?: () => Theme;
	warn?: (message: string) => void;
	warningTimer?: ReturnType<typeof setTimeout>;
};

type Fn = (...args: any[]) => any;
type Originals = { aUpdate: Fn; aRender: Fn; aMouse: Fn; tRender: Fn; tMouse: Fn };

const g = globalThis as typeof globalThis & {
	__foldRunsState?: State;
	__foldRunsOriginals?: Originals;
	/** Set by this extension's earlier name; reused so a /reload after the rename does not stack patches. */
	__hideStepsState?: State;
	__hideStepsOriginals?: Originals;
};
const state: State = (g.__foldRunsState ??= g.__hideStepsState ?? {
	level: "folded",
	busy: false,
	overrides: new Map(),
	promptedCalls: new Set(),
});
// State created by an older version of this file in the same process lacks newer fields.
state.promptedCalls ??= new Set();

// ---------------------------------------------------------------------------
// Persistence

function loadLevel(): Level {
	try {
		if (!existsSync(STATE_FILE)) return "folded";
		const parsed = JSON.parse(readFileSync(STATE_FILE, "utf8")) as { level?: unknown; hidden?: unknown };
		if (typeof parsed.level === "string" && (LEVELS as readonly string[]).includes(parsed.level)) {
			return parsed.level as Level;
		}
		// Older format: { hidden: boolean }.
		if (typeof parsed.hidden === "boolean") return parsed.hidden ? "folded" : "full";
	} catch {
		// Fall through to the default.
	}
	return "folded";
}

function saveLevel(level: Level): void {
	try {
		writeFileSync(STATE_FILE, `${JSON.stringify({ level }, null, "\t")}\n`);
	} catch {
		// Best effort; the level still applies to this process.
	}
}

// ---------------------------------------------------------------------------
// Private component shapes we read

type Block = { type: string; thinking?: string; id?: string; name?: string };
type Usage = { input?: number; output?: number; cacheRead?: number; cacheWrite?: number; cost?: { total?: number } };
type AssistantMsg = {
	content?: Block[];
	timestamp?: number;
	durationMs?: number;
	usage?: Usage;
	stopReason?: string;
};
type Mode = "full" | "no-thinking";
type AssistantLike = Component & {
	lastMessage?: AssistantMsg;
	isStreaming?: boolean;
	contentContainer?: unknown;
	__hsMode?: Mode;
	__hsHeader?: number;
	updateContent(message: AssistantMsg): void;
};
type ToolLike = Component & {
	toolName?: string;
	toolCallId?: string;
	args?: unknown;
	isPartial?: boolean;
	result?: { isError?: boolean; durationMs?: number; details?: unknown };
	__hsHeader?: number;
};
type ContainerLike = { children: unknown[] };

// ---------------------------------------------------------------------------
// Run analysis: group chat children into prompts and summarize their steps

type Run = {
	leader?: Component;
	key?: string;
	last: boolean;
	turns: number;
	reasoning: number;
	tools: ToolLike[];
	counts: Map<string, number>;
	failed: number;
	files: Set<string>;
	tokensIn: number;
	tokensOut: number;
	cost: number;
	streaming?: AssistantLike;
	live: boolean;
	start?: number;
	end?: number;
	/** Set when the prompt's last response ended badly: "error", "aborted", "truncated". */
	ending?: string;
};

type Placement = { run: Run; isLeader: boolean };

let parents = new WeakMap<object, ContainerLike>();
let frameCache: Map<ContainerLike, Map<object, Placement>> | undefined;

function findParent(comp: object): ContainerLike | undefined {
	const cached = parents.get(comp);
	if (cached?.children.includes(comp)) return cached;
	const root = state.tui as unknown as ContainerLike | undefined;
	if (!root) return undefined;
	const stack: ContainerLike[] = [root];
	while (stack.length > 0) {
		const node = stack.pop()!;
		if (!Array.isArray(node.children)) continue;
		if (node.children.includes(comp)) {
			parents.set(comp, node);
			return node;
		}
		for (const child of node.children) {
			if (child && Array.isArray((child as ContainerLike).children)) stack.push(child as ContainerLike);
		}
	}
	return undefined;
}

function hasToolCalls(message: AssistantMsg | undefined): boolean {
	return Array.isArray(message?.content) && message.content.some((b) => b.type === "toolCall");
}

function countReasoning(message: AssistantMsg | undefined): number {
	// Consecutive thinking blocks form one reasoning run, matching Pi's rendering.
	let runs = 0;
	let inRun = false;
	for (const block of message?.content ?? []) {
		if (block.type !== "thinking") {
			inRun = false;
		} else if (!inRun && block.thinking?.trim()) {
			runs++;
			inRun = true;
		}
	}
	return runs;
}

function endingOf(message: AssistantMsg | undefined): string | undefined {
	switch (message?.stopReason) {
		case "error":
			return "error";
		case "aborted":
			return "aborted";
		case "length":
			return "truncated";
		default:
			return undefined;
	}
}

function isRunning(tool: ToolLike): boolean {
	return !tool.result || tool.isPartial === true;
}

function runKey(leader: Component): string | undefined {
	if (leader instanceof AssistantMessageComponent) {
		const ts = (leader as unknown as AssistantLike).lastMessage?.timestamp;
		return ts === undefined ? undefined : `a:${ts}`;
	}
	const id = (leader as ToolLike).toolCallId;
	return id ? `t:${id}` : undefined;
}

function newRun(): Run {
	return {
		last: false,
		turns: 0,
		reasoning: 0,
		tools: [],
		counts: new Map(),
		failed: 0,
		files: new Set(),
		tokensIn: 0,
		tokensOut: 0,
		cost: 0,
		live: false,
	};
}

function addAssistant(run: Run, comp: AssistantLike): void {
	if (comp.contentContainer === undefined) throw new Error("AssistantMessageComponent internals changed");
	const msg = comp.lastMessage;
	run.turns++;
	run.reasoning += countReasoning(msg);
	if (comp.isStreaming) {
		run.live = true;
		run.streaming = comp;
	}
	if (typeof msg?.timestamp === "number") {
		run.start = Math.min(run.start ?? msg.timestamp, msg.timestamp);
		const end = msg.timestamp + (msg.durationMs ?? 0);
		run.end = Math.max(run.end ?? end, end);
	}
	const usage = msg?.usage;
	if (usage) {
		run.tokensIn += (usage.input ?? 0) + (usage.cacheRead ?? 0) + (usage.cacheWrite ?? 0);
		run.tokensOut += usage.output ?? 0;
		run.cost += usage.cost?.total ?? 0;
	}
	// The latest response decides how the prompt ended.
	run.ending = endingOf(msg);
}

function addTool(run: Run, comp: ToolLike): void {
	if (typeof comp.toolName !== "string") throw new Error("ToolExecutionComponent internals changed");
	const name = comp.toolName;
	run.tools.push(comp);
	run.counts.set(name, (run.counts.get(name) ?? 0) + 1);
	if (isRunning(comp)) {
		run.live = true;
	} else if (comp.result?.isError) {
		run.failed++;
	} else if (name === "edit" || name === "write") {
		const path = stringArg(comp.args, "path");
		if (path) run.files.add(path);
	}
}

function analyze(container: ContainerLike): Map<object, Placement> {
	if (frameCache?.has(container)) return frameCache.get(container)!;
	if (!frameCache) {
		frameCache = new Map();
		// One render frame is synchronous; drop the cache afterwards so stats stay live.
		queueMicrotask(() => {
			frameCache = undefined;
		});
	}

	const placements = new Map<object, Placement>();
	let run = newRun();
	for (const child of container.children) {
		if (child instanceof UserMessageComponent) {
			run = newRun();
			continue;
		}
		if (child instanceof AssistantMessageComponent) addAssistant(run, child as unknown as AssistantLike);
		else if (child instanceof ToolExecutionComponent) addTool(run, child as unknown as ToolLike);
		else continue;

		const isLeader = run.leader === undefined;
		if (isLeader) run.leader = child as Component;
		placements.set(child as object, { run, isLeader });
	}
	run.last = true;
	for (const { run: r, isLeader } of placements.values()) {
		if (isLeader && r.leader) r.key = runKey(r.leader);
	}
	frameCache.set(container, placements);
	return placements;
}

function placementOf(comp: object): Placement | undefined {
	const parent = findParent(comp);
	return parent ? analyze(parent).get(comp) : undefined;
}

function hasSteps(run: Run): boolean {
	return run.tools.length > 0 || run.reasoning > 0 || run.turns > 1;
}

function isLive(run: Run): boolean {
	return run.live || (state.busy && run.last);
}

function effectiveLevel(run: Run): Level {
	const override = run.key ? state.overrides.get(run.key) : undefined;
	if (override) return override;
	// A failed prompt has no real answer to show; open its outline so the failure is visible.
	if (run.ending && !isLive(run) && state.level === "folded") return "outline";
	return state.level;
}

function setOverride(key: string, level: Level): void {
	state.overrides.delete(key);
	state.overrides.set(key, level);
	if (state.overrides.size > MAX_OVERRIDES) {
		const oldest = state.overrides.keys().next().value;
		if (oldest !== undefined) state.overrides.delete(oldest);
	}
}

// ---------------------------------------------------------------------------
// Formatting

function color(name: string, text: string): string {
	const theme = state.getTheme?.();
	return theme ? theme.fg(name as never, text) : text;
}

function plural(n: number, word: string): string {
	return `${n} ${word}${n === 1 ? "" : "s"}`;
}

function formatDuration(ms: number): string {
	const s = Math.max(0, Math.round(ms / 1000));
	if (s < 60) return `${s}s`;
	const m = Math.floor(s / 60);
	if (m < 60) return `${m}m ${s % 60}s`;
	return `${Math.floor(m / 60)}h ${m % 60}m`;
}

function formatStepDuration(ms: number): string {
	return ms < 10_000 ? `${(ms / 1000).toFixed(1)}s` : formatDuration(ms);
}

function formatTokens(n: number): string {
	if (n < 1000) return `${n}`;
	if (n < 1_000_000) return `${(n / 1000).toFixed(n < 10_000 ? 1 : 0)}k`;
	return `${(n / 1_000_000).toFixed(1)}M`;
}

function formatCost(cost: number): string {
	return cost < 0.01 ? "<$0.01" : `$${cost.toFixed(2)}`;
}

function oneLine(text: string): string {
	return text.slice(0, 400).replace(/\s+/g, " ").trim();
}

function shortPath(path: string): string {
	const home = homedir();
	return path.startsWith(home) ? `~${path.slice(home.length)}` : path;
}

function stringArg(args: unknown, key: string): string | undefined {
	if (!args || typeof args !== "object") return undefined;
	const value = (args as Record<string, unknown>)[key];
	return typeof value === "string" && value.trim() ? value : undefined;
}

/** A short description of what a tool call does, e.g. its command or path. */
function describeCall(name: string, args: unknown): string {
	if (!args || typeof args !== "object") return "";
	const a = args as Record<string, unknown>;
	const arg = (key: string) => stringArg(args, key);

	if (name === "read") {
		const path = arg("path");
		if (!path) return "";
		const offset = typeof a.offset === "number" ? a.offset : undefined;
		const limit = typeof a.limit === "number" ? a.limit : undefined;
		if (offset === undefined && limit === undefined) return shortPath(path);
		const from = offset ?? 1;
		return `${shortPath(path)}:${from}${limit ? `-${from + limit - 1}` : ""}`;
	}
	if (name === "codemode") {
		const line = (arg("code") ?? "")
			.split("\n")
			.map((l) => l.trim())
			.find((l) => l && !l.startsWith("//"));
		return line ? oneLine(line) : "";
	}

	const path = arg("path") ?? arg("file_path") ?? arg("file");
	const main =
		arg("command") ?? arg("pattern") ?? arg("query") ?? arg("url") ?? arg("name") ?? arg("task") ?? arg("prompt");
	if (main && path && path !== ".") return `${oneLine(main)}  ${shortPath(path)}`;
	if (main) return oneLine(main);
	if (path) return shortPath(path);
	const first = Object.values(a).find((v): v is string => typeof v === "string" && v.trim() !== "");
	return first ? oneLine(first) : "";
}

/** What the agent is doing right now, for the running summary line. */
function currentStep(run: Run): string {
	for (let i = run.tools.length - 1; i >= 0; i--) {
		const tool = run.tools[i]!;
		if (isRunning(tool)) {
			const name = tool.toolName ?? "tool";
			return truncateToWidth(`${name} ${describeCall(name, tool.args)}`.trim(), 48);
		}
	}
	const content = run.streaming?.lastMessage?.content;
	switch (content?.[content.length - 1]?.type) {
		case "thinking":
			return "thinking";
		case "text":
			return "writing";
		case "toolCall":
			return "preparing tool call";
		default:
			return "";
	}
}

function diffStat(tool: ToolLike): string {
	if (isRunning(tool) || tool.result?.isError) return "";
	if (tool.toolName === "edit") {
		const details = tool.result?.details as { diff?: unknown } | undefined;
		if (typeof details?.diff !== "string") return "";
		let added = 0;
		let removed = 0;
		for (const line of details.diff.split("\n")) {
			if (line.startsWith("+")) added++;
			else if (line.startsWith("-")) removed++;
		}
		return `${color("success", `+${added}`)} ${color("error", `−${removed}`)}`;
	}
	if (tool.toolName === "write") {
		const content = stringArg(tool.args, "content");
		return content ? color("dim", plural(content.split("\n").length, "line")) : "";
	}
	return "";
}

/** Left text, then right text aligned to the right edge of the outline area. */
function joinRow(left: string, right: string, width: number): string {
	if (!right) return truncateToWidth(left, width);
	const area = Math.min(width, OUTLINE_WIDTH);
	const rightWidth = visibleWidth(right);
	const room = area - rightWidth - 2;
	if (room < 20) return truncateToWidth(`${left}  ${right}`, width);
	const shown = truncateToWidth(left, room);
	return shown + " ".repeat(Math.max(2, area - visibleWidth(shown) - rightWidth)) + right;
}

function outlineLines(run: Run, width: number): string[] {
	if (run.tools.length === 0) return [];
	const nameWidth = Math.min(12, Math.max(...run.tools.map((t) => (t.toolName ?? "tool").length)));
	return run.tools.map((tool) => {
		const name = tool.toolName ?? "tool";
		const running = isRunning(tool);
		const mark = running ? color("accent", "◌") : tool.result?.isError ? color("error", "✗") : color("dim", "·");
		const left = `   ${mark} ${color("muted", name.padEnd(nameWidth))} ${color("toolOutput", describeCall(name, tool.args))}`;
		const details: string[] = [];
		const diff = diffStat(tool);
		if (diff) details.push(diff);
		const ms = tool.result?.durationMs;
		if (!running && ms !== undefined && ms >= 1000) details.push(color("dim", formatStepDuration(ms)));
		return joinRow(left, details.join("  "), width);
	});
}

function headerLines(run: Run, level: Level, width: number): string[] {
	const live = isLive(run);
	const parts: string[] = [];
	if (run.tools.length > 0) parts.push(plural(run.tools.length, "tool call"));
	if (run.reasoning > 0) parts.push(`${run.reasoning} reasoning`);
	if (run.turns > 1) parts.push(plural(run.turns, "turn"));
	if (live) {
		const elapsed = run.start === undefined ? "" : ` ${formatDuration(Date.now() - run.start)}`;
		const step = currentStep(run);
		parts.push(`running${elapsed}${step ? ` · ${step}` : ""}`);
	} else if (run.start !== undefined && run.end !== undefined) {
		parts.push(formatDuration(run.end - run.start));
	}
	if (run.files.size > 0) parts.push(`${plural(run.files.size, "file")} changed`);
	if (run.cost > 0) parts.push(formatCost(run.cost));

	const sep = color("muted", " · ");
	let line = ` ${color("accent", ARROWS[level])} ${color("muted", parts.join(" · "))}`;
	if (run.failed > 0) line += sep + color("error", `${run.failed} failed`);
	if (run.ending && !live) line += sep + color("error", run.ending);

	const breakdown = [...run.counts.entries()]
		.sort((a, b) => b[1] - a[1])
		.map(([name, n]) => (n > 1 ? `${name} ${n}` : name));
	if (run.tokensIn + run.tokensOut > 0) {
		breakdown.push(`${formatTokens(run.tokensIn)} in / ${formatTokens(run.tokensOut)} out`);
	}
	if (breakdown.length > 0) line += `   ${color("dim", breakdown.join(" · "))}`;

	const lines = ["", truncateToWidth(line, width)];
	if (level === "outline") lines.push(...outlineLines(run, width));
	return lines;
}

// ---------------------------------------------------------------------------
// Component patches

type Plan = { run: Run; header?: Run; level: Level; showBody: boolean };

function layout(comp: object): Plan | null {
	const placement = placementOf(comp);
	if (!placement) return null;
	const { run, isLeader } = placement;
	const level = effectiveLevel(run);
	const header = isLeader && hasSteps(run) ? run : undefined;
	if (level === "full") return { run, header, level, showBody: true };
	// Folded and outline keep only the conversation: final answers and exchanges with the user.
	return { run, header, level, showBody: isConversation(comp) };
}

function isInteractive(name: string | undefined, id: string | undefined): boolean {
	return (name !== undefined && INTERACTIVE_TOOLS.has(name)) || (id !== undefined && state.promptedCalls.has(id));
}

/**
 * An assistant message is conversation when it has no tool calls (a final answer) or one of
 * its tool calls talks to the user, e.g. text that introduces a question. A tool call is
 * conversation when it talks to the user, so the question and answer stay visible.
 */
function isConversation(comp: object): boolean {
	if (comp instanceof AssistantMessageComponent) {
		const content = (comp as unknown as AssistantLike).lastMessage?.content ?? [];
		const calls = content.filter((b) => b.type === "toolCall");
		return calls.length === 0 || calls.some((b) => isInteractive(b.name, b.id));
	}
	const tool = comp as ToolLike;
	return isInteractive(tool.toolName, tool.toolCallId);
}

function withHeader(comp: { __hsHeader?: number }, plan: Plan | null, body: string[], width: number): string[] {
	if (!plan?.header) {
		comp.__hsHeader = 0;
		return body;
	}
	const header = headerLines(plan.header, plan.level, width);
	comp.__hsHeader = header.length;
	return [...header, ...body];
}

function filterContent(message: AssistantMsg, mode: Mode): AssistantMsg {
	if (mode === "full" || !Array.isArray(message?.content)) return message;
	return { ...message, content: message.content.filter((b) => b.type !== "thinking") };
}

/** Re-run Pi's content build when the wanted thinking mode changed since the last build. */
function ensureMode(comp: AssistantLike, mode: Mode): void {
	if ((comp.__hsMode ?? "full") === mode) return;
	comp.__hsMode = mode;
	if (comp.lastMessage) comp.updateContent(comp.lastMessage);
}

function refresh(): void {
	state.tui?.invalidate();
	state.tui?.requestRender(true);
}

/** Turn the extension off and fall back to Pi's own rendering. */
function disable(reason: string): void {
	if (state.broken) return;
	state.broken = reason;
	// Rendering may be in progress; notify and redraw afterwards.
	state.warningTimer = setTimeout(() => {
		state.warningTimer = undefined;
		state.warn?.(`fold-runs disabled (${reason}). Pi's internals may have changed; see fold-runs.ts.`);
		refresh();
	}, 0);
}

function guarded<T>(fallback: () => T, run: () => T): T {
	if (!state.tui || state.broken) return fallback();
	try {
		return run();
	} catch (error) {
		disable(error instanceof Error ? error.message : String(error));
		return fallback();
	}
}

/** Patch the prototypes. Always wraps Pi's original methods, so reloading replaces rather than stacks. */
function installPatches(): string | undefined {
	const ap = AssistantMessageComponent?.prototype as unknown as Record<string, Fn> | undefined;
	const tp = ToolExecutionComponent?.prototype as unknown as Record<string, Fn> | undefined;
	if (!ap || !tp || typeof UserMessageComponent !== "function") return "chat components are no longer exported";
	for (const [proto, label, names] of [
		[ap, "AssistantMessageComponent", ["updateContent", "render", "handleMouse"]],
		[tp, "ToolExecutionComponent", ["render", "handleMouse"]],
	] as const) {
		for (const name of names) {
			if (typeof proto[name] !== "function") return `${label}.${name} is missing`;
		}
	}

	const o = (g.__foldRunsOriginals ??= g.__hideStepsOriginals ?? {
		aUpdate: ap.updateContent!,
		aRender: ap.render!,
		aMouse: ap.handleMouse!,
		tRender: tp.render!,
		tMouse: tp.handleMouse!,
	});

	ap.updateContent = function (this: AssistantLike, message: AssistantMsg, ...rest: unknown[]) {
		const mode = !state.tui || state.broken ? "full" : (this.__hsMode ?? "full");
		o.aUpdate.call(this, filterContent(message, mode), ...rest);
		// Keep the real message so stats, unfolding and other readers see full content.
		this.lastMessage = message;
	};

	ap.render = function (this: AssistantLike, width: number) {
		return guarded(
			() => {
				try {
					ensureMode(this, "full");
				} catch {
					// Already falling back.
				}
				return o.aRender.call(this, width);
			},
			() => {
				const plan = layout(this);
				ensureMode(this, plan && plan.level !== "full" ? "no-thinking" : "full");
				const body = !plan || plan.showBody ? o.aRender.call(this, width) : [];
				return withHeader(this, plan, body, width);
			},
		);
	};

	tp.render = function (this: ToolLike, width: number) {
		return guarded(
			() => o.tRender.call(this, width),
			() => {
				const plan = layout(this);
				const body = !plan || plan.showBody ? o.tRender.call(this, width) : [];
				return withHeader(this, plan, body, width);
			},
		);
	};

	/** Clicks on the summary area cycle the prompt's level; other clicks reach the body at corrected offsets. */
	const wrapMouse = (original: Fn) =>
		function (this: Component & { __hsHeader?: number }, event: TuiMouseEvent) {
			return guarded(
				() => original.call(this, event),
				() => {
					const plan = layout(this);
					const headerHeight = plan?.header ? (this.__hsHeader ?? 0) : 0;
					if (!plan || headerHeight === 0) return !plan || plan.showBody ? original.call(this, event) : undefined;
					if (event.y < headerHeight) {
						if (event.type !== "click" || event.button !== "left" || !plan.run.key) return undefined;
						const next = LEVELS[(LEVELS.indexOf(plan.level) + 1) % LEVELS.length]!;
						setOverride(plan.run.key, next);
						return { handled: true };
					}
					if (!plan.showBody) return undefined;
					return original.call(this, {
						...event,
						y: event.y - headerHeight,
						height: event.height - headerHeight,
					});
				},
			);
		};
	ap.handleMouse = wrapMouse(o.aMouse);
	tp.handleMouse = wrapMouse(o.tMouse);
	return undefined;
}

// ---------------------------------------------------------------------------
// Extension wiring

/** Prototype patches survive reloads, but session contexts and TUI references must not. */
function releaseSession(): void {
	if (state.warningTimer !== undefined) clearTimeout(state.warningTimer);
	state.warningTimer = undefined;
	state.getTheme = undefined;
	state.warn = undefined;
	state.tui = undefined;
	state.busy = false;
	parents = new WeakMap();
	frameCache = undefined;
}

/** Grab the TUI through a throwaway widget so we can find the chat and force re-renders. */
function captureTui(ctx: ExtensionContext): void {
	if (state.tui) return;
	ctx.ui.setWidget(PROBE_WIDGET, (tui) => {
		state.tui = tui;
		return { render: () => [], invalidate() {} };
	});
	ctx.ui.setWidget(PROBE_WIDGET, undefined);
}

const LEVEL_DESCRIPTIONS: Record<Level, string> = {
	folded: "summary line and final answer",
	outline: "plus one line per tool call",
	full: "every step, as Pi normally shows it",
};

/** Let the user choose a level; the current one is marked and listed first. Returns null when cancelled. */
async function pickLevel(ctx: ExtensionContext): Promise<Level | null> {
	const ordered = [state.level, ...LEVELS.filter((l) => l !== state.level)];
	const options = ordered.map(
		(l) => `${ARROWS[l]} ${l.padEnd(8)} ${LEVEL_DESCRIPTIONS[l]}${l === state.level ? "  (current)" : ""}`,
	);
	const choice = await ctx.ui.select("Show agent runs as", options);
	if (choice === undefined) return null;
	return ordered[options.indexOf(choice)] ?? null;
}

/**
 * Pi lists argument completions only after "/fold " plus a typed character, so also list
 * "fold folded", "fold outline" and "fold full" right under "fold" in the command menu.
 */
function withLevelCommands(current: AutocompleteProvider): AutocompleteProvider {
	return {
		triggerCharacters: current.triggerCharacters,
		async getSuggestions(lines, cursorLine, cursorCol, options) {
			const result = await current.getSuggestions(lines, cursorLine, cursorCol, options);
			if (!result?.prefix.startsWith("/") || result.prefix.includes(" ")) return result;
			const index = result.items.findIndex((item) => item.value === "fold");
			if (index === -1) return result;
			const levels = LEVELS.map((l) => ({
				value: `fold ${l}`,
				label: `fold ${l}`,
				description: LEVEL_DESCRIPTIONS[l],
			}));
			return { ...result, items: [...result.items.slice(0, index + 1), ...levels, ...result.items.slice(index + 1)] };
		},
		applyCompletion: (lines, cursorLine, cursorCol, item, prefix) =>
			current.applyCompletion(lines, cursorLine, cursorCol, item, prefix),
		shouldTriggerFileCompletion: current.shouldTriggerFileCompletion
			? (lines, cursorLine, cursorCol) => current.shouldTriggerFileCompletion!(lines, cursorLine, cursorCol)
			: undefined,
	};
}

function parseLevel(arg: string): Level | undefined {
	const value = arg.trim().toLowerCase();
	if (value === "hide" || value === "fold") return "folded";
	if (value === "show") return "full";
	return (LEVELS as readonly string[]).includes(value) ? (value as Level) : undefined;
}

export default function foldRuns(pi: ExtensionAPI) {
	const showStatus = (ctx: ExtensionContext) => {
		const theme = ctx.ui.theme;
		const text = state.broken
			? theme.fg("warning", "fold-runs off")
			: state.level === "full"
				? undefined
				: theme.fg("dim", `runs ${state.level}`);
		ctx.ui.setStatus(STATUS_KEY, text);
	};

	const setLevel = (level: Level, ctx: ExtensionContext) => {
		state.level = level;
		// A global change applies to every prompt, so forget per-prompt clicks.
		state.overrides.clear();
		saveLevel(level);
		refresh();
		showStatus(ctx);
	};

	pi.on("session_start", async (_event, ctx) => {
		// Also discard references inherited from older versions without shutdown cleanup.
		releaseSession();
		if (ctx.mode !== "tui" || !ctx.hasUI) return;
		state.level = loadLevel();
		state.broken = undefined;
		state.getTheme = () => ctx.ui.theme;
		state.warn = (message) => {
			ctx.ui.notify(message, "warning");
			showStatus(ctx);
		};
		const problem = installPatches();
		if (problem) disable(problem);
		ctx.ui.addAutocompleteProvider(withLevelCommands);
		captureTui(ctx);
		refresh();
		showStatus(ctx);
	});

	// Remember which tool calls prompt the user: a prompt that opens while a call runs belongs to it.
	const runningCalls = new Set<string>();
	pi.on("session_shutdown", () => {
		releaseSession();
		runningCalls.clear();
	});
	pi.on("tool_execution_start", async (event) => {
		runningCalls.add(event.toolCallId);
	});
	pi.on("tool_execution_end", async (event) => {
		runningCalls.delete(event.toolCallId);
	});
	pi.on("ui_prompt_start", async () => {
		if (runningCalls.size === 0) return;
		for (const id of runningCalls) state.promptedCalls.add(id);
		while (state.promptedCalls.size > MAX_OVERRIDES) {
			const oldest = state.promptedCalls.values().next().value;
			if (oldest === undefined) break;
			state.promptedCalls.delete(oldest);
		}
		refresh();
	});

	pi.on("agent_start", async () => {
		state.busy = true;
	});
	pi.on("agent_settled", async () => {
		state.busy = false;
		state.tui?.requestRender();
	});

	pi.registerShortcut("alt+h", {
		description: "Fold or unfold every agent run",
		handler: (ctx) => {
			if (ctx.mode !== "tui") return;
			setLevel(state.level === "folded" ? "full" : "folded", ctx);
		},
	});

	pi.registerCommand("fold", {
		description: "Set how agent runs show: /fold [folded|outline|full]",
		getArgumentCompletions: (prefix) =>
			LEVELS.filter((v) => v.startsWith(prefix.trim())).map((v) => ({
				value: v,
				label: v,
				description: LEVEL_DESCRIPTIONS[v],
			})),
		handler: async (args, ctx) => {
			if (ctx.mode !== "tui") {
				ctx.ui.notify("/fold requires interactive mode", "error");
				return;
			}
			const level = args.trim() ? parseLevel(args) : await pickLevel(ctx);
			if (level === null) return; // Picker cancelled.
			if (!level) {
				ctx.ui.notify("Usage: /fold [folded|outline|full]", "error");
				return;
			}
			setLevel(level, ctx);
		},
	});
}
