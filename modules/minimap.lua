local addon = select(2, ...)
--local config = addon.config;
--local event = addon.package;
--local class = addon._class;
--local unpack = unpack;
local select = select;
local pairs = pairs;
local ipairs = ipairs;
local UnitName = UnitName;
local UnitClass = UnitClass;
local _G = getfenv(0);

local UIFrameFlash = UIFrameFlash

local ToggleCharacter = ToggleCharacter
--local ToggleSpellBook = ToggleSpellBook
--local ToggleTalentFrame = ToggleTalentFrame
local ToggleAchievementFrame = ToggleAchievementFrame
local ToggleFriendsFrame = ToggleFriendsFrame
local ToggleHelpFrame = ToggleHelpFrame
local ToggleFrame = ToggleFrame

local PLAYER_ENTERING_WORLD, Minimap_GrabButtons

local minimap = CreateFrame("Frame", "pretty_actionbar_minimap", UIParent)
minimap:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
minimap:SetSize(Minimap:GetWidth(), Minimap:GetHeight())


do
    local find = string.find
    local len = string.len
    local sub = string.sub
    local ceil = math.ceil
    local tinsert = table.insert

    local LockButton
    local UnlockButton
    local CheckVisibility
    --local GetVisibilbleList
    local GrabMinimapButtons
    local SkinMinimapButton
    local UpdateLayout

    local ignoreButtons = {
        "BattlefieldMinimap",
        "ButtonCollectFrame",
        "GameTimeFrame",
        "MiniMapBattlefieldFrame",
        "MiniMapLFGFrame",
        "MiniMapMailFrame",
        "MiniMapPing",
        "MiniMapRecordingButton",
        --"MiniMapTracking",
        --"MiniMapTrackingButton",
        "MiniMapVoiceChatFrame",
        "MiniMapWorldMapButton",
        "Minimap",
        "MinimapBackdrop",
        "MinimapToggleButton",
        "MinimapZoneTextButton",
        "MinimapZoomIn",
        "MinimapZoomOut",
        "TimeManagerClockButton"
    }

    local genericIgnores = {
        "GuildInstance",
        "GatherMatePin",
        "GatherNote",
        "GuildMap3Mini",
        "HandyNotesPin",
        "LibRockConfig-1.0_MinimapButton",
        "NauticusMiniIcon",
        "WestPointer",
        "poiMinimap",
        "Spy_MapNoteList_mini"
    }
    local partialIgnores = { "Node", "Note", "Pin" }
    local whiteList = { "LibDBIcon" }
    local buttonFunctions = {
        "SetParent",
        "SetFrameStrata",
        "SetFrameLevel",
        "ClearAllPoints",
        "SetPoint",
        "SetScale",
        "SetSize",
        "SetWidth",
        "SetHeight"
    }
    local grabberFrame
    local needUpdate
    local minimapFrames
    local skinnedButtons

    function LockButton(btn)
        for _, func in ipairs(buttonFunctions) do
            btn[func] = addon._noop
        end
    end

    function UnlockButton(btn)
        for _, func in ipairs(buttonFunctions) do
            btn[func] = nil
        end
    end

    function CheckVisibility()
        local updateLayout

        for _, button in ipairs(skinnedButtons) do
            if button:IsVisible() and button.__hidden then
                button.__hidden = false
                updateLayout = true
            elseif not button:IsVisible() and not button.__hidden then
                button.__hidden = true
                updateLayout = true
            end
        end

        return updateLayout
    end

    function GetVisibleList()
        local t = {}

        for _, button in ipairs(skinnedButtons) do
            if button:IsVisible() then
                tinsert(t, button)
            end
        end

        return t
    end

    function GrabMinimapButtons()
        for _, frame in ipairs(minimapFrames) do
            for i = 1, frame:GetNumChildren() do
                local object = select(i, frame:GetChildren())

                if object and object:IsObjectType("Button") then
                    SkinMinimapButton(object)
                end
            end
        end

        if _G.MiniMapMailFrame then
            SkinMinimapButton(_G.MiniMapMailFrame)
        end

        if _G.MiniMapTrackingButton then
            SkinMinimapButton(_G.MiniMapTracking)
        end

        if _G.AtlasButtonFrame then
            SkinMinimapButton(_G.AtlasButton)
        end
        if _G.FishingBuddyMinimapFrame then
            SkinMinimapButton(_G.FishingBuddyMinimapButton)
        end
        if _G.HealBot_MMButton then
            SkinMinimapButton(_G.HealBot_MMButton)
        end

        if needUpdate or CheckVisibility() then
            UpdateLayout()
        end
    end

    function SkinMinimapButton(button)
        if not button or button.__skinned then return end

        local name = button:GetName()
        if not name then return end

        if button:IsObjectType("Button") then
            local validIcon

            for i = 1, #whiteList do
                if sub(name, 1, len(whiteList[i])) == whiteList[i] then
                    validIcon = true
                    break
                end
            end

            if not validIcon then
                if tContains(ignoreButtons, name) then
                    return
                end

                for i = 1, #genericIgnores do
                    if sub(name, 1, len(genericIgnores[i])) == genericIgnores[i] then
                        return
                    end
                end

                for i = 1, #partialIgnores do
                    if find(name, partialIgnores[i]) then
                        return
                    end
                end
            end

            button:SetPushedTexture(nil)
            button:SetHighlightTexture(nil)
            button:SetDisabledTexture(nil)
        end

        for i = 1, button:GetNumRegions() do
            local region = select(i, button:GetRegions())

            if region:GetObjectType() == "Texture" then
                local texture = region:GetTexture()

                if texture and (find(texture, "Border") or find(texture, "Background") or find(texture, "AlphaMask")) then
                    region:SetTexture(nil)
                else
                    if name == "BagSync_MinimapButton" then
                        region:SetTexture("Interface\\AddOns\\BagSync\\media\\icon")
                    elseif name == "DBMMinimapButton" then
                        region:SetTexture("Interface\\Icons\\INV_Helmet_87")
                    elseif name == "OutfitterMinimapButton" then
                        if region:GetTexture() == "Interface\\Addons\\Outfitter\\Textures\\MinimapButton" then
                            region:SetTexture(nil)
                        end
                    elseif name == "SmartBuff_MiniMapButton" then
                        region:SetTexture("Interface\\Icons\\Spell_Nature_Purge")
                    elseif name == "VendomaticButtonFrame" then
                        region:SetTexture("Interface\\Icons\\INV_Misc_Rabbit_2")
                    elseif name == "MiniMapTracking" then
                        for m = 1, MiniMapTrackingButton:GetNumRegions() do
                            local trackRegion = select(m, MiniMapTrackingButton:GetRegions())
                            if trackRegion:GetObjectType() == "Texture" then
                                local trackTexture = trackRegion:GetTexture()
                                if trackTexture and (find(trackTexture, "Border") or find(trackTexture, "Background") or find(trackTexture, "AlphaMask")) then
                                    trackRegion:SetTexture(nil)
                                end
                            end
                        end
                    end

                    region:ClearAllPoints()
                    region:SetPoint("TOPLEFT", 2, -2)
                    region:SetPoint("BOTTOMRIGHT", -2, 2)
                    region:SetDrawLayer("ARTWORK")
                    region.SetPoint = addon._noop
                end
            end
        end

        button:SetParent(grabberFrame)
        button:SetFrameLevel(grabberFrame:GetFrameLevel() + 5)
        button:SetBackdrop({
            bgFile = "Interface\\AddOns\\pretty_actionbar\\assets\\DarkSandstone-Tile",
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })

        LockButton(button)

        button:SetScript("OnDragStart", nil)
        button:SetScript("OnDragStop", nil)

        button.__hidden = button:IsVisible() and true or false
        button.__skinned = true
        tinsert(skinnedButtons, button)

        needUpdate = true
    end

    function UpdateLayout()
        if #skinnedButtons == 0 then return end

        local spacing = 2
        local visibleButtons = GetVisibleList()

        if #visibleButtons == 0 then
            grabberFrame:SetSize(21 + (spacing * 2), 21 + (spacing * 2))
            return
        end

        local numButtons = #visibleButtons
        local buttonsPerRow = 6
        local numColumns = ceil(numButtons / buttonsPerRow)

        if buttonsPerRow > numButtons then
            buttonsPerRow = numButtons
        end

        local barWidth = (21 * numColumns) + (1 * (numColumns - 1)) + spacing * 2
        local barHeight = (21 * buttonsPerRow) + (1 * (buttonsPerRow - 1)) + spacing * 2

        grabberFrame:SetSize(barWidth, barHeight)

        for i, button in ipairs(visibleButtons) do
            UnlockButton(button)

            button:SetSize(21, 21)
            button:ClearAllPoints()

            if i == 1 then
                button:SetPoint("BOTTOMRIGHT", grabberFrame, "BOTTOMRIGHT", -spacing, 0)
            elseif (i - 1) % buttonsPerRow == 0 then
                button:SetPoint("TOPRIGHT", visibleButtons[i - buttonsPerRow], "BOTTOMRIGHT", 0, -spacing)
            else
                button:SetPoint("RIGHT", visibleButtons[i - 1], "LEFT", -spacing, 0)
            end

            LockButton(button)
        end

        needUpdate = nil
    end

    local wipe = wipe or table.wipe
    local weaktable = { __mode = "v" }
    function addon.WeakTable(t)
        return setmetatable(wipe(t or {}), weaktable)
    end

    local TickerPrototype = {}
    local TickerMetatable = { __index = TickerPrototype }

    local WaitTable = {}

    local new, del
    do
        local list = { cache = {}, trash = {} }
        setmetatable(list.trash, { __mode = "v" })

        function new()
            return tremove(list.cache) or {}
        end

        function del(t)
            if t then
                setmetatable(t, nil)
                for k, _ in pairs(t) do
                    t[k] = nil
                end
                tinsert(list.cache, 1, t)
                while #list.cache > 20 do
                    tinsert(list.trash, 1, tremove(list.cache))
                end
            end
        end
    end

    local function WaitFunc(self, elapsed)
        local total = #WaitTable
        local i = 1

        while i <= total do
            local ticker = WaitTable[i]

            if ticker._cancelled then
                del(tremove(WaitTable, i))
                total = total - 1
            elseif ticker._delay > elapsed then
                ticker._delay = ticker._delay - elapsed
                i = i + 1
            else
                ticker._callback(ticker)

                if ticker._iterations == -1 then
                    ticker._delay = ticker._duration
                    i = i + 1
                elseif ticker._iterations > 1 then
                    ticker._iterations = ticker._iterations - 1
                    ticker._delay = ticker._duration
                    i = i + 1
                elseif ticker._iterations == 1 then
                    del(tremove(WaitTable, i))
                    total = total - 1
                end
            end
        end

        if #WaitTable == 0 then
            self:Hide()
        end
    end

    local WaitFrame = _G.WaitFrame or CreateFrame("Frame", "WaitFrame", UIParent)
    WaitFrame:SetScript("OnUpdate", WaitFunc)

    local function AddDelayedCall(ticker, oldTicker)
        ticker = (oldTicker and type(oldTicker) == "table") and oldTicker or ticker
        tinsert(WaitTable, ticker)
        WaitFrame:Show()
    end

    local function ValidateArguments(duration, callback, callFunc)
        if type(duration) ~= "number" then
            error(format(
                    "Bad argument #1 to '" .. callFunc .. "' (number expected, got %s)",
                    duration ~= nil and type(duration) or "no value"
            ), 2)
        elseif type(callback) ~= "function" then
            error(format(
                    "Bad argument #2 to '" .. callFunc .. "' (function expected, got %s)",
                    callback ~= nil and type(callback) or "no value"
            ), 2)
        end
    end

    local function After(duration, callback, ...)
        ValidateArguments(duration, callback, "After")

        local ticker = new()

        ticker._iterations = 1
        ticker._delay = max(0.01, duration)
        ticker._callback = callback

        AddDelayedCall(ticker)
    end

    local function CreateTicker(duration, callback, iterations, ...)
        local ticker = new()
        setmetatable(ticker, TickerMetatable)

        ticker._iterations = iterations or -1
        ticker._delay = max(0.01, duration)
        ticker._duration = ticker._delay
        ticker._callback = callback

        AddDelayedCall(ticker)
        return ticker
    end

    local function NewTicker(duration, callback, iterations, ...)
        ValidateArguments(duration, callback, "NewTicker")
        return CreateTicker(duration, callback, iterations, ...)
    end

    local function NewTimer(duration, callback, ...)
        ValidateArguments(duration, callback, "NewTimer")
        return CreateTicker(duration, callback, 1, ...)
    end

    local function CancelTimer(ticker, silent)
        if ticker and ticker.Cancel then
            ticker:Cancel()
        elseif not silent then
            error("CancelTimer(timer[, silent]): '" .. tostring(ticker) .. "' - no such timer registered")
        end
        return nil
    end

    function TickerPrototype:Cancel()
        self._cancelled = true
    end

    function TickerPrototype:IsCancelled()
        return self._cancelled
    end

    addon.After = After
    addon.NewTicker = NewTicker
    addon.NewTimer = NewTimer
    addon.CancelTimer = CancelTimer

    function Minimap_GrabButtons()
        skinnedButtons = addon.WeakTable(skinnedButtons)
        minimapFrames = { Minimap, MinimapBackdrop }

        grabberFrame = CreateFrame("Frame", "MinimapButtonGrabber", Minimap)
        grabberFrame:SetSize(21, 21)
        grabberFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 0, -25)
        grabberFrame:SetFrameStrata("LOW")
        grabberFrame:SetClampedToScreen(true)

        GrabMinimapButtons()
        addon.NewTicker(5, GrabMinimapButtons)
    end
end

do
    local menuFrame

    local menuList = {
        {
            text = CHARACTER_BUTTON,
            notCheckable = 1,
            func = function()
                ToggleCharacter("PaperDollFrame")
            end
        },
        {
            text = SPELLBOOK_ABILITIES_BUTTON,
            notCheckable = 1,
            func = function()
                ToggleFrame(SpellBookFrame)
            end
        },
        {
            text = TALENTS_BUTTON,
            notCheckable = 1,
            func = function()
                TalentMicroButton:Click()
            end
        },
        {
            text = ACHIEVEMENT_BUTTON,
            notCheckable = 1,
            func = ToggleAchievementFrame
        },
        {
            text = QUESTLOG_BUTTON,
            notCheckable = 1,
            func = function()
                ToggleFrame(QuestLogFrame)
            end
        },
        {
            text = SOCIAL_BUTTON,
            notCheckable = 1,
            func = function()
                ToggleFriendsFrame(1)
            end
        },
        {
            text = "Calendar",
            notCheckable = 1,
            func = function()
                GameTimeFrame:Click()
            end
        },
        {
            text = BATTLEFIELD_MINIMAP,
            notCheckable = 1,
            func = ToggleBattlefieldMinimap
        },
        {
            text = TIMEMANAGER_TITLE,
            notCheckable = 1,
            func = ToggleTimeManager
        },
        {
            text = PLAYER_V_PLAYER,
            notCheckable = 1,
            func = function()
                ToggleFrame(PVPParentFrame)
            end
        },
        {
            text = LFG_TITLE,
            notCheckable = 1,
            func = function()
                ToggleFrame(LFDParentFrame)
            end
        },
        {
            text = LOOKING_FOR_RAID,
            notCheckable = 1,
            func = function()
                ToggleFrame(LFRParentFrame)
            end
        },
        {
            text = MAINMENU_BUTTON,
            notCheckable = 1,
            func = function()
                if EscapeMenu:IsShown() then
                    PlaySound("igMainMenuQuit")
                    HideUIPanel(EscapeMenu)
                else
                    PlaySound("igMainMenuOpen")
                    ShowUIPanel(EscapeMenu)
                end
            end
        },
        {
            text = HELP_BUTTON,
            notCheckable = 1,
            func = ToggleHelpFrame
        }
    }

    -- handles mouse wheel action on minimap
    local function Minimap_OnMouseWheel(_, z)
        local c = Minimap:GetZoom()
        if z > 0 and c < 5 then
            Minimap:SetZoom(c + 1)
        elseif (z < 0 and c > 0) then
            Minimap:SetZoom(c - 1)
        end
    end

    -- handle mouse clicks on minimap
    local function Minimap_OnMouseUp(self, button)
        -- create the menu frame
        menuFrame = menuFrame or CreateFrame("Frame", "MinimapRightClickMenu", UIParent, "UIDropDownMenuTemplate")

        if button == "RightButton" then
            EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
        elseif button == "MiddleButton" then
            ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self)
        else
            Minimap_OnClick(self)
        end
    end

    -- called once the user enter the world
    function PLAYER_ENTERING_WORLD()
        -- fix the stupid buff with MoveAnything Condolidate buffs
        if not (_G.MOVANY or _G.MovAny) then
            ConsolidatedBuffs:SetParent(UIParent)
            ConsolidatedBuffs:ClearAllPoints()
            ConsolidatedBuffs:SetPoint("TOPRIGHT", -205, -13)
            ConsolidatedBuffs.SetPoint = addon._noop
        end

        for _, v in pairs({
            MinimapBorder,
            MiniMapMailBorder,
            _G.QueueStatusMinimapButtonBorder,
            -- select(1, TimeManagerClockButton:GetRegions()),
        }) do
            v:SetVertexColor(.3, .3, .3)
        end

        MinimapBorderTop:Hide()
        MinimapZoomIn:Hide()
        MinimapZoomOut:Hide()
        MiniMapWorldMapButton:Hide()
        GameTimeFrame:Hide()
        --core:Kill(GameTimeFrame)
        --core:Kill(MiniMapTracking)
        MinimapZoneTextButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -5, 0)
        MinimapZoneTextButton:SetFrameLevel(Minimap:GetFrameLevel() + 2)
        MinimapZoneText:SetPoint("TOPLEFT", "MinimapZoneTextButton", "TOPLEFT", 5, 5)
        --[[         if DB.zone then
            MinimapZoneTextButton:Hide()
        else
            MinimapZoneTextButton:Show()
        end ]]
        Minimap:EnableMouseWheel(true)

        Minimap:SetScript("OnMouseWheel", Minimap_OnMouseWheel)
        Minimap:SetScript("OnMouseUp", Minimap_OnMouseUp)

        -- Make is square
        MinimapBorder:SetTexture(nil)
        Minimap:SetFrameLevel(2)
        Minimap:SetFrameStrata("BACKGROUND")
        Minimap:SetMaskTexture([[Interface\ChatFrame\ChatFrameBackground]])
        --Minimap:SetBackdrop({
        --bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
        --insets = { top = -2, bottom = -1, left = -2, right = -1 }
        --})
        Minimap:SetBackdropColor(0, 0, 0, 1)
        MinimapCluster:SetScale(1.2)

        local textureParent = CreateFrame("Frame", nil, Minimap)
        textureParent:SetFrameLevel(Minimap:GetFrameLevel() + 1)
        textureParent:SetPoint("BOTTOMRIGHT", 0, 0)
        textureParent:SetPoint("TOPLEFT", 0, 0)
        Minimap.TextureParent = textureParent

        local border = textureParent:CreateTexture(nil, "BORDER", nil, 1)
        border:SetPoint("CENTER", 0, 0)
        border:SetTexture("Interface\\AddOns\\SimpleFramesEnhanced\\Media\\Border\\minimap-square-100")
        border:SetTexCoord(1 / 1024, 433 / 1024, 1 / 512, 433 / 512)
        border:SetSize(Minimap:GetWidth() + 10, Minimap:GetHeight() + 10)
        --E:SmoothColor(border)
        Minimap.Border = border

        local background = Minimap:CreateTexture(nil, "BACKGROUND", nil, -7)
        background:SetAllPoints(Minimap)
        background:SetTexture("Interface\\HELPFRAME\\DarkSandstone-Tile", "REPEAT", "REPEAT")
        background:SetHorizTile(true)
        background:SetVertTile(true)
        background:Hide()
        Minimap.Background = background

        --[[         if DB.hide then
            MinimapCluster:Hide()
        elseif not DB.combat and not core.InCombat then
            MinimapCluster:Show()
        end ]]

        Minimap_GrabButtons()

    end

    addon.package:RegisterEvents(PLAYER_ENTERING_WORLD, "PLAYER_ENTERING_WORLD"
    );

    local pinger
    local timer
    local frame = CreateFrame("Frame")
    local player = UnitName("player")
    addon.package:RegisterEvents(function(_, unit)
        if UnitName(unit) ~= player then
            if not pinger then
                pinger = frame:CreateFontString(nil, "OVERLAY")
                pinger:SetFont("Fonts\\FRIZQT__.ttf", 13, "OUTLINE")
                pinger:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
                pinger:SetJustifyH("CENTER")
            end

            if not timer or (timer and time() - timer > 1) then
                local unitName = UnitName(unit)
                if unitName then
                    local classColor = (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[select(2, UnitClass(unit))])
                            or (RAID_CLASS_COLORS and RAID_CLASS_COLORS[select(2, UnitClass(unit))])
                            or { r = 1, g = 1, b = 1 } -- default to white if class color is not available

                    -- Format and display the ping text with class color
                    pinger:SetText(format("|cffff0000*|r %s |cffff0000*|r", unitName))
                    pinger:SetTextColor(classColor.r, classColor.g, classColor.b)

                    -- Flash the pinger text for visibility
                    UIFrameFlash(pinger, 0.2, 2.8, 5, false, 0, 5)

                    -- Update timer to prevent frequent pings
                    timer = time()
                end
            end
        end
    end, "MINIMAP_PING"
    );

    local function MoveWatchFrame()
        WatchFrame:ClearAllPoints()
        WatchFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMLEFT", 0, -50)
    end

    addon.package:RegisterEvents(MoveWatchFrame, "PLAYER_LOGIN");
    addon.package:RegisterEvents(MoveWatchFrame, "QUEST_LOG_UPDATE");

end
