PedBoneEnum = immediate_class(Enum)

function PedBoneEnum:__init()
    self:EnumInit()

    -- Enum values
    self.RightHandThumbFirstKnuckle = 1 -- first knuckle on right hand thumb
    self.RightHandIndexFingerSecondKnuckle = 2 -- second knuckle on right hand index finger
    self.RightHandIndexFingerThirdKnuckle = 3 -- third knuckle on right hand index finger
    self.RightHandMiddleFingerLastKnuckle = 4
    self.Spine1 = 5
    self.Spine2 = 6
    self.Spine3 = 7 -- highest spine point (use radius of .225)
    self.Head = 8 -- (use radius of .135) .. ***also + .03 on .z !!
    self.RightElbow = 9 -- good viewing radius .05
    self.RightWrist = 10 -- good viewing radius is .045



    self.Test = 99


    self.bone_map = {
        [self.RightHandThumbFirstKnuckle] = "BONETAG_R_FINGER01",
        [self.RightHandIndexFingerSecondKnuckle] = "BONETAG_R_FINGER11",
        [self.RightHandIndexFingerThirdKnuckle] = "BONETAG_R_FINGER12",
        [self.RightHandMiddleFingerLastKnuckle] = "BONETAG_R_FINGER22",
        [self.Spine1] = "BONETAG_SPINE1",
        [self.Spine2] = "BONETAG_SPINE2",
        [self.Spine3] = "BONETAG_SPINE3",
        [self.Head] = "BONETAG_HEAD",
        --[self.Test] = "BONETAG_PELVIS", -- pelvis
        [self.RightElbow] = "BONETAG_R_FOREARM",
        --[self.Test] = "BONETAG_R_UPPERARM", -- right shoulder
        [self.RightWrist] = "BONETAG_R_HAND",
        --[self.Test] = "BONETAG_R_HAND",
    }

    self.reverse_bone_map = {}
    for k, v in pairs(self.bone_map) do
        self.reverse_bone_map[v] = k
    end
end

function PedBoneEnum:MapToBoneName(enum_value)
    return self.bone_map[enum_value]
end

function PedBoneEnum:FromBone(bone)
    return self.reverse_bone_map[bone]
end

PedBoneEnum = PedBoneEnum()