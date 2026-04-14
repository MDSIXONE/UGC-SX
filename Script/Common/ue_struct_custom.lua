-- auto exported UStruct while compiling 

-- sorted by struct name asc 

---@class FSignInEventData
---@field EventID int32
---@field DayNum int32
---@field NextDayTime int32
---@field SupplementDayNum int32

---@class FSignInAward
---@field ItemID int32
---@field ItemNum int32

---@class FSignInEventConfig
---@field EventID int32
---@field EventName FString
---@field Type ESignInEventType
---@field StartTime FDateTime
---@field EndTime FDateTime
---@field Desc FString
---@field SupplementDay int32
---@field SupplementItemID int32
---@field SupplementItemNum int32
---@field AwardTablePath FSoftObjectPath
---@field HighLight7thDay bool

---@class chongzhi
---@field itemid int32
---@field itemnum int32
---@field itemcount int32

---@class fubenreward
---@field 虚拟物品ID int32
---@field 数量 int32

---@class hechengjiegou
---@field 合成材料 objectname
---@field 所需数量 int32
---@field 材料虚拟物品ID int32

---@class hecjgt
---@field 虚拟物品ID int32
---@field 数量 int32
---@field 顺序 int32
---@field 页签 int32
---@field 合成配方 hechengjiegou[]

---@class LeveConfig
---@field Level int32
---@field Exp int32
---@field AddHP int32
---@field AddHIT int32
---@field AddMG int32

---@class mobconfig
---@field moblevel int32
---@field mobhp int32
---@field mobat int32

---@class MonsterConfig
---@field MonsterID int32
---@field MonsterName int32
---@field MonsterClass int32
---@field MonsterType int32
---@field KillExp int32
---@field MonsterHealth int32
---@field MonsterBaseAttack int32

---@class taskconfig
---@field taskname FString
---@field taskdetail FString
---@field taskawardid int32
---@field awardname FString
---@field awardnum int32
---@field page int32
---@field type int32

---@class GiftPackData
---@field ID int32
---@field ItemID int32
---@field GiftPackType EGiftPackType
---@field OpenWay EGiftPackOpenType
---@field DropID int32
---@field DropGroupID int32

---@class LotteryDrawInfo
---@field LotteryID int32
---@field LotteryRecords LotteryRecord[]
---@field TotalDrawTimes int32

---@class LotteryDrawItemInfo
---@field ID int32
---@field Num int32
---@field DropType FString
---@field IsDrawTenth bool

---@class LotteryExchangeInfo
---@field ProductID int32
---@field ExchangeInfo LotteryExchangeItemInfo[]

---@class LotteryExchangeItemInfo
---@field ExchangeNum int32
---@field ExchangeTime int32

---@class LotteryGiftProgressInfo
---@field LotteryID int32
---@field ProgressInfo LotteryGiftProgressReciveState[]

---@class LotteryGiftProgressReciveState
---@field Progress int32
---@field State bool

---@class LotteryInfo
---@field LotteryGroup bool
---@field Lottery bool
---@field LotteryExchangeInfo bool
---@field LotteryGiftProgress bool
---@field LotterySkipAnim bool

---@class LotteryRecord
---@field DrawItemInfo LotteryDrawItemInfo
---@field DrawTime int32

---@class LotteryData
---@field ID int32
---@field GiftProgressRewards ProgressReward[]
---@field LotteryRule FString
---@field DailyDrawLimit int32
---@field DailyDrawGroup int32
---@field OverrideDropID int32
---@field DropGroupID int32
---@field DrawCostID int32
---@field TenDrawCostNum int32
---@field OverrideGuarantDropID int32
---@field GuarantDropGroupID int32
---@field IsFirstDrawDiscountOpen bool
---@field FirstDrawDiscountCost int32
---@field FirstDrawDiscountResetType ELotteryResetType
---@field OverrideFirstDrawGuarantDropID int32
---@field FirstDrawGuarantDropGroupID int32
---@field FirstDrawGuarantResetType ELotteryResetType
---@field OneDrawCostNum int32
---@field Name FString
---@field Icon FSoftObjectPath

---@class ProgressItem
---@field ItemID int32
---@field ItemCount int32

---@class ProgressReward
---@field Progress int32
---@field ItemList ProgressItem[]
---@field Desc FString

---@class ShopV2_ItemQuality
---@field ItemID int32
---@field QualityRank int32

---@class ShopV2_TabInfo
---@field TabID int32
---@field TabName FString
---@field TabShopName FString
---@field TabShopDesc FString

---@class FEventTabInfo
---@field EventID int32
---@field TabName FString
---@field ShowPeriod bool

