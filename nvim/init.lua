-- nvim-tree는 netrw와 역할이 겹치므로 가장 먼저 꺼 둔다.
-- 이 설정이 늦게 적용되면 디렉터리를 열 때 netrw가 먼저 개입할 수 있다.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("psm.core")
require("psm.lazy")
