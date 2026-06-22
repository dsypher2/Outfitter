local API = {}; OutfitterAPI = API;
local IS_WOW1002 = select(4, GetBuildInfo()) >= 100002 or nil;

OutfitterAPI.IsWoW1002 = true  -- Midnight 12.x is always >= 10.0.2

function API:GetContainerItemLink(...)
    if C_Container and C_Container.GetContainerItemLink then return C_Container.GetContainerItemLink(...) end
  return GetContainerItemLink(...)
end

function API:GetContainerItemInfo(...)
    if C_Container and C_Container.GetContainerItemInfo then
        local containerInfo = C_Container.GetContainerItemInfo(...)
        if containerInfo then
            return containerInfo.iconFileID
        end
        return
    end
  return GetContainerItemInfo(...)
end

function API:ContainerIDToInventoryID(...)
    if C_Container and C_Container.ContainerIDToInventoryID then return C_Container.ContainerIDToInventoryID(...) end
  return ContainerIDToInventoryID(...)
end

function API:GetContainerNumFreeSlots(...)
    if C_Container and C_Container.GetContainerNumFreeSlots then return C_Container.GetContainerNumFreeSlots(...) end
  return GetContainerNumFreeSlots(...)
end

function API:UseContainerItem(...)
    if C_Container and C_Container.UseContainerItem then return C_Container.UseContainerItem(...) end
  return UseContainerItem(...)
end

function API:GetContainerNumSlots(...)
    if C_Container and C_Container.GetContainerNumSlots then return C_Container.GetContainerNumSlots(...) end
  return GetContainerNumSlots(...)
end

function API:PickupContainerItem(...)
    if C_Container and C_Container.PickupContainerItem then return C_Container.PickupContainerItem(...) end
  return PickupContainerItem(...)
end

function API:ShowContainerSellCursor(...)
    if C_Container and C_Container.ShowContainerSellCursor then return C_Container.ShowContainerSellCursor(...) end
  return ShowContainerSellCursor(...)
end

function API:GetNumTrackingTypes(...)
    if C_Minimap and C_Minimap.GetNumTrackingTypes then return C_Minimap.GetNumTrackingTypes(...) end
    return GetNumTrackingTypes(...)
end

function API:GetTrackingInfo(...)
    if C_Minimap and C_Minimap.GetTrackingInfo then
        local result = C_Minimap.GetTrackingInfo(...)
        if type(result) == 'table' then
            return result.name, result.texture, result.active
        else
            return C_Minimap.GetTrackingInfo(...)
        end
    else
        return GetTrackingInfo(...)
    end
end

function API:SetTracking(...)
    if C_Minimap and C_Minimap.SetTracking then return C_Minimap.SetTracking(...) end
    return SetTracking(...)
end

-- Midnight 12.x: GetInventoryItemTexture removed -> use GetInventoryItemID + C_Item.GetItemIconByID
function API:GetInventoryItemTexture(unit, slotID)
    local itemID = GetInventoryItemID(unit, slotID)
    if itemID then
        return C_Item.GetItemIconByID(itemID)
    end
end

-- Midnight 12.x: GetInventoryItemQuality removed -> derive from GetInventoryItemLink + GetItemInfo
function API:GetInventoryItemQuality(unit, slotID)
    local link = GetInventoryItemLink(unit, slotID)
    if link then
        local _, _, quality = C_Item.GetItemInfo(link)
        return quality
    end
end

-- Midnight 12.x: GetProfessions / GetProfessionInfo removed
-- Use C_TradeSkillUI to enumerate profession skill lines and get their icons
function API:GetProfessions()
    if C_TradeSkillUI and C_TradeSkillUI.GetAllProfessionTradeSkillLines then
        return C_TradeSkillUI.GetAllProfessionTradeSkillLines()
    end
    -- fallback (pre-TWW)
    return GetProfessions and GetProfessions() or {}
end

function API:GetProfessionInfo(skillLineID)
    if C_TradeSkillUI and C_TradeSkillUI.GetProfessionInfoBySkillLineID then
        local info = C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLineID)
        if info then
            return info.professionName, info.professionIconID
        end
    end
    -- fallback (pre-TWW)
    if GetProfessionInfo then
        return GetProfessionInfo(skillLineID)
    end
end

-- Midnight 12.x: GetSpellTabInfo removed -> use C_SpellBook.GetSpellBookSkillLineInfo
-- Returns: name, texture, offset, numSpells (same shape as old GetSpellTabInfo)
function API:GetSpellTabInfo(tabIndex)
    if C_SpellBook and C_SpellBook.GetSpellBookSkillLineInfo then
        local info = C_SpellBook.GetSpellBookSkillLineInfo(tabIndex)
        if info then
            return info.name, info.iconID, info.itemIndexOffset, info.numSpellBookItems
        end
        return nil
    end
    -- fallback
    return GetSpellTabInfo and GetSpellTabInfo(tabIndex)
end

-- Midnight 12.x: GetNumSpellTabs removed -> use C_SpellBook.GetNumSpellBookSkillLines
function API:GetNumSpellTabs()
    if C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines then
        return C_SpellBook.GetNumSpellBookSkillLines()
    end
    return GetNumSpellTabs and GetNumSpellTabs() or 0
end

-- Midnight 12.x: GetSpellTexture(index, bookType) signature changed
-- Now use C_SpellBook.GetSpellBookItemInfo(index, bookType).iconID
function API:GetSpellTexture(spellIndex, bookType)
    if C_SpellBook and C_SpellBook.GetSpellBookItemInfo then
        local info = C_SpellBook.GetSpellBookItemInfo(spellIndex, bookType or Enum.SpellBookSpellBank.Player)
        return info and info.iconID
    end
    return GetSpellTexture and GetSpellTexture(spellIndex, bookType)
end

-- Midnight 12.x: IS_WOW1002 compat flag update
API.IsWoW1200 = (select(4, GetBuildInfo()) >= 120000) or nil

-- Midnight 12.x: BOOKTYPE_SPELL / BOOKTYPE_PET constants removed
-- Provide fallback values so existing code doesn't error on reference
if not BOOKTYPE_SPELL then BOOKTYPE_SPELL = Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player or "spell" end
if not BOOKTYPE_PET   then BOOKTYPE_PET   = Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Pet   or "pet"   end
OutfitterAPI.IsWoW1200 = true  -- Midnight 12.x
