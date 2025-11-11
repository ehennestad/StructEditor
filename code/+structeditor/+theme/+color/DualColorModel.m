classdef DualColorModel < handle
    properties
        PrimaryColorA = structeditor.compatibility.hex2rgb( '#002054' )
        PrimaryColorB = structeditor.compatibility.hex2rgb( '#17A7FF' )
        PrimaryColorC = structeditor.compatibility.hex2rgb( '#F6F8FC' ) % Light.
        SecondaryColorA = structeditor.compatibility.hex2rgb( '#2EB0FF' )
        SecondaryColorB = structeditor.compatibility.hex2rgb( '#5DC1FF' )
        SecondaryColorC = structeditor.compatibility.hex2rgb( '#FDF7FA' ) % Light.
    end
end