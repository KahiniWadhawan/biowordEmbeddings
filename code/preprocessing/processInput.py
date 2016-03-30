#------------------------------------------------------------
# This file takes in the pubmed bio text files and
# process them to proper format. This proper formatted
# file is then used by Neural Net.
#------------------------------------------------------------

import time
import os


start_time=time.time()

#---------------------------------------------------------------
# Setting up data input, output directories
#---------------------------------------------------------------
data_DIR = "../../../data/"
inputFiles_DIR = os.path.join(data_DIR,"tokenizedFiles/TextWinTokenFiles/")
outputFiles_DIR = os.path.join(data_DIR,"tokenizedFiles/TextWinFiles/")

#---------------------------------------------------------------
#size of text window, preferrably be odd number
# Will pass on to this file from config shell script file later
#---------------------------------------------------------------
window_size = 11


#---------------------------------------------------------
# Function to read all files in a directory
#---------------------------------------------------------
def iter_docs(topdir):
	try:
		for fn in os.listdir(topdir):
			if fn.endswith('.txt'):
				print("------------------------------")
				in_filepath = os.path.join(topdir, fn)
				in_filename = os.path.basename(in_filepath)
				fin = open(in_filepath, 'rb')
				print("Processing doc:: ",in_filename)
				text = fin.read()
				create_text_window(text,in_filename)
				#print("------------------------------")
				fin.close()
	except IOError:
		print "IOError: Could not open files or access directory"


#-------------------------------------------------------------------
#function to create overlapping text windows from words in sequence
#-------------------------------------------------------------------
def create_text_window(text,filename):
	words = text.split()
	words_len = len(words)
	try:
		out_filepath = os.path.join(outputFiles_DIR, filename)
		print("Output filepath :: ",out_filepath)
		fout = open(out_filepath,'wb')

		for i in range(words_len-1):
			if i+11 < words_len:
				window = words[i:i+11]

			else:
				window = words[i:words_len]

			#print("window :: ", window)
			window_str = ''
			for word in window:
				if len(window_str) > 0:
					window_str = window_str + ' ' + word    #revisit - does space at last creates problem
				else:
					window_str = word
			#print("window_str :: ", window_str)
			fout.write(window_str+'\n')

		fout.close()
		print("Done writing this doc")

	except IOError:
		print "IOError: Could not open files or access directory"





end_time=time.time()



# text = "introduction dispersion migration uranium ( u ) toxic metals radionuclides " \
# 	   "uranium mines due mining operations waste piling serious environmental concern " \
# 	   "uranium producing states ( foster et al islam et al ) once released environment " \
# 	   "fate toxicity these metallic contaminants strongly regulated abiotic biotic " \
# 	   "components minerals bacteria ( lloyd renshaw ) hand toxic bioavailable forms " \
# 	   "these metals radionuclides often affect adversely diversity function autochthonous " \
# 	   "microorganisms neighboring habitats bequeath ecological sustains maintaining" \
# 	   " biogeochemical cycles ( torsvik et al islam et al ) diversity distribution microbes" \
# 	   " often site - specific influenced composition geochemical matrix microhabitats" \
# 	   " perturbation due environmental contamination cause change inhabitant microbial" \
# 	   " community structure diversity function ( herrera et al desai et al ) order gauge" \
# 	   " impact environmental contamination microbial community composition diversity" \
# 	   " increasingly being considered highly sensitive ecological parameters " \
# 	   "( wang et al desai et al islam sar ) therefore studies diversity composition " \
# 	   "indigenous microbial communities within sites having high risk contamination " \
# 	   "may serve baseline information assess subsequent impact contamination recent" \
# 	   " years advances culture - based - independent molecular approaches elucidated " \
# 	   "microbial diversity function sites contaminated radioactive"


#create_text_window(text,"test.txt")

iter_docs(inputFiles_DIR)

print "processing time :: ", end_time - start_time