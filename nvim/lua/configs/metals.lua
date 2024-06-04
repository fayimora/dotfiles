local metals_config = require("metals").bare_config()

-- Example of settings
metals_config.settings = {
  serverVersion = "latest.snapshot",
  showImplicitArguments = true,
  showInferredType = true,
  superMethodLensesEnabled = true,
  -- enableSemanticHighlighting = true,
}

-- Example if you are using cmp how to make sure the correct capabilities for snippets are set
metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

metals_config.init_options.statusBarProvider = "on"

-- Autocmd that will actually be in charge of starting the whole thing
local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "scala", "sc", "sbt", "java" },
  callback = function()
    require("metals").initialize_or_attach(metals_config)
  end,
  group = nvim_metals_group,
})

-- util.root_pattern("build.sbt", "build.sc", "build.gradle", "pom.xml")

return metals_config
