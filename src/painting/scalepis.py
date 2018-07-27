# Moduel that

# Import the libraries to use
import numpy as np
from PIL import Image
import os

# The paths for reading and writing the images
#path = '/Users/hector/Documents/Github_Repos/MThesis/EPIs_Strips/EPIs/'

def rescale_EPIs(path,size):
	# List elements of the path
	names = os.listdir(path)
	names.pop(0);

	for name in names:
    		# open the row high-resolution image
    		im = Image.open(path+name)
    		# check sizes
    		size = 1024, 683
    		# resize the image
    		im_resized = im.resize(size, Image.ANTIALIAS)
   		# save the image
   	 	im_resized.save(path+name)
