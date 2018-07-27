# Script to track points of the image sequence

import the libraries to use
import numpy as np
import cv2
import matplotlib.pyplot as plt
import pandas as pd
import time
from PIL import Image

from os import listdir
from os.path import isfile, join

# Generate EPIs for the church images

#size = 1024, 683
# The paths for reading and writing the images

#path_raw = '/Users/hector/Documents/Master_thesis/EPI_samples/Church_data_set/church_image-raw/church_image-raw/'
#path_lowres = '/Users/hector/Documents/Master_thesis/EPI_samples/Church_data_set/church_image-raw/church_image_lowres/'

# Function to lower the resolution of the images to the given size
def to_lowres(path_raw, path_lowres, size):
	# List of files
	files = [f for f in listdir(path_raw) if isfile(join(path_raw, f))]
	#for loop to lower the resolution
	for i in range(len(files)):
		im = Image.open(path_raw+files[i])
		im_resized = im.resize(size, Image.ANTIALIAS)
		im_resized.save(path_lowres+file)
	print('Done')

def point(tracking, path_lowres, path_tracked_points):
	# List of files
	files = [f for f in listdir(path_raw) if isfile(join(path_lowres, f))]
	# Lets start with the feature tracking
	# params for ShiTomasi corner detection
	feature_params = dict(maxCorners = 400,
        	              qualityLevel = 0.3,
                	      minDistance = 7,
                       	      blockSize = 7 )
	# Parameters for lucas kanade optical flow
	lk_params = dict( winSize  = (18,18),
	                  maxLevel = 2,
	                  criteria = (cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 10, 0.03))

	# Create some random colors
	color = np.random.randint(0,255,(100,3))

	# Path of church data set
	#path_lowres = '/Users/hector/Documents/Master_thesis/EPI_samples/Church_data_set/church_image-raw/church_image_lowres/'

	# Take first frame image and find corners in data set
	old_frame = cv2.imread(path_lowres+files[0])
	old_gray = cv2.cvtColor(old_frame, cv2.COLOR_BGR2GRAY)
	p0 = cv2.goodFeaturesToTrack(old_gray, mask = None, **feature_params)
	st = np.array([[1]]*len(p0))

	# Create a data frame with the entries of the point
	# df = pd.DataFrame({'p' : range(1,len(p0)+1), 'x1' : p0[st==1][:,0], 'y1' : p0[st==1][:,1]})
	df = pd.DataFrame({'x1' : p0[st==1][:,0], 'y1' : p0[st==1][:,1]})
	# Vector to track the number of points to track
	lengths_church = [len(p0)]
	# Create a mask image for drawing purposes
	mask = np.zeros_like(old_frame)

	# For loop to track those points
	for i in range(len(files)):
		frame = cv2.imread(path_lowres+files[i])
		frame_gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

 		# calculate optical flow
	        p1, st, err = cv2.calcOpticalFlowPyrLK(old_gray, frame_gray, p0, None, **lk_param)
		# Select good points
        	good_new = p1[st==1]
        	good_old = p0[st==1]

 		# append new length to lengths
        	lengths_church.append(len(p1))

		 # Adding the new points to the dataframe
	        df_new = pd.DataFrame({'x'+str(i+2) : [np.nan]*len(df_church.x1), 'y'+str(i+2) : [np.nan]*len(df.x1)})

		df_new1 = df_new[notnull]
        	id=df_new1[[sti[0]==1 for sti in st]].index
        	df_new1['x'+str(i+2)][[sti[0]==1 for sti in st]] = pd.Series(p1[st==1][:,0],index = id)
        	df_new1['y'+str(i+2)][[sti[0]==1 for sti in st]] = pd.Series(p1[st==1][:,1],index = id)
        	df_new[notnull] = df_new1
        	df=df.join(df_new)

 		# draw the tracks
        	for j,(new,old) in enumerate(zip(good_new,good_old)):
            		a,b = new.ravel()
            		c,d = old.ravel()
            		mask = cv2.line(mask, (a,b),(c,d), color[j%100].tolist(), 2)
            		frame = cv2.circle(frame,(a,b),5,color[j%100].tolist(),-1)
        	img = cv2.add(frame,mask)

		old_gray = frame_gray.copy()
        	p0 = good_new.reshape(-1,1,2)
		cv2.imwrite(path_tracked_points+'tracked_points_traces.png',frame)

		cv2.destroyAllWindows()

		# Save the dataframe to csv
		df.to_csv(path_tracked_points+'tracked_points.csv')

