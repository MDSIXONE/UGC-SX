UGCGameSystem.UGCRequire('Script.GameAttribute.game_attribute_type')
local UGCGlobalDamageCalculation = {}

function UGCGlobalDamageCalculation:GetCalculationResult(Context, ExtraResult)
    local VictimActor				= UGCAttributeSystem.GetVictimFromContext(Context)      --受害者
    local Causer					= UGCAttributeSystem.GetCauserFromContext(Context)      --枪等武器或者人(空手情况)
    local InstigatorController      = UGCAttributeSystem.GetInstigatorFromContext(Context)  --攻击者的Controller
    local CauserActor = UGCGameSystem.GetPlayerPawnByPlayerController(InstigatorController)  --攻击者角色
    print("[UGCGlobalDamageCalculation] Context CauserActor --->"..tostring(CauserActor))
    print("[UGCGlobalDamageCalculation] Context VictimActor --->"..tostring(VictimActor))  
    -- 禁止角色自己的攻击命中自己
    if CauserActor and VictimActor and CauserActor == VictimActor then
        return 0, ExtraResult
    end

    -- 同阵营免伤：如果攻击者和受害者是友好关系（同阵营），伤害为0
    if CauserActor and VictimActor and CauserActor ~= VictimActor then
        local relation = UGCCampSystem.GetCampRelationWithActor(CauserActor, VictimActor)
        if relation == 0 then
            -- 0=友好，同阵营不造成伤害
            return 0, ExtraResult
        end
    end

    -- 传入的原始伤害数值
    local SkillAttack = UGCAttributeSystem.GetSourceMagnitudeFromContext(Context)
    local Attack = UGCAttributeSystem.GetGameAttributeValue(CauserActor, "Attack")
    -- 根据伤害类型计算武器伤害
    if Causer ~= nil and CauserActor ~= nil then
        if UGCAttributeSystem.GetDamageTypeFromContext(Context) == 1 then
            local BaseImpactDamageWrapper = UGCAttributeSystem.GetGameAttributeValue(Causer, "BaseImpactDamageWrapper")
            SkillAttack = Attack * BaseImpactDamageWrapper
        elseif UGCAttributeSystem.GetDamageTypeFromContext(Context) == 2 then
            SkillAttack = Attack * 0.2
        end
    end
    return SkillAttack, ExtraResult
end

return UGCGlobalDamageCalculation