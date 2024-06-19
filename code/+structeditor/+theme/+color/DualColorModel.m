classdef DualColorModel < handle
    properties
        PrimaryColorA = uim.utility.hex2rgb( '#002054' )
        PrimaryColorB = uim.utility.hex2rgb( '#17A7FF' )
        PrimaryColorC = uim.utility.hex2rgb( '#F6F8FC' ) % Light.
        SecondaryColorA = uim.utility.hex2rgb( '#2EB0FF' )
        SecondaryColorB = uim.utility.hex2rgb( '#5DC1FF' )
        SecondaryColorC = uim.utility.hex2rgb( '#FDF7FA' ) % Light.
    end
end