local __border = require "custom.assets.border"

-- custom on_attach() function with extra things
local on_attach = function(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false

  require("core.utils").load_mappings("lspconfig", { buffer = bufnr })

  if client.server_capabilities.signatureHelpProvider then
    require("nvchad_ui.signature").setup(client)
  end

  if client.server_capabilities.documentSymbolProvider then
    require("nvim-navic").attach(client, bufnr)
    require("nvim-navbuddy").attach(client, bufnr)
  end

  vim.diagnostic.config {
    virtual_text = false,
    severity_sort = true,
  }

  -- Show diagnostic in a floating window.
  vim.api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    callback = function()
      local opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = __border,
        source = "always",
        prefix = " ",
        scope = "cursor",
      }
      vim.diagnostic.open_float(nil, opts)
    end,
  })
end

---@diagnostic disable-next-line: different-requires
local capabilities = require("plugins.configs.lspconfig").capabilities
capabilities.offsetEncoding = { "utf-16" }

require("lspconfig.ui.windows").default_options = {
  border = __border,
}

-- LSP settings (for overriding per client)
local handlers = {
  ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = __border }),
  ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = __border }),
}
---@diagnostic disable-next-line: different-requires
local lspconfig = require "lspconfig"

local servers = {
  "lua_ls",
  "marksman",
  "jsonls",
  "taplo",
  "yamlls",
  "clangd",
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    handlers = handlers,

    settings = {
      Lua = require "custom.plugins.configs.lsp.lua_ls",
    },

    marksman = require "custom.plugins.configs.lsp.marksman",
    jsonls = require "custom.plugins.configs.lsp.jsonls",
    taplo = require "custom.plugins.configs.lsp.taplo",
    yamlls = require "custom.plugins.configs.lsp.yamlls",
    clangd = require "custom.plugins.configs.lsp.clangd",
  }
end
