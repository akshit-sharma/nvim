local ok, lsp = pcall(require, 'lsp-zero')
if not ok then
  vim.notify('lsp-zero not found', vim.log.levels.ERROR)
  return
end

lsp.preset('recommended')

lsp.ensure_installed({
  'clangd',
  'cmake',
  'pyright',
  'vimls',
  'rust_analyzer',
  'ltex',
})

local ok_cmp, cmp = pcall(require, 'cmp')
if not ok_cmp then
  vim.notify('cmp not found', vim.log.levels.ERROR)
  return
end

local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mapping = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-Space>'] = cmp.mapping.complete(),
  ['<C-e>'] = cmp.mapping.close(),
  ['<M-k>'] = cmp.mapping.confirm({
    behavior = cmp.ConfirmBehavior.Replace,
    select = true
  }),

  ['<C-k>'] = cmp.mapping.confirm({
    behavior = cmp.ConfirmBehavior.Insert,
    select = true
  }),
})

-- disable completion with table
cmp_mapping['<CR>'] = nil
cmp_mapping['<C-j>'] = nil
cmp_mapping['<Tab>'] = nil
cmp_mapping['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
  sources = {
    {name = 'copilot', max_item_count = 10},

    {name = 'nvim_lsp', keyword_length = 3, max_item_count = 10},
    {name = 'path', keyword_length = 2, max_item_count = 5},
    {name = 'luasnip', keyword_length = 2, max_item_count = 5},
    {name = 'buffer', keyword_length = 2, max_item_count = 5},
  },
  mapping = cmp_mapping,
})

lsp.set_preferences({
  sign_icons ={
    error = 'E',
    warn = 'W',
    hint = 'H',
    info = 'I'
  }
})

--local navbuddy = require('nvim-navbuddy')
local navic = require('nvim-navic')

lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  if client.name == "eslint" then
      vim.cmd.LspStop('eslint')
      return
  end
  if client.server_capabilities.documentSymbolProvider then
    --navbuddy.attach(client, bufnr)
    navic.attach(client, bufnr)
  end

  -- print offset_encoding
--  print(client.offset_encoding)

  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, opts)
  vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts)
  vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>rr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<C-h>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("n", "<leader>fm", function() vim.lsp.buf.format { async = true } end, opts)
  vim.keymap.set("v", "<leader>fm", function() vim.lsp.buf.format { async = true } end, opts)
end)

local dictionaryFile = {
  ["en"] = {vim.fn.getenv("HOME") .. "spell/dictionary.txt"},
}
local disabledRulesFile = {
  ["en"] = {vim.fn.getenv("HOME") .. "spell/disabled-rules.txt"},
}
local falsePositivesFile = {
  ["en"] = {vim.fn.getenv("HOME") .. "spell/false-positives.txt"},
}

local function readFiles(files)
  local dict = {}
  for _, file in ipairs(files) do
    local f = io.open(file, "r")
    if not f then
      vim.notify("File not found: " .. file, vim.log.levels.ERROR)
      return
    end
    for line in f:lines() do
      table.insert(dict, line)
    end
  end
end

local function findLtexLang()
    local buf_clients = vim.lsp.buf_get_clients()
    for _, client in ipairs(buf_clients) do
        if client.name == "ltex" then
            return client.config.settings.ltex.language
        end
    end
end

local function findLtexFiles(filetype, value)
    local files = nil
    if filetype == 'dictionary' then
        files = dictionaryFile[value or findLtexLang()]
    elseif filetype == 'disable' then
        files = disabledRulesFile[value or findLtexLang()]
    elseif filetype == 'falsePositive' then
        files = falsePositivesFile[value or findLtexLang()]
    end

    if files then
        return files
    else
        return nil
    end
end

local function updateConfig(lang, configtype)
    local buf_clients = vim.lsp.buf_get_clients()
    local client = nil
    for _, lsp in ipairs(buf_clients) do
        if lsp.name == "ltex" then
            client = lsp
        end
    end

    if client then
        if configtype == 'dictionary' then
            if client.config.settings.ltex.dictionary then
                client.config.settings.ltex.dictionary = {
                    [lang] = readFiles(dictionaryFile[lang])
                };
                return client.notify('workspace/didChangeConfiguration', client.config.settings)
            else
                return vim.notify("Error when reading dictionary config, check it")
            end
        elseif configtype == 'disable' then
            if client.config.settings.ltex.disabledRules then
                client.config.settings.ltex.disabledRules = {
                    [lang] = readFiles(disabledRulesFile[lang])
                };
                return client.notify('workspace/didChangeConfiguration', client.config.settings)
            else
                return vim.notify("Error when reading disabledRules config, check it")
            end

        elseif configtype == 'falsePositive' then
            if client.config.settings.ltex.hiddenFalsePositives then
                client.config.settings.ltex.hiddenFalsePositives = {
                    [lang] = readFiles(falsePositivesFile[lang])
                };
                return client.notify('workspace/didChangeConfiguration', client.config.settings)
            else
                return vim.notify("Error when reading hiddenFalsePositives config, check it")
            end
        end
    else
        return nil
    end
end

local function addToFile(filetype, lang, file, value)
    file = io.open(file[#file-0], "a+") -- add only to last file defined.
    if file then
        file:write(value .. "\n")
        file:close()
    else
        return print("Failed insert %q", value)
    end
    if filetype == 'dictionary' then
        return updateConfig(lang, "dictionary")
    elseif filetype == 'disable' then
        return updateConfig(lang, "disable")
    elseif filetype == 'falsePositive' then
        return updateConfig(lang, "disable")
    end
end

local function addTo(filetype, lang, file, value)
    local dict = readFiles(file)
    for _, v in ipairs(dict) do
        if v == value then
            return nil
        end
    end
    return addToFile(filetype, lang, file, value)
end

lsp.configure('ltex', {
  settings = {
    ltex = {
      dictionary = {
        ['en'] = readFiles(dictionaryFile["en"] or {}),
      },
      disabledRules = {
        ['en'] = readFiles(disabledRulesFile["en"] or {}),
      },
      hiddenFalsePositives = {
        ['en'] = readFiles(falsePositivesFile["en"] or {}),
      },
    }
  }
})

-- https://github.com/neovim/nvim-lspconfig/issues/858 can't intercept,
-- override it then.
local orig_execute_command = vim.lsp.buf.execute_command
vim.lsp.buf.execute_command = function(command)
    if command.command == '_ltex.addToDictionary' then
        local arg = command.arguments[1].words -- can I really access like this?
        for lang, words in pairs(arg) do
            for _, word in ipairs(words) do
                local filetype = "dictionary"
                addTo(filetype,lang, findLtexFiles(filetype,lang), word)
            end
        end
    elseif command.command == '_ltex.disableRules' then
        local arg = command.arguments[1].ruleIds -- can I really access like this?
        for lang, rules in pairs(arg) do
            for _, rule in ipairs(rules) do
                local filetype = "disable"
                addTo(filetype,lang,findLtexFiles(filetype,lang), rule)
            end
        end

    elseif command.command == '_ltex.hideFalsePositives' then
        local arg = command.arguments[1].falsePositives -- can I really access like this?
        for lang, rules in pairs(arg) do
            for _, rule in ipairs(rules) do
                local filetype = "falsePositive"
                addTo(filetype,lang,findLtexFiles(filetype,lang), rule)
            end
        end
    else
      orig_execute_command(command)
    end
end

lsp.setup()

vim.diagnostic.config({
  virtual_text = true
})
