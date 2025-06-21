all: format test

format:
	@echo Formatting...
	@stylua tests/ lua/ -f ./stylua.toml

test: deps
	@echo Testing...
	@# nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run()"
	@nvim --headless --noplugin -u scripts/minimal_init.lua -c "PlenaryBustedDirectory tests/ {minimal_init = 'scripts/minimal_init.lua', sequential = true}"

test_file: deps
	@echo Testing File...
	@# E.g. make test_file FILE=tests/test_file.lua
	@# nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run_file('$(FILE)')"
	@nvim --headless --noplugin -u scripts/minimal_init.lua -c "PlenaryBustedFile $(FILE)"

deps: deps/plenary.nvim deps/mini.nvim
	@echo Pulling...

deps/plenary.nvim:
	@mkdir -p deps
	git clone --filter=blob:none --depth 1 https://github.com/nvim-lua/plenary.nvim.git $@

deps/mini.nvim:
	@mkdir -p deps
	git clone --filter=blob:none --depth 1 https://github.com/echasnovski/mini.nvim $@
