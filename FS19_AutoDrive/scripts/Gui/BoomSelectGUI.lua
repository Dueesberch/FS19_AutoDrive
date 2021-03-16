ADBoomSelectGui = {}
ADBoomSelectGui.CONTROLS = {"textInputElement", "listItemTemplate", "autoDriveBoomSelectList"}

local ADBoomSelectGui_mt = Class(ADBoomSelectGui, ScreenElement)

function ADBoomSelectGui:new(target)
    local o = ScreenElement:new(target, ADBoomSelectGui_mt)
    o.returnScreenName = ""
    o.booms = {}
    o:registerControls(ADBoomSelectGui.CONTROLS)
    return o
end

function ADBoomSelectGui:onCreate()
    self.listItemTemplate:unlinkElement()
    self.listItemTemplate:setVisible(false)
end

function ADBoomSelectGui:onOpen()
    self:refreshItems()
    ADBoomSelectGui:superClass().onOpen(self)
end

function ADBoomSelectGui:refreshItems()
    self.booms = ADGraphManager:getMapBooms()
    self.autoDriveBoomSelectList:deleteListItems()
    for _, r in pairs(self.booms) do
        local new = self.listItemTemplate:clone(self.autoDriveBoomSelectList)
        new:setVisible(true)
        new.elements[1]:setText(r.name)
        new.elements[2]:setText(r.id)
        new:updateAbsolutePosition()
    end
end

function ADBoomSelectGui:onListSelectionChanged(rowIndex)
end

function ADBoomSelectGui:onDoubleClick(rowIndex)
    self.textInputElement:setText(self.booms[rowIndex].name)
end

function ADBoomSelectGui:onClickOk()
    vehicle = g_currentMission.controlledVehicle
    ADBoomSelectGui:superClass().onClickBack(self)  -- TODO warum schließt die GUI nicht bei onClickOk()?
    vehicle.ad.stateModule:getCurrentMode():start()
end

function ADBoomSelectGui:onClickBack()
    vehicle = g_currentMission.controlledVehicle
    ADBoomSelectGui:superClass().onClickBack(self)
    -- remove waypoint from vehicle waypoints
    vehicle.ad.stateModule:getCurrentMode():start()
end

function ADBoomSelectGui:onEnterPressed(_, isClick)
    if not isClick then
        --self:onClickOk()
    end
end

function ADBoomSelectGui:onEscPressed()
    self:onClickBack()
end
