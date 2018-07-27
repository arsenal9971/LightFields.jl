# Light Fields package

module LightFields

using Shearlab
using PyPlot

export csv_to_variable, point_epis, strip_epi, paint_epis, getshearletsystem2D, inpaint_files, inpaint_file, inpaint2D_accel, inpaint2D

include("tracking/efueatures.jl")
include("painting/sparepis.jl")
include("inpaint_depth/inpaintepis.jl")
include("inpaint_depth/linedetect.jl")

end #module
