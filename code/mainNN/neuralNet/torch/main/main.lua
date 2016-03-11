-- -------------------------------------------------------------------------------------
-- Word Embeddings Creation for Biomedical using Collobert & Weston method
-- This file prepare params and intialize WordEmb model. Then it calls train method and
-- checks accuracy on dev set and finally running trained model on test set.
-- --------------------------------------------------------------------------------------
-- The model and training logic is in wordEmb.lua file.
-- ---------------------------------------------------------------------------------------

require 'torch'
require 'io'
require 'nn'
require 'sys'
require 'os'
require 'optim'
require 'xlua'
require 'lfs'
include('wordEmb.lua')

-- ---------------------------------------------------------------
-- initializing Cmdline for setting config parameters
-- ---------------------------------------------------------------
cmd = torch.CmdLine()
cmd:text()
cmd:text('Word Embeddings Creation for Biomedical texts')
cmd:text()
cmd:text('Options')

-- ------------------------------------------------------------------
--Option values with default values.
--These can be set while running program to take different value
-- data, params taking data file locations
-- ------------------------------------------------------------------
cmd:option('-inputFiles_DIR','../../../../../../data/','data dir location')
cmd:option('-textwinFiles_DIR', '../../../../../../data/tokenizedFiles/TextWinFiles/',
	'text window files location')
cmd:option('-vocabFiles_DIR','../../../../../../data/tokenizedFiles/VocabTokenFiles/',
	'vocab tokens files location')
cmd:option('-train_file','../../../../../../data/tokenizedFiles/train.txt',
	'training set file location')
cmd:option('-dev_file','../../../../../../data/tokenizedFiles/dev.txt','dev set file location')
--cmd:option('-test_file','../data/preprocessed/test.tsv','test set file location')
cmd:option('-res_file','../../../../../../data/tokenizedFiles/result.txt','result file location')
cmd:option('-to_lower',1,'change the case of word to lower case')

-- --------------------------------------------------------------------------------------
-- model params (general)
-- --------------------------------------------------------------------------------------
cmd:option('-wdim',300,'dimensionality of word embeddings') -- revisit - look more into this in glove paper
cmd:option('-min_freq',5,'words that occur less than <int> times will not be taken for training')
cmd:option('-pre_train',1,'initialize word embeddings with pre-trained vectors?')
cmd:option('-wwin',5,'word convolution units')  --revisit
cmd:option('-hid_size',300,'hidden units')     --revisit - with Ronan paper
cmd:option('-text_win_size',11,'text window size') --revisit - Ronan - 11, Glove has set it as 8. It can make a
--huge performance difference.

-- ------------------------------------------------------------------
-- optimization params
-- ------------------------------------------------------------------
cmd:option('-learning_rate',0.01,'learning rate')
cmd:option('-grad_clip',0.03,'clip gradients at this value') --revisit 
cmd:option('-batch_size',75,'number of sequences to train on in parallel')  --revisit 
cmd:option('-max_epochs',1,'number of full passes through the training data') --revisit
cmd:option('-reg',1e-4,'regularization parameter l2-norm')  --revisit - see Ronan paper for values 

-- ------------------------------------------------------------------
-- run on GPU/CPU
-- ------------------------------------------------------------------
cmd:option('-gpu',0,'1=use gpu; 0=use cpu;')

-- ------------------------------------------------------------------
-- Book-keeping
-- ------------------------------------------------------------------
cmd:option('-print_params',1,'output the parameters in the console. 0=dont print; 1=print;')

-- ------------------------------------------------------------------
-- make Logs
-- ------------------------------------------------------------------
cmd:option('-create_logs',1,'create log file for the process')

-- ------------------------------------------------------------------
-- parse input params
-- ------------------------------------------------------------------
cmd:addTime('WordEmbeddings for Biomedical texts','%F %T')
params=cmd:parse(arg)

if params.print_params==1 then
	-- output the parameters to console	
	for param, value in pairs(params) do
	    print(param ..' : '.. tostring(value))
	end
end

if params.create_logs==1 then 
	--create log file 
	params.rundir = cmd:string('../experiment/logs', params, {dir=true})
	paths.mkdir(params.rundir)

	-- create log file
	cmd:log(params.rundir .. '/log', params)
end 

-- --------------------------------------------------------------------
-- Initializing WordEmb Model
-- --------------------------------------------------------------------
model = WordEmb(params)
model:train()

-- -------------------------------------------------------------------
-- check accuracy on dev set
-- -------------------------------------------------------------------
--model:compute_dev_score()

-- -------------------------------------------------------------------
-- compute test result and save
-- -------------------------------------------------------------------
--model:compute_test_result()
