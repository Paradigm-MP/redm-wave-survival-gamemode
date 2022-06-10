--[[Grandparent = class()
function Grandparent:__init()
    print("entered Grandparent init")
end
]]

--print("==================== CREATING PARENT CLASS ===================")
Parent = class()
function Parent:__init()
    -- only executed when you create a Parent class directly
    --print("entered Parent init")
end
function Parent:InitializeParentFromChild()
    --print("initialized Parent from Child")
end

--print("==================== CREATING CHILD CLASS ===================")
Child = class(Parent)
function Child:__init()
    self:InitializeParentFromChild()
    --print("entered Child init")
end

--print("==================== CREATING TestClasses CLASS ===================")
TestClasses = class()
function TestClasses:__init()
    --print("==================== CREATING CHILD INSTANCE ===================")
    --print("@@@@@@@@@@@@@@@@ ENTERED TestClasses __init @@@@@@@@@@@@@@@@@@")
    self.child = Child()
end
test_classes = TestClasses()

--[[
ImmediateClass = immediate_class()
function ImmediateClass:__init()
    print("entered ImmediateClass init")
end
local imm = ImmediateClass()

LoadFirstClass = load_first_class()
function LoadFirstClass:__loadFirst()
    print("entered loadFirst")
    self.__loadFirstCompleted = true
end
local lf_class = LoadFirstClass()
]]