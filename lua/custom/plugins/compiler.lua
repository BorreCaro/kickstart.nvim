return {
  {
    'CRAG666/code_runner.nvim',
    config = function()
      require('code_runner').setup {
        filetype = {
          python = 'py -u',
          javascript = 'node',
          typescript = 'ts-node',
          rust = {
            'cd $dir &&',
            'mkdir exes 2>nul || echo. &&',
            'rustc $fileName -o exes\\$fileNameWithoutExt.exe &&',
            'exes\\$fileNameWithoutExt.exe',
          },
          c = {
            'cd $dir &&',
            'mkdir exes 2>nul || echo. &&',
            'gcc $fileName -o exes\\$fileNameWithoutExt.exe &&',
            'exes\\$fileNameWithoutExt.exe',
          },
          cpp = {
            'cd $dir &&',
            'mkdir exes 2>nul || echo. &&',
            'g++ -g $fileName -o exes\\$fileNameWithoutExt.exe &&',
            'exes\\$fileNameWithoutExt.exe',
          },
          java = {
            'cd $dir &&',
            'mkdir exes 2>nul || echo. &&',
            'javac $fileName -d exes &&',
            'java -cp exes $fileNameWithoutExt',
          },
          go = {
            'cd $dir &&',
            'mkdir exes 2>nul || echo. &&',
            'go build -o exes\\$fileNameWithoutExt.exe &&',
            'exes\\$fileNameWithoutExt.exe',
          },
          zig = {
            'cd $dir &&',
            'mkdir exes 2>nul || echo. &&',
            'zig build-exe $fileName -femit-bin=exes\\$fileNameWithoutExt.exe &&',
            'exes\\$fileNameWithoutExt.exe',
          },
          cs = {
            'cd $dir &&',
            'mkdir exes 2>nul || echo. &&',
            'csc $fileName /out:exes\\$fileNameWithoutExt.exe &&',
            'exes\\$fileNameWithoutExt.exe',
          },
        },
      }

      vim.keymap.set('n', '<F6>', ':RunCode<CR>', { noremap = true, silent = false })
      vim.keymap.set('n', '<leader>r', ':RunCode<CR>', { noremap = true, silent = false })
      vim.keymap.set('n', '<leader>rf', ':RunFile<CR>', { noremap = true, silent = false })
      vim.keymap.set('n', '<leader>rc', ':RunClose<CR>', { noremap = true, silent = false })
    end,
  },
}
