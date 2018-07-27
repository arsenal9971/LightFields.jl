# Module to extract the different features (hand-made)

# We will use library DataFrames to deal with DataFrames in csv
using DataFrames


# Read csv's and storage the y entries in the time of the points
function csv_to_variable(path_csv,size):
	df = readtable("path_csv")
	x =  df[2:2:size(x)[1]]
	# all points
	points_x, points_y = extract(x,y,1,0,size[0],0,size[1])

