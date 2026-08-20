{ pkgs, lib, ... }:

let
  p = import ./palette.nix { inherit lib; };
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;

    # clipboard=unnamedplus needs a Wayland clipboard helper on Hyprland.
    extraPackages = [ pkgs.wl-clipboard ];

    initLua = ''
      -- Artemis colorscheme
      vim.o.termguicolors = true
      vim.o.background = "dark"

      local c = {
        bg        = "${p.hex p.void}",
        bg1       = "${p.hex p.surface0}",
        bg2       = "${p.hex p.surface1}",
        bg3       = "${p.hex p.surface2}",
        border    = "${p.hex p.blueDim}",
        muted     = "${p.hex p.overlay}",
        inactive  = "${p.hex p.dim}",
        subtle    = "${p.hex p.muted}",
        fg        = "${p.hex p.text}",
        fg_bright = "${p.hex p.bright}",
        accent    = "${p.hex p.amber}",
        accent_hi = "${p.hex p.amberBright}",
        red       = "${p.hex p.rust}",
        red_hi    = "${p.hex p.rustBright}",
        green     = "${p.hex p.green}",
        green_hi  = "${p.hex p.greenBright}",
        yellow    = "${p.hex p.amber}",
        yellow_hi = "${p.hex p.amberBright}",
        blue      = "${p.hex p.blue}",
        blue_hi   = "${p.hex p.blueBright}",
        blue_br   = "${p.hex p.blueBrightest}",
        magenta   = "${p.hex p.violet}",
        magenta_hi= "${p.hex p.violetBright}",
        cyan      = "${p.hex p.blueBright}",
        cyan_hi   = "${p.hex p.blueBrightest}",
        none      = "NONE",
      }

      local function hi(group, opts)
        vim.api.nvim_set_hl(0, group, opts)
      end

      -- Editor chrome
      hi("Normal",        { fg = c.fg,        bg = c.bg })
      hi("NormalFloat",   { fg = c.fg,        bg = c.bg1 })
      hi("FloatBorder",   { fg = c.border,    bg = c.bg1 })
      hi("ColorColumn",   { bg = c.bg2 })
      hi("CursorLine",    { bg = c.bg2 })
      hi("CursorColumn",  { bg = c.bg2 })
      hi("CursorLineNr",  { fg = c.accent,    bold = true })
      hi("LineNr",        { fg = c.inactive })
      hi("SignColumn",    { fg = c.inactive,  bg = c.bg })
      hi("VertSplit",     { fg = c.border,    bg = c.bg })
      hi("WinSeparator",  { fg = c.border,    bg = c.bg })
      hi("EndOfBuffer",   { fg = c.bg3 })
      hi("Folded",        { fg = c.subtle,    bg = c.bg2 })
      hi("FoldColumn",    { fg = c.border,    bg = c.bg })

      -- Cursor & selection
      hi("Cursor",        { fg = c.bg,        bg = c.accent })
      hi("Visual",        { bg = c.bg3 })
      hi("VisualNOS",     { bg = c.bg3 })
      hi("Search",        { fg = c.bg,        bg = c.accent })
      hi("IncSearch",     { fg = c.bg,        bg = c.yellow_hi })
      hi("CurSearch",     { fg = c.bg,        bg = c.yellow_hi })

      -- Status & tab line
      hi("StatusLine",    { fg = c.fg,        bg = c.bg1 })
      hi("StatusLineNC",  { fg = c.subtle,    bg = c.bg1 })
      hi("TabLine",       { fg = c.subtle,    bg = c.bg1 })
      hi("TabLineFill",   { bg = c.bg1 })
      hi("TabLineSel",    { fg = c.bg,        bg = c.accent,  bold = true })
      hi("WildMenu",      { fg = c.bg,        bg = c.accent })

      -- Pmenu (completion)
      hi("Pmenu",         { fg = c.fg,        bg = c.bg1 })
      hi("PmenuSel",      { fg = c.bg,        bg = c.accent })
      hi("PmenuSbar",     { bg = c.bg2 })
      hi("PmenuThumb",    { bg = c.border })

      -- Messages & prompts
      hi("ErrorMsg",      { fg = c.red_hi })
      hi("WarningMsg",    { fg = c.yellow })
      hi("ModeMsg",       { fg = c.fg_bright, bold = true })
      hi("MoreMsg",       { fg = c.blue_hi })
      hi("Question",      { fg = c.accent })
      hi("Title",         { fg = c.accent,    bold = true })

      -- Syntax
      hi("Comment",       { fg = c.inactive,  italic = true })
      hi("Constant",      { fg = c.cyan })
      hi("String",        { fg = c.green_hi })
      hi("Character",     { fg = c.green })
      hi("Number",        { fg = c.cyan_hi })
      hi("Boolean",       { fg = c.magenta_hi })
      hi("Float",         { fg = c.cyan_hi })
      hi("Identifier",    { fg = c.fg })
      hi("Function",      { fg = c.blue_hi })
      hi("Statement",     { fg = c.magenta,   bold = false })
      hi("Conditional",   { fg = c.magenta })
      hi("Repeat",        { fg = c.magenta })
      hi("Label",         { fg = c.magenta })
      hi("Operator",      { fg = c.subtle })
      hi("Keyword",       { fg = c.magenta_hi })
      hi("Exception",     { fg = c.red_hi })
      hi("PreProc",       { fg = c.yellow })
      hi("Include",       { fg = c.blue })
      hi("Define",        { fg = c.yellow })
      hi("Macro",         { fg = c.yellow })
      hi("PreCondit",     { fg = c.yellow })
      hi("Type",          { fg = c.accent })
      hi("StorageClass",  { fg = c.accent })
      hi("Structure",     { fg = c.accent })
      hi("Typedef",       { fg = c.accent })
      hi("Special",       { fg = c.yellow_hi })
      hi("SpecialChar",   { fg = c.yellow_hi })
      hi("Tag",           { fg = c.blue_hi })
      hi("Delimiter",     { fg = c.subtle })
      hi("SpecialComment",{ fg = c.subtle,    italic = true })
      hi("Debug",         { fg = c.red })
      hi("Underlined",    { underline = true })
      hi("Ignore",        { fg = c.muted })
      hi("Error",         { fg = c.red_hi })
      hi("Todo",          { fg = c.bg,        bg = c.accent, bold = true })

      -- Diagnostics
      hi("DiagnosticError",          { fg = c.red_hi })
      hi("DiagnosticWarn",           { fg = c.yellow })
      hi("DiagnosticInfo",           { fg = c.blue_hi })
      hi("DiagnosticHint",           { fg = c.subtle })
      hi("DiagnosticUnderlineError", { sp = c.red_hi,  undercurl = true })
      hi("DiagnosticUnderlineWarn",  { sp = c.yellow,  undercurl = true })
      hi("DiagnosticUnderlineInfo",  { sp = c.blue_hi, undercurl = true })
      hi("DiagnosticUnderlineHint",  { sp = c.subtle,  undercurl = true })

      -- Diff
      hi("DiffAdd",       { fg = c.green,     bg = "${p.hex p.diffAddBg}" })
      hi("DiffChange",    { fg = c.yellow,    bg = "${p.hex p.diffChangeBg}" })
      hi("DiffDelete",    { fg = c.red,       bg = "${p.hex p.diffDeleteBg}" })
      hi("DiffText",      { fg = c.accent,    bg = "${p.hex p.diffTextBg}", bold = true })
      hi("Added",         { fg = c.green })
      hi("Changed",       { fg = c.yellow })
      hi("Removed",       { fg = c.red })

      -- Spell
      hi("SpellBad",      { sp = c.red_hi,    undercurl = true })
      hi("SpellCap",      { sp = c.yellow,    undercurl = true })
      hi("SpellRare",     { sp = c.magenta,   undercurl = true })
      hi("SpellLocal",    { sp = c.blue,      undercurl = true })

      -- Netrw / file explorer
      hi("Directory",     { fg = c.blue_hi })

      -- Options
      vim.o.number         = true
      vim.o.relativenumber = true
      vim.o.cursorline     = true
      vim.o.signcolumn     = "yes"
      vim.o.scrolloff      = 8
      vim.o.splitbelow     = true
      vim.o.splitright     = true
      vim.o.expandtab      = true
      vim.o.tabstop        = 2
      vim.o.shiftwidth     = 2
      vim.o.smartindent    = true
      vim.o.wrap           = false
      vim.o.ignorecase     = true
      vim.o.smartcase      = true
      vim.o.hlsearch       = true
      vim.o.incsearch      = true
      vim.o.updatetime     = 250
      vim.o.timeoutlen     = 400
      vim.o.mouse          = "a"
      vim.o.clipboard      = "unnamedplus"
      vim.o.undofile       = true
      vim.o.winborder      = "rounded"
    '';
  };
}
