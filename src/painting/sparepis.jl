## Module for painting sparse EPIs

# We will use library DataFrames to deal with DataFrames in csv
using DataFrames
using PyPlot

# Function that paints EPI
function paint_epi(points_x, points_y, ϵ, y0, s_rate=1)
    # Limits of the strip
    y01 = y0-ϵ;
    y02 = y0+ϵ;
    #Subset of features catched
    idy = (points_y[:y1].<=y02).*(points_y[:y1].>=y01);
    array_x = points_x[idy,:]
    array_y = points_y[idy,:];
    features = unique(array_x[:feature])
    for feature in unique(array_x[:feature])
        array_feature_x = array_x[array_x[:feature].==feature,:];
        array_feature_y = array_y[array_y[:feature].==feature,:];
        color_feature = array_x[array_x[:feature].==feature,:][:color][1]

        # find min and max of x coordinate for that feature
        xmax_feature_first,idxmax_feature = findmax(array_feature_x[:x1])
        xmin_feature_first, idxmin_feature = findmin(array_feature_x[:x1]);

        nonas = min(array_feature_x[idxmax_feature,:][:no_nas][1],array_feature_x[idxmin_feature,:][:no_nas][1]);
        i = 1
        max_size = size(array_feature_x[idxmax_feature,:])[2]
        cond_max = abs(array_feature_x[idxmax_feature,:][i+s_rate]-array_feature_x[idxmax_feature,:][i+s_rate+1])[1]<=10.0
        cond_min = abs(array_feature_x[idxmin_feature,:][i+s_rate]-array_feature_x[idxmin_feature,:][i+s_rate+1])[1]<=10.0
        while (i <= (nonas-s_rate-2))*(cond_max)*(cond_min)
            x_max = [array_feature_x[idxmax_feature,:][i],array_feature_x[idxmax_feature,:][i+1]]
            x_min = [array_feature_x[idxmin_feature,:][i],array_feature_x[idxmin_feature,:][i+1]]
            plot(x_max,[i,i+1],color=color_feature)
            plot(x_min,[i,i+1],color=color_feature)
            x = [x_max[2][1],x_max[1][1],x_min[1][1],x_min[2][1]]
            y = [i+1,i,i,i+1];
            fill(x,y,color=color_feature)
            x_max = [array_feature_x[idxmax_feature,:][i],array_feature_x[idxmax_feature,:][i+1]]
            x_min = [array_feature_x[idxmin_feature,:][i],array_feature_x[idxmin_feature,:][i+1]]
            cond_max = abs(array_feature_x[idxmax_feature,:][i+s_rate]-array_feature_x[idxmax_feature,:][i+s_rate+1])[1]<=10.0
            cond_min = abs(array_feature_x[idxmin_feature,:][i+s_rate]-array_feature_x[idxmin_feature,:][i+s_rate+1])[1]<=10.0
            i+=s_rate
        end
    end
    plot([0,1024,1024,0,0],[0,0,maximum(array_x[:no_nas]),maximum(array_x[:no_nas]),0],color="black")
    ax = gca()
    ax[:set_frame_on](false) 
    ax[:set_frame_on](false)
    yticks([])
    xticks([])
    maximum(array_x[:no_nas])
end

# Function that paints a strip in the first image with the
# captured points
function strip_epi(points_x, points_y, ϵ, y0)
    # Limits of the strip
    y01 = y0-ϵ;
    y02 = y0+ϵ;
    #Subset of features catched
    idy = (points_y[:y1].<=y02).*(points_y[:y1].>=y01);
    array_x = points_x[idy,:]
    array_y = points_y[idy,:];   
    plot([0,1024],[y01,y01],"-r")
    plot([0,1024],[y02,y02],"-r")
    i = 1
    imshow(church_first)
    x = array_x[i][~isna(array_x[i])]
    y = array_y[i][~isna(array_y[i])]
    colors = array_x[:color][~isna(array_x[i])]
    for j in 1:size(x)[1]
        plot(x[j],y[j], color=colors[j],"o")
    end
    ax = gca()
    ax[:set_frame_on](false) 
    ax[:set_frame_on](false)
    yticks([])
    xticks([])
end

# Paint the epis
function paint_epis(points_x, points_y, y0, ϵ, s_rate, path_to_epis):
	# Limits of the strip
	y01 = y0-ϵ;
	y02 = y0+ϵ;
	#Subset of features catched
	idy = (points_y[:y1].<=y02).*(points_y[:y1].>=y01)
	array_x = points_x[idy,:];
	t_max = maximum(array_x[:no_nas])
	no_features = size(unique(array_x[:feature]))[1]
	no_features = size(unique(array_x[:feature]))[1]
	tracked_points = size(array_x)[1]
	s_rate = 4;
	name=string(y0)*"_"*string(ϵ)*"_"*string(t_max)*"_"string(s_rate)*"_"*string(tracked_points)*"_"*string(no_features)
	strip_epi(points_x, points_y,ϵ,y0)
	savefig(path_to_epis*name*"_strip", dpi = 80*3,bbox_inches="tight")
	
	paint_epi(points_x, points_y, ϵ, y0,12)
	savefig(path_to_epis*name*"_sparse", dpi = 80*3,bbox_inches="tight")

	paint_epi(points_x, points_y, ϵ, y0,1)
	savefig(path_to_epis*name*"_dense", dpi = 80*3,bbox_inches="tight")

	# Painting all the EPIs

	for y00 in y0:-2ϵ:0+ϵ    
    	# Limits of the strip
    	y01 = y00-ϵ;
    	y02 = y00+ϵ;
    	#Subset of features catched
    	idy = (points_y[:y1].<=y02).*(points_y[:y1].>=y01);
    	array_x = points_x[idy,:];
    	t_max = maximum(array_x[:no_nas])
    	no_features = size(unique(array_x[:feature]))[1]
    	no_features = size(unique(array_x[:feature]))[1]
    	tracked_points = size(array_x)[1];
    	name=string(Int(y00))*"_"*string(Int(ϵ))*"_"*string(t_max)*"_"string(s_rate)*"_"*string(tracked_points)*"_"*string(no_features)    
    	
			strip_epi(points_x, points_y,ϵ,y00)
    	savefig(path_to_epis*name*"_strip", dpi = 80*3,bbox_inches="tight")
    	clf()
    	paint_epi(points_x, points_y, ϵ, y00,s_rate)
    	savefig(path_to_epis*name*"_sparse", dpi = 80*3,bbox_inches="tight")
    	clf()
   		paint_epi(points_x, points_y, ϵ, y00,1)
    	savefig(path_to_epis*name*"_dense", dpi = 80*3,bbox_inches="tight")
   	 	clf()
	end
end
