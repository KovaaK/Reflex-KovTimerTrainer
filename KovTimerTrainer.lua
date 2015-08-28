require "base/internal/ui/reflexcore"

KovTimerTrainer =
{
};
registerWidget("KovTimerTrainer");

function KovTimerTrainer:initialize()
    -- load data stored in engine
    self.userData = loadUserData();
    
    -- ensure it has what we need
    CheckSetDefaultValue(self, "userData", "table", {});
    CheckSetDefaultValue(self.userData, "TimerCountsDown", "boolean", true);
    CheckSetDefaultValue(self.userData, "ShowReds", "boolean", true);
    CheckSetDefaultValue(self.userData, "ShowYellows", "boolean", true);
    CheckSetDefaultValue(self.userData, "ShowGreens", "boolean", true);
    CheckSetDefaultValue(self.userData, "ShowMegas", "boolean", true);
    CheckSetDefaultValue(self.userData, "ShowCarnage", "boolean", true);

end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function KovTimerTrainer:finalize()
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function KovTimerTrainer:draw()
    
    local TimerCountsDown = self.userData.TimerCountsDown;
    local ShowReds = self.userData.ShowReds;
    local ShowYellows = self.userData.ShowYellows;
    local ShowGreens = self.userData.ShowGreens;
    local ShowMegas = self.userData.ShowMegas;
    local ShowCarnage = self.userData.ShowCarnage;
    
    local gameTime
    local gameTimeLimit = world.gameTimeLimit
    if TimerCountsDown then
        gameTime = gameTimeLimit - world.gameTime   
    else
        gameTime = world.gameTime
    end
    
    
    -- Early out if HUD shouldn't be shown.
    if not shouldShowHUD() then return end;

    local translucency = 192;
    
    -- Find player
    local player = getPlayer();

    -- count pickups
    local pickupCount = 0;
    for k, v in pairs(pickupTimers) do
        pickupCount = pickupCount + 1;
    end

    local spaceCount = pickupCount - 1;
    
    -- Options
    local timerWidth = 100;
    local timerHeight = 30;
    local timerSpacing = 5; -- 0 or -1 to remove spacing
    
    -- Helpers
    local rackHeight = (timerHeight * pickupCount) + (timerSpacing * spaceCount);
    local rackTop = -(rackHeight / 2);
    local timerX = 0;
    local timerY = rackTop;

    -- iterate pickups
    for i = 1, pickupCount do
        local pickup = pickupTimers[i];

        if (pickup.type == PICKUP_TYPE_ARMOR50 and ShowGreens) or (pickup.type == PICKUP_TYPE_ARMOR100 and ShowYellows) or (pickup.type == PICKUP_TYPE_ARMOR150 and ShowReds) or (pickup.type == PICKUP_TYPE_HEALTH100 and ShowMegas) or (pickup.type == PICKUP_TYPE_POWERUPCARNAGE and ShowCarnage) then

            local backgroundColor = Color(0,0,0,65)
            
            -- Frame background
            nvgBeginPath();
            nvgRect(timerX,timerY,timerWidth,timerHeight);
            nvgFillColor(backgroundColor);
            nvgFill();

            -- Icon
            local iconRadius = timerHeight * 0.40;
            local iconX = timerX + iconRadius + 5;
            local iconY = timerY + (timerHeight / 2);
            local iconColor = Color(255,255,255);
            local iconSvg = "internal/ui/icons/armor";
            if pickup.type == PICKUP_TYPE_ARMOR50 then
                iconColor = Color(0,180,0);
            elseif pickup.type == PICKUP_TYPE_ARMOR100 then
                iconColor = Color(255,255,0);
            elseif pickup.type == PICKUP_TYPE_ARMOR150 then
                iconColor = Color(255,0,0);
            elseif pickup.type == PICKUP_TYPE_HEALTH100 then
                iconSvg = "internal/ui/icons/health";
                iconColor = Color(60,80,255);
            elseif pickup.type == PICKUP_TYPE_POWERUPCARNAGE then
                iconSvg = "internal/ui/icons/carnage";
                iconColor = Color(255,120,128);         
            end
          
            -- TODO: tint based on pickup type
            local svgName = "internal/ui/icons/armor";
            nvgFillColor(iconColor);
            nvgSvg(iconSvg, iconX, iconY, iconRadius);

            -- Time

            --[[
            Logic for timers:
            If you're in prematch, just use the normal method
            If you have the timer set to count up, 
            --]]
            
            local t = FormatTime(pickup.timeUntilRespawn);
            local timeX = timerX + (timerWidth / 2) + iconRadius;
            local time = t.seconds + 60 * t.minutes;

            if time == 0 then
                time = "-";
            end
            
            if world.gameState == GAME_STATE_ACTIVE then
                local OTFlag = 0
                if time ~= "-" and time > 0 then
                    if TimerCountsDown == true then
                        time = gameTime - pickup.timeUntilRespawn
                        if time < 0 then 
                            time = time + 120*1000
                            OTFlag = 1
                        end
                    else
                        time = gameTime + pickup.timeUntilRespawn
                        if time > gameTimeLimit then
                            OTFlag = 1
                        end
                    end     
                    local seconds = math.floor(time/1000)%60
                    if seconds < 10 then
                    seconds = "0"..seconds
                    end
                    local minutes = (math.floor(time/1000) - seconds)/60
                    time = minutes..":"..seconds
                    if OTFlag == 1 then
                        time = "OT "..time
                    end
                end

            end

            if not pickup.canSpawn then
                time = "held";
            end

            nvgFontSize(30);
            nvgFontFace("TitilliumWeb-Bold");
            nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_TOP);

            nvgFontBlur(0);
            nvgFillColor(Color(255,255,255));
            nvgText(timeX, timerY, time);
            
            timerY = timerY + timerHeight + timerSpacing;
        end
    end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function KovTimerTrainer:drawOptions(x, y)
    local user = self.userData;

    user.TimerCountsDown = uiCheckBox(user.TimerCountsDown, "Timer Counts Down", x, y);
    y = y + 50;

    user.ShowReds = uiCheckBox(user.ShowReds, "Show Red Armors", x, y);
    y = y + 30;

    user.ShowYellows = uiCheckBox(user.ShowYellows, "Show Yellow Armors", x, y);
    y = y + 30;

    user.ShowGreens = uiCheckBox(user.ShowGreens, "Show Green Armors", x, y);
    y = y + 30;

    user.ShowMegas = uiCheckBox(user.ShowMegas, "Show Mega Healths", x, y);
    y = y + 30;

    user.ShowCarnage = uiCheckBox(user.ShowCarnage, "Show Carnage", x, y);
    y = y + 30;
    
    --[[
    CheckSetDefaultValue(self.userData, "ShowReds", "boolean", true);
    CheckSetDefaultValue(self.userData, "ShowYellows", "boolean", true);
    CheckSetDefaultValue(self.userData, "ShowGreens", "boolean", true);
    CheckSetDefaultValue(self.userData, "ShowMegas", "boolean", true);
    CheckSetDefaultValue(self.userData, "ShowCarnage", "boolean", true);
    --]]
    saveUserData(user);
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function KovTimerTrainer:getOptionsHeight()
    return 370; -- debug with: ui_optionsmenu_show_properties_height 1
end
