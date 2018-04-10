# Light Fields package

module LightFields

using Shearlab
using PyPlot

export 

include("tracking/efueatures.jl")
include("painting/sparepis.jl")
include("inpaint_depth/inpaintepis.jl")
include("inpaint_depth/linedetect.jl")

end #module
