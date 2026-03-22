vim.g.mapleader = " "
vim.g.maplocalleader = ","

local keymap = vim.keymap

-- insert 모드에서 jk로 빠르게 빠져나오는 습관을 유지한다.
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- Nvim 0.11 기본 snippet 점프가 <Tab>를 가로채면 일반 들여쓰기 감각이 깨진다.
-- completion/snippet 플러그인이 직접 관리하도록 기본 매핑은 제거한다.
pcall(keymap.del, { "i", "s" }, "<Tab>")
pcall(keymap.del, { "i", "s" }, "<S-Tab>")

-- macOS 쪽과 같은 손동작을 유지하도록 하이라이트 해제 키를 leader로 맞춘다.
keymap.set("n", "<leader>nh", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- 숫자 증감은 설정 파일 수정 시 꽤 자주 유용하다.
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- 창 관리는 macOS 설정과 같은 s prefix로 되돌린다.
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Equalize window size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current window" })

-- 방향키 대신 홈로우로 창 이동이 가능하면 터미널/에디터 사이 감각이 맞는다.
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- 탭은 큰 작업 단위를 나눌 때만 쓰도록 최소 키맵만 남긴다.
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })
