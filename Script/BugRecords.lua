--[[
    犯错记录文档 / Mistake Record Document
    用途: 记录开发过程中的错误、原因分析、解决方案
    维护: 每次修复问题后更新此文档
]]

---@class MistakeRecord
---@field id number 记录ID
---@field date string 发生日期 (YYYY-MM-DD)
---@field severity "critical"|"high"|"medium"|"low" 严重程度
---@field module string 出错模块
---@field description string 错误描述
---@field cause string 原因分析
---@field solution string 解决方案
---@field fixed_by string 修复人
---@field fixed boolean 是否已修复
---@field tags string[] 标签

---@type MistakeRecord[]
local MistakeRecords = {
    -- ==================== 已修复记录 ====================

    {
        id = 1,
        date = "2026-04-19",
        severity = "high",
        module = "CommonTriggerBox",
        description = "触发盒检测逻辑异常",
        cause = "碰撞检测回调未正确注册",
        solution = "在 OnRegister 生命周期中正确注册碰撞回调",
        fixed_by = "",
        fixed = false,
        tags = { "collision", "trigger" }
    },

    -- ==================== 示例模板 ====================
    --[[
    {
        id = 0,
        date = "YYYY-MM-DD",
        severity = "low",       -- critical | high | medium | low
        module = "模块名",
        description = "错误描述",
        cause = "原因分析",
        solution = "解决方案",
        fixed_by = "修复人",
        fixed = false,          -- true 已修复 | false 待修复
        tags = { "tag1", "tag2" }
    },
    ]]
}

-- ==================== 辅助函数 ====================

--- 添加新记录
---@param record MistakeRecord
---@return number 新记录的ID
local function AddRecord(record)
    record.id = #MistakeRecords + 1
    table.insert(MistakeRecords, record)
    return record.id
end

--- 获取所有未修复记录
---@return MistakeRecord[]
local function GetUnfixedRecords()
    local unfixed = {}
    for _, record in ipairs(MistakeRecords) do
        if not record.fixed then
            table.insert(unfixed, record)
        end
    end
    return unfixed
end

--- 按严重程度筛选
---@param severity string
---@return MistakeRecord[]
local function FilterBySeverity(severity)
    local result = {}
    for _, record in ipairs(MistakeRecords) do
        if record.severity == severity then
            table.insert(result, record)
        end
    end
    return result
end

--- 按模块筛选
---@param module string
---@return MistakeRecord[]
local function FilterByModule(module)
    local result = {}
    for _, record in ipairs(MistakeRecords) do
        if record.module == module then
            table.insert(result, record)
        end
    end
    return result
end

--- 标记为已修复
---@param record_id number
---@param fixed_by string 修复人
---@return boolean 是否成功
local function MarkAsFixed(record_id, fixed_by)
    for _, record in ipairs(MistakeRecords) do
        if record.id == record_id then
            record.fixed = true
            record.fixed_by = fixed_by
            return true
        end
    end
    return false
end

--- 打印记录摘要
---@param record MistakeRecord
local function PrintRecordSummary(record)
    local status = record.fixed and "[已修复]" or "[待修复]"
    print(string.format(
        "[%d] %s | %s | [%s] | %s\n  原因: %s\n  解决: %s",
        record.id,
        record.date,
        status,
        record.severity,
        record.description,
        record.cause,
        record.solution
    ))
end

--- 打印所有未修复记录
local function PrintAllUnfixed()
    local unfixed = GetUnfixedRecords()
    print(string.format("\n===== 未修复记录 (%d) =====\n", #unfixed))
    for _, record in ipairs(unfixed) do
        PrintRecordSummary(record)
        print("")
    end
end

-- ==================== 导出模块 ====================
local M = {
    AddRecord = AddRecord,
    GetUnfixedRecords = GetUnfixedRecords,
    FilterBySeverity = FilterBySeverity,
    FilterByModule = FilterByModule,
    MarkAsFixed = MarkAsFixed,
    PrintRecordSummary = PrintRecordSummary,
    PrintAllUnfixed = PrintAllUnfixed,
}

return M
