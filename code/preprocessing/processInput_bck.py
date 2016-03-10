'''

This file takes in the pubmed bio text files and 
process them to proper format. This proper formatted 
file is then used by Neural Net. 

'''

import nltk
import nltk.data
from nltk.tokenize import sent_tokenize
from nltk.tokenize import word_tokenize
import sys
import string 
from nltk.tokenize import RegexpTokenizer
import time
import os


start_time=time.time()
tokenizer = RegexpTokenizer(r'\w+')

#Input/Output pipeline
#revisit this to read all the input files in the folder
#and create either - separate processed files each or combined. 
# training_set_text = '../data/train.txt'     #pubmed text files path
# processed_train_file = '../data/proc_train.txt'   #?? - revisit
# textwin_file= '../data/textwin_train.txt'  #processed input files
#out_file=open(textwin_file,'w+')

data_DIR = "../../../data/"
inputFiles_DIR = os.path.join(data_DIR,"tokenizedFiles/TextWinTokenFiles/" )
outputFiles_DIR = os.path.join(data_DIR,"tokenizedFiles/TextWinFiles/" )

window_size = 11    #size of text window, preferrably be odd number


#---------------------------------------------------------
# Function to read all files in a directory
#---------------------------------------------------------

def iter_docs(topdir):
    for fn in os.listdir(topdir):
        if not fn.__eq__('.DS_Store'):
            fin = open(os.path.join(topdir, fn), 'rb')
            text = fin.read()
            #texts = text.split("----------------------")[:-1]
			#iterating over each 'txt' file and calling text_win_creator

            fin.close()

def process(input_text_file,prcd_dest_file):
	#res_file=open(prcd_dest_file,'w+')
	err=0
	with open(input_text_file,"r") as inf:
		array=[]
		for line in inf:
			try:
				sentence_tokenize(line.decode('string_escape'))
			except UnicodeDecodeError:
				err=err+1
	#out_file.close()
	#print('#Lines with unicode errors: '+str(err))


def sentence_tokenize(sentences):
	res=''
	sent_tokenize_list=sent_tokenize(sentences)   #splitting text into sentences
	for s in sent_tokenize_list:
		#res+=words_tokenize(s)+'\n'
		print("sentence :: ", s)
		words=wrds_tokenize(s)     #calling the custom function wrds_tokenize - revisit - this will be replaced by UIMA word tokenization
		create_textwin(words)   #calling text window creation function
	#return res.strip(),len(sent_tokenize_list)




def wrds_tokenize(sentence):
	#words=word_tokenize(sentence.encode('utf-8'))
	#words=word_tokenize(sentence)
	#words=tokenizer.tokenize(sentence.decode('string_escape'))
	words=tokenizer.tokenize(sentence)

	#extracting text windows and writing it to proc_input_file - logic transferred to create_textwin func. 
	"""res=''
	word_count=0
	text_win=''
	for word in words:
		res+=word+' '
		if word_count < window_size:
			text_win+=word+' '
		word_count+=1 	
	text_win+='\n'
	if len(text_win.split()) == window_size:
		out_file.write(text_win)

	#return res.strip()"""
	return words
	
	
#function to create overlapping text windows from words in sequence
def create_textwin(words):
	#res=''
	s=''
	word_count=0
	text_win=''
	#making up sentence string
	"""for word in words:
		s+=' ' + word
	"""
	s=words
	#print("sentence :: ",s)
	#while len(s.split())>= 2:  #could 2 or 3 - revisit 
	while len(s)>= 2:  #could 2 or 3 - revisit 
		#text_win=s.split(' ',1)[1]   #stripping off only one word at a time
		text_win_str=''
		if len(s)>=11:
			text_win=s[:11]
		else:
			text_win=s

		for i,word in enumerate(text_win):   #revisit it will insert space at the beginnning also
			if i == 0:
				text_win_str+= word
			else:
				text_win_str+=' ' + word
		
		#print("text_win str :: ",text_win_str) 
		out_file.write(text_win_str)
		out_file.write('\n')
		temp_s=s[1:]
		#print("temp_s :: ",temp_s)
		s=temp_s

	

process(training_set_text,processed_train_file)

out_file.close()

end_time=time.time()

#print "processing time :: ", end_time - start_time

