--------------------------------------------------------------------------------
-- UGC-SX 项目架构文档
-- UGC-SX Script/ugc_module_doc.lua
--
-- 本文件为纯注释文档，用于说明项目中所有 UI 模块和 Common 系统的作用、
-- 数据结构、持久化方式、网络通信和跨模块交互关系。
--
-- 文档索引：
--   I.   系统架构概述
--   II.  Common 系统
--         II-A. Config_PlayerData
--         II-B. SkillSystem
--         II-C. VirtualItemSystem
--         II-D. RewardSystem
--   III. UI 模块
--         III-A.  MMainUI — 中央面板枢纽
--         III-B.  ShenYin 神佑
--         III-C.  Jiange 剑阁
--         III-D.  Zhuansheng 转生
--         III-E.  PlayerInfo 玩家信息 (touxiang / touxiangdetail)
--         III-F.  XueMai 血脉
--         III-G.  Addexp 直接经验
--         III-H.  TalentTree 天赋
--         III-I.  Active 活动
--         III-K.  WB_Inventory 合成/分解
--         III-L.  WB_Team 队伍
--         III-M.  Chuansong 传送
--         III-N.  其他模块
--   IV.   数据持久化汇总
--   V.    RPC 参考表
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- I. 系统架构概述
--------------------------------------------------------------------------------

-- 【游戏架构】
--   UGCGameSystem        — 全局游戏系统，提供所有子系统的访问入口
--   UGCPlayerState       — 玩家状态 Actor，处理所有与玩家数据相关的服务器逻辑
--   UGCPlayerController  — 玩家控制器，持有客户端 UI 引用，处理输入和网络通信
--   UGCGameData          — 游戏配置数据，提供等级配置、充值奖励配置等读取接口
--   UGCGameMode          — 游戏模式，处理全局规则（如复活时恢复装备技能）
--   UGCGameState         — 游戏状态

-- 【数据流向】
--   客户端 UI (Lua Widget)
--        |
--        v (UnrealNetwork.CallUnrealRPC)
--   服务器 RPC Handler (UGCPlayerState 或 UGCGameMode)
--        |
--        v (修改 GameData 字段)
--   UGCPlayerState (运行时内存状态)
--        |
--        v (UGCPlayerStateSystem.SavePlayerArchiveData)
--   玩家存档 (持久化存储)
--
--   属性同步：服务器通过 UGCAttributeSystem.SetGameAttributeValue 将属性设置到玩家 Pawn，
--            客户端通过 UGCAttributeSystem.GetGameAttributeValue 读取，Binding 属性实时刷新 UI。

-- 【UI 框架】
--   MMainUI 是所有 UI 面板的中央枢纽，持有所有子面板的引用。
--   各个功能面板以 UUserWidget 子类的形式存在，通过 MMainUI 的 Toggle*/Show/Hide 方法控制显示。
--   面板的显示/隐藏通过 UGCWidgetManagerSystem.AddWidgetHiddenLayer / SubWidgetHiddenLayer
--   实现全屏遮罩（隐藏底层 HUD 元素如摇杆和主控制面板）。
--   所有面板通过 Server RPC 与服务器通信，所有持久化数据最终写入 UGCPlayerState.GameData，
--   由 UGCPlayerStateSystem.SavePlayerArchiveData 落盘。

--------------------------------------------------------------------------------
-- II. Common 系统
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- II-A. Config_PlayerData  (文件: Script/Common/Config_PlayerData.lua)
--
-- 玩家数据配置常量、默认模板和辅助函数。
--------------------------------------------------------------------------------

-- 【默认玩家数据模板】 — 定义了所有需要持久化的玩家数据字段及其默认值。
-- 关键字段说明：
--   PlayerExp / PlayerLevel              — 经验值和等级
--   PlayerHp / PlayerMaxHp              — 当前生命和最大生命
--   PlayerAttack / PlayerMagic           — 攻击力和魔法值
--   PlayerRebirthCount                  — 转生次数
--   PlayerTalentPoints                 — 天赋点（每升1级获得1点）
--   PlayerRebirthBonusHp/Attack/Magic   — 转生时累积的属性加成
--   PlayerTalent{1-9}                  — 各类型天赋等级
--   PlayerSpeedTalent / AttackTalent / HpTalent — 速度/攻击/生命天赋
--   DirectExpEnabled                   — 直接经验开关（绕过吞噬系统）
--   AutoTunshiEnabled / AutoPickupEnabled — 自动吞噬/拾取开关
--   PlayerEcexp                        — 吞噬经验基础值（受神佑加成影响）
--   PlayerVIP                          — VIP等级（由累计充值计算）
--   PlayerJiangeFloor / Level / Progress — 剑阁当前层数、剑等级、锻造进度
--   PlayerShenyinData                  — 神佑数据的序列化字符串
--   PlayerManual{Attack/Magic/Hp/Bland} — 手动加点的各属性分配次数
--   PlayerBland                        — 吞噬值（血脉属性）
--   BloodlineEnabled                   — 血脉开关
--   PlayerJiangeFloorClaimed           — 已领取的剑阁层奖励（逗号分隔字符串）
--   PlayerJiangeDailyClaimDate         — 剑阁每日奖励领取日期（"YYYY-MM-DD"格式）

-- 【转生配置】
--   RebirthLevels:       {25, 90, 180, 300, 450, 600, 750, 1000}  — 8级转生所需等级
--   RebirthCombatPowers: {500, 5000, 25000, 80000, 300000, 600000, 2000000, 5000000} — 所需战斗力

-- 【VIP 等级计算】 — CalcVIPLevelBySpend(spendCount)
--   6元=1级, 30元=2级, 98元=3级, 168元=4级, 648元=5级, 1000元=6级, 3000元=7级

-- 【天赋配置】 TALENT_CONFIG
--   天赋类型1（木）：消耗1， maxLevel=5
--   天赋类型2（金）：消耗1， maxLevel=5
--   天赋类型4（水）：消耗3， maxLevel=5
--   天赋类型7（火）：消耗5， maxLevel=5
--   天赋类型8（土）：消耗5， maxLevel=5
--   ENABLED_TALENT_TYPES = {1, 2, 4, 7, 8}

-- 【神佑/剑阁技能路径前缀】
--   ALL_SHENYIN_SKILLS = {"baise","lvse","lanse","zise","chengse","hongse","jinse"}
--   ALL_JIANGE_SKILLS = {"bailangjian","kuishejian","baihujian","bifangjian","qilingjian","zhuquejian","shenlongjian"}

-- 【血脉技能路径】
--   BLOODLINE_SKILL_PATH = 'Asset/Blueprint/Prefabs/Skills/chaofeng.chaofeng_C'

-- 【剑阁奖励配置】
--   JiangeRewardVirtualItemID = 5666 （锻造石）
--   JiangeFloorRewardConfig: 层数100-1000，每层对应奖励数量

--------------------------------------------------------------------------------
-- II-B. SkillSystem  (文件: Script/Common/SkillSystem.lua)
--
-- 玩家技能系统：天赋 Buff 管理、神佑/剑阁被动技能挂载/卸载、复活时技能恢复。
--------------------------------------------------------------------------------

-- 【天赋系统】
--   ApplyTalentBuff(talentType) — 根据天赋类型应用对应 Buff
--     1=木之本源(HP), 2=金之本源(速度), 4=水之本源(魔法), 7=火之本源(攻击), 8=土之本源(HP回复)
--     Buff 通过 UGCPersistEffectSystem.AddBuffByClass 添加到玩家 Pawn，level 作为Buff等级参数
--   ApplyAllTalentBuffs / ApplyAllTalentBuffsInternal — 应用所有已激活天赋的 Buff
--     使用 UGCPersistEffectSystem.RemoveBuffByClass 先清除旧 Buff，再按新等级重新添加

-- 【神佑技能系统】 Server_SetShenyingSkill(skillPath, isWear)
--   挂载：清理所有 7 种神兽 x 5 种品质 = 35 个可能的技能路径
--         （通过遍历 ALL_SHENYIN_SKILLS 和品质1-5 构建路径进行清理）
--         然后使用 UGCPersistEffectSystem.AddSkillByClass 添加目标技能
--   卸载：遍历所有路径找到对应技能，使用 RemoveSkillInstance 移除
--   技能以持久效果形式存在于玩家 Pawn 上（UGCPersistEffectSystem）

-- 【剑阁技能系统】 Server_SetJiangeSkill(skillPath, isWear)
--   清理所有 7 种剑阁技能路径，然后按需添加目标技能
--   与神佑共享清理逻辑的结构，但独立路径前缀（shenjian vs shenyin）

-- 【血脉技能】 Server_SetBloodlineEnabled(isEnabled)
--   开启：添加 chaofeng 技能，设置 bland=1，标记 BloodlineEnabled=true
--   关闭：移除 chaofeng 技能，设置 bland=0，标记 false
--   属性 bland 影响吞噬值和血脉相关计算

-- 【复活时技能恢复】 ReapplyWearingSkills(self)
--   当玩家复活时调用，从 PlayerShenyinData 字符串中解析出当前穿戴的技能路径，
--   重新调用 Server_SetShenyingSkill 和 Server_SetJiangeSkill 恢复装备状态。
--   在 UGCGameMode 的复活逻辑中调用。

--------------------------------------------------------------------------------
-- II-C. VirtualItemSystem  (文件: Script/Common/VirtualItemSystem.lua)
--
-- 虚拟物品和背包物品操作。
--------------------------------------------------------------------------------

-- 【虚拟物品扣除】 Server_RemoveVirtualItem(virtualItemID, count)
--   通过 VirtualItemManager:RemoveVirtualItem 扣除虚拟物品
--   特殊处理：virtualItemID=5666（锻造石）使用异步回调模式，
--     回调完成或 0.35s 超时后才通知客户端消费结果，防止客户端提前刷新导致进度回滚
--   其他物品使用同步扣除

-- 【背包物品扣除】 Server_RemoveBackpackItem(itemID, count)
--   通过 UGCBackpackSystemV2.RemoveItemV2 扣除背包中的实体物品

-- 【消费计次】 Server_AddSpendCount(amount)
--   累加消费金额，用于 VIP 等级计算
--   更新 TotalSpendCount、VIP等级、排名的消费排名

-- 【商店购买计次】 Server_AddShopBuyCount()
--   累加商店购买次数

--------------------------------------------------------------------------------
-- II-D. RewardSystem  (文件: Script/Common/RewardSystem.lua)
--
-- 奖励领取、序列化化和发放逻辑。
--------------------------------------------------------------------------------

-- 【充值奖励序列化】 SerializeClaimedChongzhi / DeserializeClaimedChongzhi
--   格式："1,3,5" — 逗号分隔的已领取奖励ID字符串
--   NormalizeClaimedChongzhiMap — 规范化混合格式的领取数据（支持布尔值/数值/字符串）

-- 【充值奖励】 Server_ClaimChongzhiReward(rewardID)
--   校验：是否已领取 -> 配置是否存在 -> 累计消费是否达标
--   防止重复领取：ChongzhiClaimPending[rewardID] 锁定
--   奖励发放：GrantRewardToPlayerState -> VirtualItemManager:AddVirtualItem 或背包添加

-- 【剑阁通关奖励】 Server_GiveTaReward(floorNum)
--   更新 PlayerJiangeFloor（如通关层数更高），同步到客户端显示，
--   根据 UGCGameData.GetTaSettlementReward 获取奖励配置，发放物品和经验

-- 【剑阁层奖励】 Server_ClaimJiangeFloorReward(floorNum)
--   校验：当前层数是否达标 -> 是否已领取
--   奖励通过 VirtualItemManager:AddVirtualItem 发放，
--   已领取层数以逗号分隔字符串持久化（PlayerJiangeFloorClaimed）

-- 【剑阁每日奖励】 Server_ClaimJiangeDailyReward()
--   按日期（"YYYY-MM-DD"）判断是否今日已领取，
--   奖励通过 GrantRewardToPlayerState 发放，更新 PlayerJiangeDailyClaimDate

--------------------------------------------------------------------------------
-- III. UI 模块
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- III-A. MMainUI — 中央面板枢纽  (文件: Script/UI/MMainUI.lua)
--
-- MMainUI 是所有 UI 面板的容器和控制器，持有所有子面板和工具栏按钮的引用。
--------------------------------------------------------------------------------

-- 【面板切换方法】
--   ToggleShenyin()           — 切换神佑面板显示/隐藏
--   ToggleJiange()            — 切换剑阁面板显示/隐藏
--   ToggleWujingjiange()      — 切换武经剑阁入口面板显示/隐藏
--   ToggleInventory()         — 切换合成/分解面板，使用 UIPanelToggles 管理层级
--   ToggleTeam()              — 切换队伍面板
--   ToggleShounaButtons()      — 切换工具栏显示/隐藏（收起/展开按钮）
--   ShowConfirmPurchase / HideConfirmPurchase — 购买确认面板

-- 【面板引用字段】
--   shenyin, jiange, wujingjiange, touxiang, touxiangdetail,
--   WB_Inventory, WB_Team, active, TalentTree, shouna,
--   shenyingbuttun, jiangebuttun, wujingbuttun, zhuanshengbuttun,
--   chuansongbuttun, chuansongbuttun_2, shouchongbuttun, shoucong,
--   Inventorybuttun, teambuttun, activebuttun, jiaochengbuttun,
--   xuemai, addexp, zdtunshi, zdshiqu, huicheng, help, jdutiao,
--   ta_settlement, Settlement, Settlement_2, SettlementTip, tunshi, tunshitip,
--   WB_Teamiinvite, Numchoose, ConfirmPurchase_UIBP

-- 【模式 1002 特殊处理】
--   防御塔保护模式（modeID=1002）：隐藏大多数按钮，只保留 xuemai、shenyingbuttun、jiangebuttun，
--   特殊计时代码，倒计时结束后提示目标（40只狼怪），显示敌怪计数（mobnum）
--   防御塔存在检测，血量耗尽时游戏失败

-- 【自动吞噬】 OnAutoTunshiClicked
--   0.3s 冷却保护，防止频繁点击

--------------------------------------------------------------------------------
-- III-B. ShenYin 神佑模块
--
-- 神佑系统：7种神兽（白狼、青蛇、蓝虎、白泽、麒麟、凤凰、神龙），
-- 每种有 5 档品质（决定技能外观/名称）和 1-100 级（决定Ecexp经验加成倍率）。
-- 核心效果：穿戴神兽获得吞噬经验加成（Ecexp bonus），提升吞噬后的升级效率。
-- 同一时间只能穿戴一个神兽，其余解锁后作为收藏。
--------------------------------------------------------------------------------

-- 【神佑主面板】  (文件: Script/UI/Item/shenyin.lua)
--
-- 8个神兽槽位：bailang(baise) + Button_2(lvse) + Button_3(lanse) +
--              Button_4(zise) + Button_5(chengse) + Button_6(hongse) + Button_7(jinse)
--
-- 【槽位状态】
--   unlock  — 未解锁（灰色遮罩），需要消耗 100 个对应虚拟物品才能解锁
--   unwear  — 已解锁但未穿戴
--   wear    — 已穿戴（黄色边框高亮），同时只能有一个槽位处于 wear 状态
--
-- 【每槽位数据】
--   SlotStates[槽位ID]     — 状态 (unlock/unwear/wear)
--   SlotLevels[槽位ID]     — 等级 (1-100)
--   SlotQualities[槽位ID]  — 品质 (1-5)
--
-- 【Ecexp 经验加成配置】 EcexpConfig
--   公式: bonus = cfg.base + (cfg.max - cfg.base) * (lv - 1) / 99, floor取整
--   bailang:  base=100,  max=200  (Lv100时基础吞噬加成200%)
--   lvse:     base=200,  max=400
--   lanse:    base=300,  max=600
--   zise:     base=400,  max=800
--   chengse:  base=500,  max=1000
--   hongse:   base=750,  max=1500
--   jinse:    base=1000, max=2000 (神龙满级2000%加成)
--
-- 【升级材料消耗】
--   解锁: 100 个虚拟物品
--   升级（每级）: 1 个虚拟物品
--   升品: 100 个虚拟物品（改变技能外观和名称，不改变Ecexp属性）
--
-- 【虚拟物品 ID】 ItemVirtualIDs
--   bailang=5001, lvse=5002, lanse=5003, zise=5004,
--   chengse=5005, hongse=5006, jinse=5007
--
-- 【技能资源路径】
--   品质1: 'Asset/Blueprint/Prefabs/Skills/shenyin/{skillName}.{skillName}_C'
--   品质2-5: 'Asset/Blueprint/Prefabs/Skills/shenyin/SY{quality}/{skillName}.{skillName}_C'
--   例如: baise(白狼) SY3/白狼 = shenyin/SY3/baise.baise_C
--   技能 Blueprint 包含被动效果（如吞噬经验加成 %），通过 UGCPersistEffectSystem 挂载到 Pawn
--
-- 【PendingCost 防止重复消费】
--   客户端在 RPC 发送前先累加 PendingCost[virtualID]，收到服务器确认前显示"预扣"数量，
--   避免玩家快速连续点击导致多次消费
--
-- 【UI 刷新】
--   OnItemNumUpdated — 虚拟物品数量变化时重置 PendingCost 并刷新材料显示
--   刷新流程: OnSlotButtonClicked -> UpdateItemImages / UpdateLevelDisplay /
--              UpdateInfoDisplay / UpdateActionButtons
--
-- 【操作流程】
--   1. 点击槽位按钮: 选中该神兽，显示名称/图片/当前等级/当前Ecexp/下一级Ecexp
--   2. 解锁 (unlock): 消耗100个虚拟物品，state: unlock->unwear
--   3. 升级 (AddLevel): 消耗1个虚拟物品，Level+1，若穿戴中实时刷新 Ecexp bonus
--   4. 升品 (AddQuality): 消耗100个虚拟物品，Quality+1，
--      若穿戴中重新调用 ApplySkill 加载新品质对应的 Blueprint 技能
--   5. 穿戴 (wear): 自动卸下上一个，state: unwear->wear，
--      调用 ApplySkill(skillPath, true, quality) 和 ApplyEcexp(bonus)
--   6. 卸下 (remove): 调用 ApplySkill(skillPath, false) 和 ApplyEcexp(0)
--
-- 【数据持久化】
--   序列化格式: "bailang:unwear:1:1;Button_2:unlock:1:1;Button_3:unlock:1:1;..."
--   每条记录: "槽位ID:状态:等级:品质"，以分号分隔
--   SerializeData -> Server_SaveShenyinData -> GameData.PlayerShenyinData（字符串）
--   存档: UGCPlayerState:DataSave -> UGCPlayerStateSystem.SavePlayerArchiveData

-- 【神佑工具栏按钮】  (文件: Script/UI/Item/shenyingbuttun.lua)
--   单按钮组件，带悬停/按压动画，
--   点击 -> pc.MMainUI:ToggleShenyin()

-- 【服务器端处理】  (Blueprint/UGCPlayerState.lua)
--   Server_SetShenyingSkill(skillPath, isWear) -> SkillSystem.Server_SetShenyingSkill
--   Server_SetShenyinEcexp(amount) -> 设置 ShenYinEcexpBonus ->
--     Ecexp attribute = GameData.PlayerEcexp + ShenYinEcexpBonus
--   Server_SaveShenyinData(dataStr) -> GameData.PlayerShenyinData = dataStr
--   Client_SyncShenyinData(dataStr) -> PC.SavedShenyinData

-- 【与其他模块的交互】
--   wujingjiange 开始副本时: 自动卸下当前穿戴神佑，CurrentEcexpBonus=0，ApplyEcexp(0)
--   UGCGameMode 复活时: ReapplyWearingSkills 读取 PlayerShenyinData 恢复穿戴状态
--   VirtualItemSystem: 消耗 ID 5001-5007 的虚拟物品

--------------------------------------------------------------------------------
-- III-C. Jiange 剑阁模块
--
-- 剑阁系统：单槽位神剑升级，共7级（白狼剑->神龙剑），通过锻造石(5666)逐步升级。
-- 每级对应不同的 Blueprint 主动技能和攻击加成百分比。
-- 与神佑并列的另一套装备系统，进入武经剑阁副本时自动卸下。
--------------------------------------------------------------------------------

-- 【剑阁主面板】  (文件: Script/UI/Item/jiange.lua)
--
-- 【7级神剑配置】 SWORD_LEVELS
--   1. bailangjian (啸月寒锋):   攻击加成100%, 升级消耗1个锻造石
--   2. kuishejian (幽冥毒剑):    攻击加成200%, 升级消耗2个锻造石
--   3. baihujian (白虎霜魄剑):  攻击加成200%, 升级消耗3个锻造石
--   4. bifangjian (白泽破邪剑): 攻击加成300%, 升级消耗4个锻造石
--   5. qilingjian (麒麟镇天剑): 攻击加成400%, 升级消耗5个锻造石
--   6. zhuquejian (凤凰涅槃剑): 攻击加成500%, 升级消耗10个锻造石
--   7. shenlongjian (神龙苍穹剑): 攻击加成1000%, 升级消耗0（满级）
--
-- 【锻造进度机制】
--   每次点击升级，消耗1个锻造石(5666)，进度条增加随机 0.1-1.0%（uniform random）
--   进度达到 100 时，剑等级+1，进度归零
--   Server_RemoveVirtualItem 对锻造石使用异步回调模式 + 0.35s 超时保护
--   ForgeCountSyncLock: 客户端在等待服务器确认期间锁定显示数量（0.9s），
--     防止服务器处理延迟导致客户端进度条回滚
--
-- 【穿戴切换】
--   穿戴: ApplySkill(true) + ApplyAtkBonus(true)
--   卸下: ApplySkill(false) + ApplyAtkBonus(false)
--   技能路径: 'Asset/Blueprint/Prefabs/Skills/shenjian/{skillName}.{skillName}_C'
--
-- 【无品质系统】 — 剑阁只有等级，无品质概念（与神佑不同）
--
-- 【剑阁 UI】  (文件: Script/UI/JiangeUI.lua)
--   副本内 HUD，显示当前层数 (JiangeFloor+1)
--   退出按钮: DataSave -> 传送到主城坐标(19053, 50346, 535) -> 关闭 JiangeUI -> 显示 MMainUI

-- 【武经剑阁入口】  (文件: Script/UI/Item/wujingjiange.lua)
--
-- 【功能】
--   显示当前剑阁层数、每日奖励领取、层奖励领取（100-1000层）
--   进入副本前的准备面板
--
-- 【每日奖励】 — 按日期字符串 ("YYYY-MM-DD") 判断，每人每天只能领取一次
--
-- 【层奖励】 — 以逗号分隔的字符串记录已领取层数
--   ParseClaimedFloors: 解析 "100,200,300" 格式的字符串
--   刷新: 遍历所有层，按 不可领/可领取/已领取 更新状态文本
--
-- 【开始副本流程】 OnStartClicked
--   自动卸下当前穿戴的神佑: shenyin.CurrentWearing 置 nil，ApplySkill(false)，ApplyEcexp(0)
--   自动关闭血脉: Server_SetBloodlineEnabled(false)
--   若有以上操作，显示提示"进入剑阁前已自动卸下当前装备并关闭血脉"
--   延迟 2s 后调用 DoEnterJiange -> Server_EnterJiangeInstance RPC

-- 【服务器端处理】  (Blueprint/UGCPlayerState.lua)
--   Server_SaveJiangeData(level, progress) -> GameData.PlayerJiangeLevel + PlayerJiangeProgress
--   Server_SetJiangeSkill(skillPath, isWear) -> SkillSystem.Server_SetJiangeSkill
--   Server_SetJiangeAtkBonus(bonusPercent) -> JiangeAtkBonusPercent + UpdateClientAttributes
--   Server_ClaimJiangeFloorReward(floorNum) -> RewardSystem
--   Server_ClaimJiangeDailyReward() -> RewardSystem

--------------------------------------------------------------------------------
-- III-D. Zhuansheng 转生模块
--
-- 转生系统：玩家达到等级+战斗力要求后可进行转生。
-- 转生效果：角色等级重置为1，经验清零，
--         转生前累积的所有等级HP/攻击/魔法加成永久累加到角色属性。
--------------------------------------------------------------------------------

-- 【转生面板】  (文件: Script/UI/Item/zhuansheng.lua)
--
-- 【转生要求】 — 双重条件
--   等级要求: RebirthLevels[rebirthCount+1]
--   战斗力要求: RebirthCombatPowers[rebirthCount+1]
--   8级转生: 25级/500战力 -> 90级/5000 -> 180级/25000 -> 300级/80000 -> 450级/30万 -> 600级/60万 -> 750级/200万 -> 1000级/500万
--
-- 【转生效果】 DoRebirth
--   1. 累加: PlayerRebirthBonusHp += 当前等级所有等级的 AddHP 总和
--             PlayerRebirthBonusAttack += 当前等级所有等级的 AddHIT 总和
--             PlayerRebirthBonusMagic += 当前等级所有等级的 AddMG 总和
--   2. PlayerRebirthCount++，PlayerLevel=1，PlayerExp=0
--   3. 重新计算: PlayerMaxHp/Attack/Magic += 转生加成，PlayerHp=PlayerMaxHp
--   4. DataSave 持久化
--
-- 【视觉表现】
--   12张转生图片 (zhuansheng1-12)，转生1次显示1张，累加显示
--
-- 【帮助面板】 — 调用 help 面板
--
-- 【转生工具栏按钮】  (文件: Script/UI/Item/zhuanshengbuttun.lua)
--   点击 -> pc.MMainUI.zhuansheng:ShowAllControls()

--------------------------------------------------------------------------------
-- III-E. PlayerInfo 玩家信息模块
--
-- 包含头像显示 (touxiang) 和详细信息面板 (touxiangdetail)。

-- 【头像面板】  (文件: Script/UI/Item/touxiang.lua)
--
-- 【显示内容】
--   头像: Common_Avatar_BP.InitView(..., UID, IconURL, Gender, FrameLevel, PlayerLevel, ...)
--   血条: HP / HealthMax，通过 Pawn 属性系统实时读取，Binding 属性驱动 ProgressBar
--   经验条: EXP / 升级所需EXP，同上，通过 UGCGameData.GetLevelConfig 获取当前等级经验阈值
--   属性文字: 攻击力、魔法值、等级、转生次数、战斗力
--   战斗力公式: maxHp * 0.05 + attack * 0.7 + magic * 0.25，floor取整
--
-- 【战斗力公式】
--   CombatPower = floor(MaxHP * 0.05 + Attack * 0.7 + Magic * 0.25)
--   转生命中医公式：攻击力权重最高（70%），生命其次（5%），魔法较低（25%）
--
-- 【点击详情按钮】 -> touxiangdetail 面板显示

-- 【详细信息面板】  (文件: Script/UI/Item/touxiangdetail.lua)
--
-- 【显示内容】
--   基础属性: 基础攻击力/生命值/魔法值
--   当前属性: 当前最大生命
--   吞噬加成: PlayerEcexp（受神佑加成影响后的百分比）
--   吞噬值 (Bland): 血脉系统属性
--   累计消费 / VIP 等级: 通过 UGCSpendCount 和累计充值奖励配置计算
--   天赋点: PlayerTalentPoints
--   手动加点详情: 攻击/魔法/生命/血脉各属性已分配次数
--
-- 【手动加点】 RequestManualPoint(pointType)
--   pointType: "attack" | "magic" | "hp" | "bland"
--   每次消耗 1 天赋点（来自升级获得，非虚拟物品）
--   效果: 攻击力+2 / 魔法+1 / 生命+5 / 血脉+10
--   RPC: Server_AddManualPoint -> UGCPlayerState 更新 GameData 字段
--   OnManualPointResult: 收到结果后刷新 UI 显示

-- 【VIP 等级计算】 CalcVIPLevelBySpend
--   6元=1级, 30元=2级, 98元=3级, 168元=4级, 648元=5级, 1000元=6级, 3000元=7级

--------------------------------------------------------------------------------
-- III-F. XueMai 血脉模块
--
-- 血脉系统：开关 chaofeng（超风）被动技能，提供血脉属性加成。
--------------------------------------------------------------------------------

-- 【血脉面板】  (文件: Script/UI/Item/xuemai.lua)
--
-- 【功能】
--   开关按钮，根据 UGCPlayerState.UGCBloodlineEnabled 显示开启/关闭图标
--   点击: 切换状态，RPC: Server_SetBloodlineEnabled(bEnabled)
--   开启效果: 添加 chaofeng Blueprint 技能，设置 bland=1 属性
--   关闭效果: 移除 chaofeng 技能，设置 bland=0 属性
--
-- 【特殊交互】
--   进入武经剑阁副本时自动关闭血脉（防止副本外属性影响副本内）

--------------------------------------------------------------------------------
-- III-G. Addexp 直接经验模块
--
-- 直接经验系统：开关绕过吞噬过程、直接获得经验的模式。
--------------------------------------------------------------------------------

-- 【直接经验面板】  (文件: Script/UI/Item/addexp.lua)
--
-- 开关按钮，根据 UGCPlayerState.UGCDirectExpEnabled 显示图标
-- 点击: Server_SetDirectExpEnabled(bEnabled)
-- 开启时：玩家击杀怪物后直接获得经验，跳过吞噬流程

--------------------------------------------------------------------------------
-- III-H. TalentTree 天赋模块
--
-- 天赋系统：5种五行本源天赋，每种最多5级，消耗五行本源(5555)升级。
--------------------------------------------------------------------------------

-- 【天赋面板】  (文件: Script/UI/Item/TalentTree.lua)
--
-- 【5种天赋类型】
--   木之本源 (TALENT_TYPE.WOOD_SOURCE = 1):
--     每次觉醒本源获取 50% 最终生命属性增长
--     dataField = PlayerTalent1, cost = 1, maxLevel = 5
--   金之本源 (TALENT_TYPE.METAL_SOURCE = 2):
--     每次觉醒本源获取 20% 最终速度属性增长
--     dataField = PlayerTalent2, cost = 1, maxLevel = 5
--   水之本源 (TALENT_TYPE.WATER_SOURCE = 4):
--     每次觉醒本源获取 50% 最终魔法属性增长
--     dataField = PlayerTalent4, cost = 3, maxLevel = 5
--   火之本源 (TALENT_TYPE.FIRE_SOURCE = 7):
--     每次觉醒本源获取 50% 最终攻击属性增长
--     dataField = PlayerTalent7, cost = 5, maxLevel = 5
--   土之本源 (TALENT_TYPE.EARTH_SOURCE = 8):
--     每3秒恢复最大生命 5% 的血量
--     dataField = PlayerTalent8, cost = 5, maxLevel = 5
--
-- 【升级流程】
--   点击天赋按钮 -> 显示详情（名称/描述/当前等级/下一级/消耗）
--   确认加点: Server_AddTalentPointNew(talentType)
--     -> 扣除虚拟物品 5555 -> 升级天赋 -> 应用 Buff -> 保存
--   OnTalentUpgradeResult: 收到结果后刷新 UI
--
-- 【Buff 路径】 TALENT_BUFF_PATH_BY_TYPE
--   type=1 -> buff1.buff4_C (木)
--   type=2 -> buff1.buff1_C (金)
--   type=4 -> buff1.buff3_C (水)
--   type=7 -> buff1.buff2_C (火)
--   type=8 -> buff1.buff5_C (土)
--
-- 【天赋按钮】  (文件: Script/UI/Item/TalenTreeButtun.lua)
--   工具栏按钮 -> pc.MMainUI:ShowTalentTree()

--------------------------------------------------------------------------------
-- III-J. Active 活动模块
--
-- 活动面板：累计充值奖励领取 + 签到活动。
--------------------------------------------------------------------------------

-- 【活动面板】  (文件: Script/UI/Item/active.lua)
--
-- 【Tab 0: 累计充值奖励】
--   数据来源: UGCGameData.GetAllChongzhiConfig()
--   buyslot 子控件: 每行显示奖励物品图标 + 累计充值门槛 + 当前充值进度
--   按钮状态: 已领取 / 可领取 / 充值 (Go Spend)
--   充值跳转: ShopV2Manager:OpenMainUI(0) 打开商店
--
-- 【Tab 1: 签到活动】
--   动态加载 ExtendResource.SignInEvent 子面板
--   SignInEventManager:GetSignInEventComponent(playerController).MainUI
--   如组件不存在则延迟 0.3s 后重试
--
-- 【Tab 2: 预留】

--------------------------------------------------------------------------------
-- III-K. WB_Inventory 合成/分解模块
--
-- 合成和分解系统：通过配方配置消耗材料生成产物，或分解物品回收材料。
--------------------------------------------------------------------------------

-- 【合成/分解主面板】  (文件: Script/UI/Item/WB_Inventory.lua)
--
-- 【多页签】 page0-page6，来自配方配置中的"页签"字段
-- 【合成模式】
--   配置来源: UGCGameData.GetAllRecipeConfig() + GetRecipeConfig
--   按"顺序"字段排序，筛选当前页签
-- 【分解模式】
--   配置来源: UGCGameData.GetAllFenjieConfig()
--   分解产物列表（OutputMaterials）显示在右侧
--
-- 【配方数据解析】 LoadRecipeData / LoadFenjieData
--   虚拟物品ID -> UGCGameData.GetItemMapping -> ClassicItemID (真实物品ID)
--   背包物品数量: UGCBackpackSystemV2.GetItemCountV2(playerController, realItemID)
--   每帧 Tick 重新检查背包数量（用于判断材料是否足够）
--
-- 【详情面板】
--   选中配方后显示: 产物图标+数量 + 材料需求列表
--   输入材料: 当前持有数/需要数，颜色提示（绿色=足够，红色=不足）
--   输出材料: 只显示数量
--
-- 【合成/分解执行】 OnCraftButtonClicked
--   材料足够检查 -> Server_CraftItem(inputItemIDs, inputCounts, outputItemID, outputCount)
--   成功后刷新背包数量显示

-- 【配方槽位】  (文件: Script/UI/Item/WB_Slot.lua)
--   每个配方一个 WB_Slot 子控件
--   显示: 产物图标 + 背包中当前持有数/需要数
--   图标加载: UGCGameData.GetItemConfig -> ItemSmallIcon -> LoadObject
--   点击槽位 -> 主面板 ShowCraftDetails 显示详情

-- 【显示槽位】  (文件: Script/UI/Item/WB_Slot_2.lua)
--   用于合成详情面板中的输入/输出物品显示
--   输入材料: 显示"当前持有数/需要数"，颜色根据是否足够变化（绿/红）
--   输出材料: 显示"xN"格式
--   每帧 Tick 重新检查背包数量

--------------------------------------------------------------------------------
-- III-L. WB_Team 队伍模块
--
-- 组队系统：显示当前在线玩家列表，支持邀请、申请入队、踢人、离队、加好友。
--------------------------------------------------------------------------------

-- 【队伍面板】  (文件: Script/UI/Item/WB_Team.lua)
--
-- 【玩家列表】
--   数据来源: UGCGameSystem.GetAllPlayerController() 遍历所有在线玩家
--   优先使用 TeamPanelPlayerData（服务器提供的队伍信息）
--   备用：直接从每个 PC/Pawn 获取玩家名/头像/战斗力/队伍ID
--
-- 【1秒自动刷新】 UGCTimerUtility 定时器
--
-- 【每行槽位状态】 (WB_TeamSlot)
--   hidden   — 同队伍成员，不显示任何操作按钮
--   invite   — 队长看到其他队伍成员: 邀请入队
--   request  — 队员看到其他队伍成员(满2人): 显示"申请入队"
--   kick     — 队长踢人按钮
--   selfleave — 非队长离队按钮
--
-- 【RPC 操作】
--   Server_RequestTeamPanelPlayers — 请求队伍面板数据
--   Server_SendTeamInvite — 发送组队邀请
--   Server_RequestJoinTeam — 申请加入队伍
--   Server_KickFromTeam — 踢出队伍
--   Server_LeaveTeam — 离开队伍

--------------------------------------------------------------------------------
-- III-M. Chuansong 传送模块
--
-- 传送系统：提供多个传送点，通过等级和转生次数限制访问。
--------------------------------------------------------------------------------

-- 【传送面板】  (文件: Script/UI/Item/chuantishi.lua)
--
-- 【6个传送点】 — 硬编码坐标
--   fuben1: (181548, 123572, 523) — 无限制
--   fuben2: (19060, 45293, 1091)  — 需要转生1次 + 等级50
--   fuben3: (145806, -7294, 373)  — 需要转生2次 + 等级100
--   fuben4: (50184, 130875, 239)  — 需要转生3次 + 等级200
--   fuben5: (87271, 68284, 271)   — 需要转生4次 + 等级350
--   fuben6: 预留
--
-- 【传送 RPC】 Server_TeleportPlayer(x, y, z, yaw)
--
-- 【全屏遮罩】 EnterFullScreen / ExitFullScreen
--   隐藏 MainControlBaseUI + ShootingUIPanel + SkillRootPanel

--------------------------------------------------------------------------------
-- III-N. 其他 UI 模块

-- 【huicheng 回城】  (文件: Script/UI/Item/huicheng.lua)
--   回城传送坐标: (275444, 167618, 3926)
--   RPC: Server_TeleportPlayer + Server_RestoreFullHealth

-- 【tunshi 吞噬】  (文件: Script/UI/Item/tunshi.lua)
--   吞噬附近尸体: Server_DestroyNearbyCorpses

-- 【zdtunshi 自动吞噬】  (文件: Script/UI/Item/zdtunshi.lua)
--   自动吞噬开关，根据 UGCPlayerState.UGCAutoTunshiEnabled 切换图标
--   模式1002下隐藏

-- 【tunshitip 吞噬提示】  (文件: Script/UI/Item/tunshitip.lua)
--   消息队列系统: 每条消息显示 0.3 秒后自动显示下一条
--   用于批量吞噬结果通知

-- 【shouna 收起/展开】  (文件: Script/UI/Item/shouna.lua)
--   工具栏总开关: 收起时隐藏大部分工具栏按钮，展开时恢复
--   ToggleShounaButtons: 切换所有工具栏按钮的可见性

-- 【jiaocheng/xuzhang 教程】  (文件: Script/UI/jiaoxue/xuzhang.lua)
--   手册/教程面板，12个页签 (Button_0-10 + 关闭)
--   WidgetSwitcher 控制内容页面切换

-- 【help 帮助】  (文件: Script/UI/Item/help.lua)
--   简单关闭式帮助/说明面板

-- 【ta_settlement 剑阁通关结算】  (文件: Script/UI/Item/ta_settlement.lua)
--   副本通关奖励面板
--   确认: 发放奖励 (Server_GiveTaReward) + 继续生成怪物 (Server_ResumeTriggerBoxSpawning)
--   退出: 发放奖励 + 传送到主城 + 关闭 JiangeUI

-- 【Settlement 系列】  (文件: Script/UI/Item/Settlement*.lua)
--   游戏结束 / 波次完成 通知面板

-- 【NumChoose 数量选择】  (文件: Script/UI/NumChoose*.lua)
--   数量选择控件，用于输入数量

-- 【NPCBAR bossxt 系列】  (文件: Script/UI/NPCBAR/bossxt_*.lua)
--   NPC血条 / BOSS 状态条 UI

-- 【3DUI 系列】  (文件: Script/UI/3DUI/*.lua)
--   shenshou3DUI / shenjian3DUI / duanzao3DUI / jiange3D / wuxing3D / zhuansheng3D
--   装备在角色身上的 3D 挂件效果（如神兽/神剑悬浮在角色身边）

--------------------------------------------------------------------------------
-- IV. 数据持久化汇总
--------------------------------------------------------------------------------

-- 【存档层次结构】
--   UGCPlayerState.GameData (运行时数据字典)
--        |
--        v DataSave()
--   UGCPlayerStateSystem.GetPlayerArchiveData(Uid).GameRecordData (存档字典)
--        |
--        v SavePlayerArchiveData()
--   持久化存储

-- 【字段持久化映射表】
--
-- | 字段名                       | 存储位置                      | 格式                            |
-- |-----------------------------|-------------------------------|----------------------------------|
-- | PlayerShenyinData          | GameData.PlayerShenyinData     | 字符串: "bailang:unwear:1:1;..." |
-- | PlayerJiangeLevel          | GameData.PlayerJiangeLevel   | Number (1-7)                    |
-- | PlayerJiangeProgress       | GameData.PlayerJiangeProgress | Number (0-99.9)                |
-- | PlayerJiangeFloor          | GameData.PlayerJiangeFloor   | Number (已通关最高层)            |
-- | PlayerJiangeFloorClaimed   | GameData.PlayerJiangeFloorClaimed | 逗号分隔字符串: "100,200,300" |
-- | PlayerJiangeDailyClaimDate | GameData.PlayerJiangeDailyClaimDate | "YYYY-MM-DD" 字符串           |
-- | ClaimedChongzhi            | ClaimedChongzhi map + UGCClaimedChongzhiStr | "1,3,5" 逗号分隔字符串 |
-- | Talent{1-9}               | GameData.PlayerTalent{N}     | Number (0-5)                    |
-- | ManualAttack/Magic/Hp/Bland| GameData.PlayerManual*         | Number                          |
-- | BloodlineEnabled           | GameData.BloodlineEnabled     | Boolean                         |
-- | DirectExpEnabled           | GameData.DirectExpEnabled     | Boolean                         |
-- | 所有其他基础属性            | GameData.Player*              | Number                          |
-- | Archive元数据               | GameRecordData.ClaimedChongzhi | 原始领取映射表                   |
-- | Archive元数据               | GameRecordData.TotalSpendCount | Number                          |

-- 【客户端缓存】 — 以下字段存储在 PlayerController 上，用于 UI 快速访问
--   PC.SavedShenyinData — 神佑数据字符串（从服务器同步）
--   PC.SavedJiangeLevel / PC.SavedJiangeProgress — 剑阁数据（从服务器同步）
--   PC.JiangeFloor — 当前剑阁层数
--   PC.JiangeClaimedFloors — 已领取层数字符串
--   PC.JiangeDailyClaimDate — 每日奖励领取日期
--   PC.JiangeDailyAmount — 每日奖励数量

--------------------------------------------------------------------------------
-- V. RPC 参考表
--------------------------------------------------------------------------------

-- 【C->S: 客户端请求服务器】
--
-- | RPC 名称                    | 方向 | 处理者               | 用途                    |
-- |---------------------------|------|----------------------|------------------------|
-- | Server_SetShenyingSkill    | C->S | SkillSystem          | 挂载/卸载神佑技能       |
-- | Server_SetShenyinEcexp     | C->S | UGCPlayerState       | 设置Ecexp加成值         |
-- | Server_SaveShenyinData     | C->S | UGCPlayerState       | 保存神佑数据到存档      |
-- | Server_SetJiangeSkill      | C->S | SkillSystem          | 挂载/卸载剑阁技能        |
-- | Server_SetJiangeAtkBonus    | C->S | UGCPlayerState       | 设置剑阁攻击加成百分比   |
-- | Server_SaveJiangeData      | C->S | UGCPlayerState       | 保存剑阁等级和进度      |
-- | Server_ClaimJiangeFloorReward| C->S | RewardSystem         | 领取剑阁层奖励          |
-- | Server_ClaimJiangeDailyReward| C->S | RewardSystem         | 领取剑阁每日奖励        |
-- | Server_GiveTaReward        | C->S | RewardSystem         | 发放剑阁通关奖励        |
-- | Server_AddTalentPointNew   | C->S | UGCPlayerState       | 升级天赋类型            |
-- | Server_AddManualPoint      | C->S | UGCPlayerState       | 手动分配天赋点          |
-- | Server_SetBloodlineEnabled | C->S | SkillSystem          | 开关血脉技能            |
-- | Server_SetDirectExpEnabled | C->S | UGCPlayerState       | 开关直接经验模式        |
-- | Server_ClaimChongzhiReward | C->S | RewardSystem         | 领取累计充值奖励        |
-- | Server_RemoveVirtualItem   | C->S | VirtualItemSystem     | 消耗虚拟物品            |
-- | Server_RemoveBackpackItem   | C->S | VirtualItemSystem     | 消耗背包物品            |
-- | Server_CraftItem           | C->S | UGCPlayerState       | 合成/分解物品           |
-- | Server_TeleportPlayer      | C->S | PlayerController      | 传送玩家Pawn            |
-- | Server_DestroyNearbyCorpses | C->S | PlayerController      | 吞噬附近尸体            |
-- | Server_RestoreFullHealth   | C->S | PlayerController      | 恢复玩家生命至满血      |
-- | Server_RequestTeamPanelPlayers| C->S | PlayerController      | 请求队伍面板玩家数据    |
-- | Server_SendTeamInvite      | C->S | PlayerController      | 发送组队邀请           |
-- | Server_RequestJoinTeam     | C->S | PlayerController      | 申请加入队伍           |
-- | Server_KickFromTeam        | C->S | PlayerController      | 踢出队伍成员           |
-- | Server_LeaveTeam           | C->S | PlayerController      | 离开当前队伍           |
-- | Server_EnterJiangeInstance | C->S | PlayerController      | 进入剑阁副本           |
-- | Server_Rebirth             | C->S | UGCPlayerState       | 执行转生               |
-- | Server_RequestInit          | C->S | UGCPlayerState       | 请求服务器数据初始化    |
-- | Server_AddSpendCount       | C->S | VirtualItemSystem     | 累加消费计次           |
-- | Server_AddShopBuyCount     | C->S | VirtualItemSystem     | 累加商店购买计次       |

-- 【S->C: 服务器通知客户端】
--
-- | RPC 名称                         | 方向 | 接收方        | 用途                    |
-- |--------------------------------|------|--------------|------------------------|
-- | Client_SyncShenyinData          | S->C | PC.SavedShenyinData | 同步神佑数据到客户端  |
-- | Client_SyncJiangeData           | S->C | PC.SavedJiangeLevel/Progress | 同步剑阁数据 |
-- | Client_UpdateJiangeFloor         | S->C | PC.JiangeFloor | 同步当前剑阁层数      |
-- | Client_SyncJiangeRewardData     | S->C | PC.*          | 同步层奖励/每日奖励数据 |
-- | Client_OnTalentUpgradeResult    | S->C | TalentTree    | 天赋升级结果反馈        |
-- | Client_OnManualPointResult      | S->C | touxiangdetail | 手动加点结果反馈       |
-- | Client_OnChongzhiClaimResult   | S->C | buyslot      | 充值奖励领取结果反馈     |
-- | Client_OnJiangeFloorClaimResult| S->C | wujingjiange | 层奖励领取结果反馈       |
-- | Client_OnJiangeDailyClaimResult| S->C | wujingjiange | 每日奖励领取结果反馈     |
-- | Client_OnExpBlockedByRebirth   | S->C | PC           | 通知经验被转生封锁      |
-- | Client_OnPlayerLevelUp         | S->C | PC           | 升级通知               |
-- | Client_OnJiangeForgeConsumeResult| S->C | jiange     | 锻造石消耗结果反馈      |

--------------------------------------------------------------------------------
-- 文档结束
--------------------------------------------------------------------------------
