require 'nn'
require 'optim'
-- -----------------------------------------------------------------------------
-- Word Embeddings Creation for BioNLP using unsupervised training
-- technique mentioned in Collobert et. al 2011
-- Word Embeddings class having Neural network for training and
-- creating wordEmbeddings
-- -----------------------------------------------------------------------------

local WordEmb=torch.class("WordEmb")
local utils=require 'utils'
--local nn = require 'nn'
--local optim = require 'optim'
-- ------------------------------------------------
-- Lua WordEmb class constructor
-- ------------------------------------------------
function WordEmb:__init(config)
	self.train_file=config.train_file    --revisit - it has to be train_file dir - same as textWinFiles
	-- for funnctional testing make a toy train_file, txt file
	self.dev_file=config.dev_file  --revisit no need - for now it is dev.txt
	--self.test_file=config.test_file -- don't need to test for now
	self.res_file=config.res_file -- might want to write vectors or something or think of dumping them
	--self.to_lower=config.to_lower
	self.wdim=config.wdim
	self.min_freq=config.min_freq
	self.wwin=config.wwin
	self.hid_size=config.hid_size
	self.num_classes = config.num_classes
	self.pre_train=config.pre_train
	self.learning_rate=config.learning_rate
	self.grad_clip=config.grad_clip
	self.batch_size=config.batch_size
	self.max_epochs=config.max_epochs
	self.reg=config.reg
	self.gpu=config.gpu
	self.vocabFiles_DIR = config.vocabFiles_DIR
	self.textwinFiles_DIR = config.textwinFiles_DIR
	self.text_win_size = config.text_win_size
	self.corpus_text = config.corpus_text
	self.CSV_DIR = config.CSV_DIR

	-- ---------------------------------------------------
	-- initializing vocab and word index structures
	-- ---------------------------------------------------
	self.vocab={} -- word frequency map for vocabulary 
	self.index2word={}
	self.word2index={}

	-- ---------------------------------------------------
	-- build vocab before training the nn
	-- ---------------------------------------------------
	utils.buildVocab(self)

	-- printing vocab, word2index
	--print(self.vocab)
	--print(self.index2word)
	--print(self.word2index)
	--print(self.corpus_text)

	utils.write_vocabToCSV(self)
	utils.write_train_samplesToCSV(self)

	-- ----------------------------------------------------
	-- build the neural network
	-- ----------------------------------------------------
	self:build_model()

	-- ----------------------------------------------------
	-- keep option to run on gpu
	-- ----------------------------------------------------
	if self.gpu==1 then
    	self:cuda()
    	end

end


-- --------------------------------------------------------------------
-- Model Training function
-- --------------------------------------------------------------------
function WordEmb:train()
	print('Training...')
	local start=sys.clock()
	local cur_batch_row=0
	local iteration=0
	local optim_state={learningRate=self.learningRate,
						learningRateDecay = self.learningRateDecay,
						weightDecay = self.weightDecay,
						momentum = self.momentum }

	-- To minimize the loss defined above, using the linear model defined
	-- in 'model', we follow a stochastic gradient descent procedure (SGD).

	-- SGD is a good optimization algorithm when the amount of training data
	-- is large, and estimating the gradient of the loss function over the
	-- entire training set is too costly.

	-- Given an arbitrarily complex model, we can retrieve its trainable
	-- parameters, and the gradients of our loss function wrt these
	-- parameters by doing so:

	x,dl_dx=self.model:getParameters()


	-- The above statement does not create a copy of the parameters in the
	-- model! Instead it create in x and dl_dx a view of the model's weights
	-- and derivative wrt the weights. The view is implemented so that when
	-- the weights and their derivatives changes, so do the x and dl_dx. The
	-- implementation is efficient in that the underlying storage is shared.

	-- A note on terminology: In the machine learning literature, the parameters
	-- that one seeks to learn are often called weights and denoted with a W.
	-- However, in the optimization literature, the parameter one seeks to
	-- optimize is often called x. Hence the use of x and dl_dx above.

	-- In the following code, we define a closure, feval, which computes
	-- the value of the loss function at a given point x, and the gradient of
	-- that function with respect to x. x is the vector of trainable weights,
	-- which, in this example, are all the weights of the linear matrix of
	-- our mode, plus one bias.

	
	feval=function(x_new)
		-- Get new params
		-- set x to x_new, if differnt
		-- (in this simple example, x_new will typically always point to x,
		-- so the copy is really useless)
		if x ~= x_new then
			x:copy(x_new)
		end

		-- Reset gradients (gradients are always accumulated, to accomodate
		-- batch methods)
		dl_dx:zero()

		-- loss is average of all criterions
		local loss=0

		-- ----------------------------------------
		-- Forward/Backward pass
		-- evaluate the loss function and its derivative wrt x,
		-- for the samples in a batch
		-- ----------------------------------------
		--print('batch :: ')
		--print(self.batch)
		--local inputs1=self.batch --now input is table of {x_pos,x_rnd}
		--local inputs=self.batch
		for bi=1,#self.batch do
			local inputs1=self.batch[bi]  --now input is table of {x_pos,x_rnd}
			--local label=self.label_tensors[bi]
			--in our case
			--In batch mode, x is a table of two Tensors of size batchsize,
			-- and y is a Tensor of size batchsize containing 1 or -1
			-- for each corresponding pair of elements in the input Tensor.
			--local label = 1
			local label = torch.Tensor(self.text_win_size):fill(1)
			print('label :: ')
			print(label)

			-- estimate f
			--local inputs2 = torch.Tensor(inputs1)
			--local inputs = inputs2:transpose(1,2)
			--local inputs = torch.Tensor(inputs1)
			local inputs = inputs1
			print('in feval -- inputs ::')
			print(inputs)
			local output=self.model:forward(inputs)
			local err=self.criterion:forward(output,label)
			loss=loss+err

			-- estimate df/dW
			local bk=self.criterion:backward(output,label)
			self.model:backward(input,bk) -- Backprop
			end --end of for loop


		loss=loss/#self.batch
		dl_dx:div(#self.batch)

		-- clip gradient element-wise
		--grad_params:clamp(-self.grad_clip,self.grad_clip)
		-- return loss(x) and dloss/dx
		return loss,dl_dx

	end

	
	self.batch={}
	--utils.loadDevCorpus(self)
	for epoch=1,self.max_epochs do
		print('Epoch '..epoch..' ...')
		local epoch_start=sys.clock()
		local cur_line=0
		local epoch_loss=0

		for i,line in ipairs(self.corpus_text) do
			print('inside train & line is :: ')
			print(line)
			local tensors=utils.getFullInputTensors(self,line) --getting input in tensor format from utils.lua
			xlua.progress(i,self.corpus_size)
			print('output of getfullinputtensors func :: ')
			print(tensors)
			for _,tensor in ipairs(tensors) do
				--table.insert(self.batch,tensor[1]) --updating batch table with ex tensors upto batch size  
				table.insert(self.batch,tensor) --updating batch table with tensor - true and rnd word tensors
				--self.label_tensors[#self.batch]=tensor[2] --revisit - we don't need labels 

				if #self.batch==self.batch_size then
					-- Train this batch
					local batch_start=sys.clock()
					iteration=iteration+1

					-- Call the optimizer
					local _,loss=optim.sgd(feval,x,optim_state)
					local train_loss = loss[1] -- the loss is inside a list, pop it
					epoch_loss=epoch_loss+train_loss

					if iteration%10==0 then collectgarbage() end

					-- clean the current batch
					for k in pairs(self.batch) do
						self.batch[k]=nil
					end
				end
			end
		end

		if #self.batch~=0 then
			local _,loss=optim.sgd(feval,params,optim_state)
			local train_loss = loss[1]
			epoch_loss=epoch_loss+train_loss
			iteration=iteration+1
		end

		xlua.progress(self.corpus_size,self.corpus_size)

		-- self:compute_dev_result()
		print(string.format("Epoch %d done in %.2f minutes. loss=%f\n\n",epoch,
			((sys.clock()-epoch_start)/60),(epoch_loss/iteration)))
	end
	print(string.format("Done in %.2f seconds.",sys.clock()-start))
end


 
-- build model --
--[[function Senna:build_model(config)
	
	--window approach by Conan - linear, hardTanh and linear layer 
	self.model = nn.Sequential()
	--self.model:add(lookupTable)
	--self.model.modules[1]:add(nn.LookupTable(self.vocab_size,self.wdim))
	self.model:add(nn.LookupTable(self.vocab_size,self.wdim))
	self.model:add(nn.Reshape(concatDim))
	self.model:add(nn.Linear(concatDim, hiddenUnits))
	if params.tanh then self.model:add(nn.Tanh()) else self.model:add(nn.HardTanh()) end
	self.model:add(nn.Linear(hiddenUnits, numClasses))
	--adding softmax - it forces probabilities to sum to 1 
	self.model:add(nn.LogSoftMax())
	
	self.criterion=nn.ClassNLLCriterion()
	--local criterion = params.hinge and nn.MultiMarginCriterion() or nn.ClassNLLCriterion()
	
end]]--

-- ------------------------------------------------------------------------------------
-- Model Architecture
-- ------------------------------------------------------------------------------------
function WordEmb:build_model(config)
	--window approach by Conan - linear, hardTanh and linear layer 
	--uncommentlocal seql1 = nn.Sequential()
	--self.model:add(lookupTable)
	--self.model.modules[1]:add(nn.LookupTable(self.vocab_size,self.wdim))
	--seql1:add(nn.LookupTable(self.vocab_size,self.wdim))
	--concatDim=1
	--print('in build model, before reshape')
	--seql1:add(nn.Reshape(concatDim))
	--print(concatDim)
	--print('after reshape')
	--print(concatDim,hiddenUnits)
	--uncomment seql1:add(nn.Linear(self.text_win_size,self.hid_size))
	--print('after Linear')
	--uncomment if params.tanh then seql1:add(nn.Tanh()) else seql1:add(nn.HardTanh()) end
	--seql1:add(nn.HardTanh())
	--uncommentseql1:add(nn.Linear(self.text_win_size, self.num_classes))
	--uncomment seql1:add(nn.Linear(self.hid_size, self.num_classes))
	--adding softmax - it forces probabilities to sum to 1
	--uncomment seql1:add(nn.LogSoftMax())
	--self.model:add(nn.LogSoftMax())
		
	--uncommentlocal seql2=seql1:clone('weight','bias')

	local prlt=nn.ParallelTable()
	prlt:add(nn.Linear(self.text_win_size, self.num_classes))
	prlt:add(nn.Linear(self.text_win_size, self.num_classes))
	--uncomment prlt:add(seql1)
	--uncomment prlt:add(seql2)

	self.model=nn.Sequential()
	--self.model:add(lookupTable)
	--self.model.modules[1]:add(nn.LookupTable(self.vocab_size,self.wdim))
	--uncomment lookup_table = nn.LookupTable(self.vocab_size,self.wdim)
	--uncomment self.model:add(lookup_table)

	self.model:add(prlt)

	self.criterion=nn.MarginRankingCriterion(0.1)

end 


-- ---------------------------------------------------------
-- Tranfer and run on CUDA
-- ---------------------------------------------------------
function WordEmb:cuda()
	require 'cunn'
	self.model:cuda()
	self.criterion:cuda()
	self.label_tensors:cuda()
end
	

-- --------------------------------------------------------------
-- Function predicting result
-- --------------------------------------------------------------
function WordEmb:compute_test_result()
	print('Computing test result...')
	local start=sys.clock()
	local file=io.open(self.res_file,'w')
	utils.loadTestCorpus(self)
	for i,line in ipairs(self.test_text) do
		local tensors=utils.getFullInputTensors(self,line)
		xlua.progress(i,#self.test_text)
		file:write(line..'\n')
		res=''
		for j,tensor in ipairs(tensors) do
			local pred=self.model:forward(tensor[1])
			res=res..utils.argmax(pred)..' '
		end
		res=utils.trim(res)
		file:write(res..'\n')
	end
	file:close()
	xlua.progress(#self.test_text,#self.test_text)
	print(string.format("Done in %.2f seconds.",sys.clock()-start))
end


-- ------------------------------------------------------------------
-- Accessing the lookup table
-- ------------------------------------------------------------------
function WordEmb:get_lookup_table()

	return lookup_table

end
