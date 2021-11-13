

function ClearMoveToInterval(char, Interval)
    Timer.ClearInterval(Interval)
    if char:IsValid() then
        char:SetValue("UpdateMoveToData", nil, false)
    end
end

function UpdateMoveTo(char)
    if char:IsValid() then
        local update_moveto_data = char:GetValue("UpdateMoveToData")
        if update_moveto_data.FollowingChar:IsValid() then
            local target_loc = update_moveto_data.FollowingChar:GetLocation()
            char:MoveTo(target_loc, update_moveto_data.acceptance_radius)
            char:LookAt(target_loc)
        else
            --print("ClearInterval, UpdateMoveTo, FollowingChar invalid")
            ClearMoveToInterval(char, update_moveto_data.interval)
        end
    end
end

function FollowCharacter(char, chartofollow, acceptance_radius, update_interval_ms)
    local update_moveto_data = char:GetValue("UpdateMoveToData")
    if update_moveto_data then
        ClearMoveToInterval(char, update_moveto_data.interval)
    end
    char:SetValue("UpdateMoveToData", {
        interval = Timer.SetInterval(UpdateMoveTo, update_interval_ms, char),
        FollowingChar = chartofollow,
        acceptance_radius = acceptance_radius,
    }, false)
    UpdateMoveTo(char)
end
Package.Export("FollowCharacter", FollowCharacter)

function StopFollowCharacter(char)
    local update_moveto_data = char:GetValue("UpdateMoveToData")
    if update_moveto_data then
        ClearMoveToInterval(char, update_moveto_data.interval)
        char:MoveTo(char:GetLocation(), 100)
    end
end
Package.Export("StopFollowCharacter", StopFollowCharacter)

Character.Subscribe("MoveCompleted", function(char, succeeded)
    local update_moveto_data = char:GetValue("UpdateMoveToData")
    if (update_moveto_data and succeeded) then
       -- print("tempfollow, MoveCompleted follow succeeded", char)
        ClearMoveToInterval(char, update_moveto_data.interval)
        Events.Call("FollowCharacterCompleted", char, update_moveto_data.FollowingChar)
    else
        if succeeded then
            --print("tempfollow, MoveCompleted NO Follow Succeeded", char)
        end
    end
end)

function CharacterStopFollowInterval(char)
    local update_moveto_data = char:GetValue("UpdateMoveToData")
    if update_moveto_data then
        --print("ClearInterval, Char destroyed or dead")
        ClearMoveToInterval(char, update_moveto_data.interval)
    end
end
Character.Subscribe("Destroy", CharacterStopFollowInterval)
Character.Subscribe("Death", CharacterStopFollowInterval)