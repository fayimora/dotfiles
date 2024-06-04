local present, null_ls = pcall(require, "null-ls")

if not present then
	return
end

local b = null_ls.builtins

local prettier_filetypes = {
	-- "javascript",
	-- "javascriptreact",
	-- "typescript",
	-- "typescriptreact",
	"vue",
	"css",
	"scss",
	"less",
	"html",
	-- "json",
	"jsonc",
	"yaml",
	"markdown",
	"markdown.mdx",
	"graphql",
	"handlebars",
}

local sources = {

	-- webdev stuff
	b.formatting.deno_fmt, -- choosed deno for ts/js files cuz its very fast!
	b.formatting.prettier.with({ filetypes = prettier_filetypes }), -- so prettier works only on these filetypes

	-- Lua
	b.formatting.stylua,

	-- cpp
	b.formatting.clang_format,

	b.formatting.scalafmt,

	b.diagnostics.checkstyle.with({
		extra_args = { "-c", "/google_checks.xml" }, -- or "/sun_checks.xml" or path to self written rules
	}),
}

null_ls.setup({
	debug = true,
	sources = sources,
})
