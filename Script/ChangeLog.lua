--[[
    改动记录文档 / Change Log Document
    用途: 记录每次代码改动的概要，供后续AI快速了解上下文
    格式: 每条记录仅需一句话概括改动
]]

---@class ChangeEntry
---@field id number 记录ID
---@field datetime string 时间 (YYYY-MM-DD HH:MM)
---@field files string[] 改动的文件列表
---@field summary string 改动概要（一句话）
---@field author string 修改人

---@type ChangeEntry[]
local ChangeLog = {
    {
        id = 1,
        datetime = "2026-04-19 10:30",
        files = { ".cursor/rules/UGC-SX 编码规则.md", "BugRecords.lua", "ChangeLog.lua" },
        summary = "新增犯错记录文档和改动记录文档，并更新编码规则",
        author = "AI"
    },

    -- 示例记录
    --[[
    {
        id = 2,
        datetime = "YYYY-MM-DD HH:MM",
        files = { "Script/UI/MMainUI.lua" },
        summary = "添加了背包按钮点击事件响应",
        author = "AI"
    },
    ]]
}

--- 添加改动记录
---@param entry ChangeEntry
---@return number 新记录ID
local function AddEntry(entry)
    entry.id = #ChangeLog + 1
    table.insert(ChangeLog, entry)
    return entry.id
end

--- 获取最近N条记录
---@param count number
---@return ChangeEntry[]
local function GetRecentEntries(count)
    local result = {}
    local start = math.max(1, #ChangeLog - count + 1)
    for i = start, #ChangeLog do
        table.insert(result, ChangeLog[i])
    end
    return result
end

--- 打印最近记录
---@param count number
local function PrintRecentEntries(count)
    local entries = GetRecentEntries(count)
    print(string.format("\n===== 最近 %d 条改动 =====\n", #entries))
    for _, entry in ipairs(entries) do
        print(string.format(
            "[%s] %s\n  文件: %s\n  改动: %s\n",
            entry.datetime,
            entry.author,
            table.concat(entry.files, ", "),
            entry.summary
        ))
    end
end

local M = {
    AddEntry = AddEntry,
    GetRecentEntries = GetRecentEntries,
    PrintRecentEntries = PrintRecentEntries,
}

return M
