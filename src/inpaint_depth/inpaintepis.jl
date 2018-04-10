# Module for inpainting epis

using PyPlot
using Shearlab

n =512;

# The path of the sparse EPI
name_sparse = "../Diagrams/results/new_EPIs/104_8_102_7_12_3_sparse.png";
EPI_sparse = Shearlab.load_image(name_sparse, n);
EPI_sparse = EPI_sparse[:,:,1];

m = size(EPI_sparse)[2]

name_dense = "../Diagrams/results/new_EPIs/104_8_102_7_12_3_dense.png";
EPI_dense = Shearlab.load_image(name_dense, n,m);
EPI_dense = EPI_dense[:,:,1];

# Mask definition

#Initialize with ones 
mask = ones(Float64,size(EPI_dense));

mask[abs.(EPI_dense-EPI_sparse).!=0]=0

# Inpainting

# Data 
EPI_masked = EPI_sparse.*mask;
stopFactor = 0.005; # The highest coefficient times stopFactor
sizeX = size(EPI_masked,1);
sizeY = size(EPI_masked,2);
dmax = 7; # Disparity term
nScales = convert(Int,ceil(log(2,dmax)));

#shearLevels |k|<= 2^(j+1)+1
shearLevels = [2.0^(j+1)+1 for j in 0:(nScales-1)];

shearLevels = shearLevels'

# Computing Shearlet system

shearletsystem = Shearlab.getshearletsystem2D(sizeX, sizeY, nScales);

# Normalized iterative thresholding

function inpaint2D(imgMasked,mask,iterations,stopFactor,shearletsystem)
    coeffs = Shearlab.sheardec2D(imgMasked,shearletsystem);
    coeffsNormalized = zeros(size(coeffs))+im*zeros(size(coeffs));
    for i in 1:shearletsystem.nShearlets
        coeffsNormalized[:,:,i] = coeffs[:,:,i]./shearletsystem.RMS[i];
    end
    delta = maximum(abs(coeffsNormalized[:]));
    lambda=(stopFactor)^(1/(iterations-1));
    imgInpainted = zeros(size(imgMasked));
    #iterative thresholding
    for it = 1:iterations
        res = mask.*(imgMasked-imgInpainted);
        coeffs = Shearlab.sheardec2D(imgInpainted+res,shearletsystem);
        coeffsNormalized = zeros(size(coeffs))+im*zeros(size(coeffs));
        for i in 1:shearletsystem.nShearlets
            coeffsNormalized[:,:,i] = coeffs[:,:,i]./shearletsystem.RMS[i];
        end
        coeffs = coeffs.*(abs(coeffsNormalized).>delta);
        imgInpainted = Shearlab.shearrec2D(coeffs,shearletsystem);  
        delta=delta*lambda;  
    end
    imgInpainted
end

# Normalized iterative thresholding with varying acceleration

function inpaint2D_accel(imgMasked,mask,iterations,stopFactor,shearletsystem)
    coeffs = Shearlab.sheardec2D(imgMasked,shearletsystem);
    coeffsNormalized = zeros(size(coeffs))+im*zeros(size(coeffs));
    for i in 1:shearletsystem.nShearlets
        coeffsNormalized[:,:,i] = coeffs[:,:,i]./shearletsystem.RMS[i];
    end
    delta = maximum(abs(coeffsNormalized[:]));
    lambda=(stopFactor)^(1/(iterations-1));
    imgInpainted = zeros(size(imgMasked));
    alpha = 1
    #iterative thresholding
    for it = 1:iterations
        res = mask.*(imgMasked-imgInpainted);
        coeffs = Shearlab.sheardec2D(imgInpainted+alpha*res,shearletsystem);
        coeffsNormalized = zeros(size(coeffs))+im*zeros(size(coeffs));
        for i in 1:shearletsystem.nShearlets
            coeffsNormalized[:,:,i] = coeffs[:,:,i]./shearletsystem.RMS[i];
        end
        coeffs = coeffs.*(abs(coeffsNormalized).>delta);
        # Support of coeffsNormalized until 
        norms = [norm(coeffs[:,:,i]) for i in 1:size(coeffs)[3]]
        # Thresholding the norm of the matrices to catch the support (smallest )
        indices = (norms.<0.5)
        beta = Shearlab.sheardec2D(res,shearletsystem);
        beta[(~indices)...] = 0;
        beta2 = mask.*(Shearlab.shearrec2D(beta,shearletsystem));
        alpha = sum((abs.(beta)).^2)/sum((abs.(beta2)).^2)
        imgInpainted = Shearlab.shearrec2D(coeffs,shearletsystem);  
        delta=delta*lambda;  
    end
    imgInpainted
end

# Inpainting all the sparse epis
split_list(string)=split(string,"_")
list_files = readdir("../Diagrams/results/EPIs/");
list_files = list_files[2:length(list_files)]
sparse_list = [];
dense_list = [];

for string in list_files
    if split(string,"_")[7]=="sparse.png"
        push!(sparse_list,string)
    end
end

for string in list_files
    if split(string,"_")[7]=="dense.png"
        push!(dense_list,string)
    end
end

# Function to inpaint file

function inpaint_file(file_sparse,file_dense) 
    # The path of the sparse EPI
    name_sparse = "../Diagrams/results/EPIs/"*file_sparse;
    EPI_sparse = Shearlab.load_image(name_sparse, n,m);
    EPI_sparse = EPI_sparse[:,:,1];
    name_dense = "../Diagrams/results/EPIs/"*file_dense;
    EPI_dense = Shearlab.load_image(name_dense, n,m);
    EPI_dense = EPI_dense[:,:,1];
    #Initialize with ones 
    mask = ones(Float64,size(EPI_dense));
    mask[abs.(EPI_dense-EPI_sparse).!=0]=0
    # Data 
    EPI_masked = EPI_sparse.*mask;
    stopFactor = 0.005; # The highest coefficient times stopFactor
    EPIinpainted50 = inpaint2D(EPI_masked,mask,50,stopFactor,shearletsystem);
    name_inpainted1 = split(name_dense,"/")
    name_inpainted1[4] = "Inpainted"
    last_name = name_inpainted1[5]
    last_name_split = split(last_name,"_")
    last_name_split[7] = "inpainted.png"
    last_name_split
    last_name = last_name_split[1]
    for i in 2:size(last_name_split)[1]
        last_name = last_name*"_"*last_name_split[i]
    end
    name_inpainted1[5] = last_name
    name_inpainted = name_inpainted1[1]
    for i in 2:size(name_inpainted1)[1]
        name_inpainted = name_inpainted*"/"*name_inpainted1[i]
    end
    name_inpainted
    Shearlab.imageplot(real(EPIinpainted50))
    savefig(name_inpainted, dpi = 80*3,bbox_inches="tight")
    clf()
end

# Inpaint all the files
for i in 1:length(sparse_list)
    file_sparse = sparse_list[i];
    file_dense = dense_list[i];
    inpaint_file(file_sparse,file_dense);
end
