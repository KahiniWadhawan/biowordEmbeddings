-- -----------------------------------------------------------
-- Utils file has all processing, data manipulation functions
-- -----------------------------------------------------------

require 'torch'
require 'math'

local utils={}

vocab={}
min_freq=5 --revisit make 5 after testing, use config var version
index2word={}
word2index={}
window_size=11   --preferrably choose odd number - can make config var, but change that in python file also later
window_size = config.text_window_size
-- -----------------------------------------------------------
-- Function to trim the string  --revisit, not used as of now
-- -----------------------------------------------------------
function utils.trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- ----------------------------------------------------------
-- Function to split a string by given splitpattern
-- ----------------------------------------------------------
function utils.splitByChar(str,inSplitPattern)
	outResults={}
	local theStart = 1
	local theSplitStart,theSplitEnd=string.find(str,inSplitPattern,theStart)
	while theSplitStart do
		table.insert(outResults,string.sub(str,theStart,theSplitStart-1))
		theStart=theSplitEnd+1
		theSplitStart,theSplitEnd=string.find(str,inSplitPattern,theStart)
	end
	table.insert(outResults,string.sub(str,theStart))
	return outResults
end

-- ----------------------------------------------------------------------
-- Function to pad tokens. Used for Border effects from Collobert paper
--Also, making every token in lower case 
--function utils.padTokens(tokens,pad)
-- ----------------------------------------------------------------------
function utils.padTokens(tokens,lpad_len,rpad_len)
	local res={}

	-- Append begin tokens
	for i=1,lpad_len do
		table.insert(res,'<bpad-'..i..'>')
	end

	for _,word in ipairs(tokens) do
		table.insert(res,word:lower())
	end

	-- Append end tokens
	for i=1,rpad_len do
		table.insert(res,'<epad-'..i..'>')
	end

	return res
end


-- -----------------------------------------------------------
-- Function to get all ngrams
-- -----------------------------------------------------------
function utils.getNgrams(doc,n,pad)
	local res={}
	--print("doc :: ")
	--print(doc)
	-- revisit - is padding needed?
	--changing for our case
	tokens_wo_pad=utils.splitByChar(doc,' ')
	--print("tokens wo pad")
	--print(tokens_wo_pad)
	--padding is calculated using window_size
	missing_tokens=window_size-#tokens_wo_pad
	--print(string.format("missing tokens ::%d",missing_tokens))
	lpad_len=missing_tokens/2 
	rpad_len=missing_tokens-lpad_len
	local tokens=utils.padTokens(tokens_wo_pad,lpad_len,rpad_len)
	--local tokens=utils.splitByChar(doc,' ')
	--print("tokens :: ")
	--print(tokens) 
	--note: this function is basically for ngrams, so adding extra space at the end of each word. 
	for i=1,(#tokens-n+1) do
		local word=''
		for j=i,(i+(n-1)) do
			word=word..tokens[j]..' '
		end
		--word=utils.trim(word)   --revisit - do i need this? This should be in input_process.py 
		table.insert(res,word)
	end
	--print("res")
	--print(res)

	return res
end


-- ----------------------------------------------------------------------------
--revisit this func - check what to pass to getNgrams func for n, 2nd arg. 
-- Function to process a sentence to build vocab
--function utils.processSentence(config,sentence)
-- ----------------------------------------------------------------------------
function utils.processSentence(sentence)
--	local pad=(config.wwin/2)
	print("----- processSentence func -------")
	--print(sentence)
	wwin = 11  --remove later - take directly from config 
	local pad=(wwin/2)
	ngrams = utils.getNgrams(sentence,1,pad)
	print("ngrams :: ")
	print(ngrams)
	--for _,word in ipairs(utils.getNgrams(sentence,1,pad)) do
	for _,word in ipairs(ngrams) do

		--config.total_count=config.total_count+1
		total_count=total_count+1

		--word=utils.splitByChar(word,'%$%$%$')[1]
		print('word')
		print(word)
		word=utils.splitByChar(word,' ')[1]
		print(word)
		--[[if config.to_lower==1 then
			word=word:lower()
		end]]--
		word=word:lower()


		-- Fill word vocab.
		--if config.vocab[word]==nil then
		if vocab[word]==nil then
			--config.vocab[word]=1			
			--print(string.format("printing word $$$%s$$$",word))
			vocab[word]=1
			--print ("entered vocab if")
		else
			--config.vocab[word]=config.vocab[word]+1
			vocab[word]=vocab[word]+1
			--print ("entered vocab else")

		end
	end

	print('vocab after current line processed')
	print(vocab)
	--config.corpus_size=config.corpus_size+1
	corpus_size=corpus_size+1
end 


-- --------------------------------------------------------------------
--revisit to add config to this after independent testing  
--function utils.buildVocab(config)
-- Notes: need to write iter_docs func that reads from tokenized normal
-- txt files and build vocab. Don't use text_window txt files for this
-- ---------------------------------------------------------------------
function utils.buildVocab(directory)
	print('Building vocabulary...')
	local start=sys.clock()

	-- initializing variables to iter a directory
	local i, t, popen = 0, {}, io.popen
	local pfile = popen('ls "'..directory..'"')

	-- Fill the vocabulary frequency map
	--config.total_count=0
	--config.corpus_size=0
	--config.corpus_text={}
	-- revisit to check - needs to out of for loop??
	total_count=0
	corpus_size=0
	corpus_text={}

	-- for loop for reading all txt files
	for filename in pfile:lines() do
		local file_path = directory..filename
		print(file_path)
		--local fptr=io.open(config.train_file,'r')
		--revisit - to change acc. to notes page 7
		local fptr=io.open(file_path,'r')

		while true do
			local line=fptr:read()
			print('line')
			print(line)
			if line==nil then
				break
			end

			utils.processSentence(line)
			--table.insert(config.corpus_text,abstract)
			table.insert(corpus_text,line)

		end

		fptr.close()
	
	--print("printing corpus text :: ")
	--print(corpus_text)
	end   --end of for iter dir loop
	pfile:close()

	print('inside buildVocab func, outside iter dir loop')
	print('printing vocab and word2index')
	print(vocab)
	print(word2index)

	-- Discard the words that doesn't meet minimum frequency and create indices.
	--for word,count in pairs(config.vocab) do
	for word,count in pairs(vocab) do
		--if count<config.min_freq then
		if count<min_freq then
			--config.vocab[word]=nil
			vocab[word]=nil
		else
			--config.index2word[#config.index2word+1]=word
			--config.word2index[word]=#config.index2word
			index2word[#index2word+1]=word
			word2index[word]=#index2word

		end
	end

	-- Add unknown word
	--[[config.vocab['<UK>']=1
	config.index2word[#config.index2word+1]='<UK>'
	config.word2index['<UK>']=#config.index2word
	config.vocab_size= #config.index2word]]--
	vocab['<UK>']=1
	index2word[#index2word+1]='<UK>'
	word2index['<UK>']=#index2word
	vocab_size= #index2word
	--print("index2word")
	--print(index2word)
	--print("word2index")
	--print(word2index)
	--print (string.format("vocab_size :: %d",vocab_size))
	
	--print(string.format("%d words, %d documents processed in %.2f seconds.",config.total_count,config.corpus_size,sys.clock()-start))
	--print(string.format("Vocab size after eliminating words occuring less than %d times: %d",config.min_freq,config.vocab_size))
	

end
 
-- test block for buildVocab
--print("generating buildvocab logs ----------")
-- should create a config.utils_inputFiles_DIR param to pass to buildVocab
-- from whereever it called from
--inputFiles_DIR = '../../../../../../data/tokenizedFiles/TextWinTokenFiles/'
inputFiles_DIR = '../../../../../../data/tokenizedFiles/toy/'
print('--------------------------START ----------------------')
utils.buildVocab(inputFiles_DIR)
print('-------------------------END-------------------------')
print("printing vocab and word2index complete")
print(vocab)
print(index2word)
print(word2index)


-- -------------------------------------------------------------------------------------
-- Function to get word tensor
--function utils.getWordTensor(config,words)
-- -------------------------------------------------------------------------------------
function utils.getWordTensor(words)
	
	local wordTensor=torch.Tensor(#words)

	for i,word in ipairs(words) do
		--print("inside loop, word :: ")
		--print(word)
		--word are coming as an ngram of size 1, with extra space attached. 
		word=utils.splitByChar(word,' ')[1]

		--print(string.format("printing word $$$%s$$$",word))
		--if config.word2index[word]==nil then
		if word2index[word]==nil then
			--print("word did not match")
			--wordTensor[i]=config.word2index['<UK>']
			wordTensor[i]=word2index['<UK>']
		else
			--print("word matched")
			--wordTensor[i]=config.word2index[word]
			wordTensor[i]=word2index[word]
		end
	end
	return wordTensor
end


-- ----------------------------------------------------------------------------------------
-- Function to get rnd word tensor --always prefer giving odd sentence window size
--function utils.getRndWordTensor(config,words)
-- -----------------------------------------------------------------------------------------
function utils.getRndWordTensor(words)

	local rnd_wordTensor=torch.Tensor(#words)
	--print("inside rnd word Tensor")
	--print(#word2index)
	--print(#index2word)

	--replace the middle word with random word in vocab
	--print("words")
	--print(#words)
	mid_ind= #words/2 + 1 
	count = 0 
	for i,word in ipairs(words) do
		count = count + 1
		--word are coming as an ngram of size 1, with extra space attached. 
		word=utils.splitByChar(word,' ')[1]

		--print(string.format("middle index ::%d,%s",mid_ind,type(mid_ind)))
		--print(string.format(" index ::%d,%s",i,type(i)))
		--if i == mid_ind then --revisit 
		if math.floor(i) == math.floor(mid_ind) then
			print("$$$$$$$$$$$$ mid ind matched")
			print(string.format("middle index ::%d,%s",mid_ind,type(mid_ind)))
			print(string.format("index ::%d,%s",i,type(i)))

			--pick up a rnd word from vocab dict
			--generate a random number in a range of size of word2index & pick that word
			math.randomseed(os.time())	
			math.random(#index2word) 
			rnd_index=math.random(#index2word)  --#word2index doesnot give correct size
			print(string.format("rnd index ::%d",rnd_index))
			rnd_wordTensor[i]=rnd_index	
					
		else
			--if config.word2index[word]==nil then
			if word2index[word]==nil then
				--wordTensor[i]=config.word2index['<UK>']
				rnd_wordTensor[i]=word2index['<UK>']

			else
				--wordTensor[i]=config.word2index[word]
				rnd_wordTensor[i]=word2index[word]
			end
		end 
	end
	return rnd_wordTensor
end


-- ----------------------------------------------------------------------------------------------
-- check if this is providing every token in lower case, because vocab,
-- word2index and index2word are made from lower case tokens
-- Function to get input tensors.
--function utils.getFullInputTensors(config,sentence) --sentence here is sentence
-- window of 11 words
-- ----------------------------------------------------------------------------------------------
function utils.getFullInputTensors(sentence)
	print("------------- Inside get fullInputTensors --------------")
	--for independent testing 
	local tensors={}
	--local pad=(config.wwin/2) --don't need this now here. Logic included in getNgrams func
	local pad=4 --just for testing. until this is corrected/removed from this func
	local words=utils.getNgrams(sentence,1,pad)
	--getting true word tensor
	--local true_wordTensor=utils.getWordTensor(config,words)
	local true_wordTensor=utils.getWordTensor(words)
	print("true word tensor")
	print(true_wordTensor)

	--getting rnd word tensor 
	--local rnd_wordTensor=utils.getRndWordTensor(config,words)  --new function for creating random sample
	local rnd_wordTensor=utils.getRndWordTensor(words)
	print("Random word tensor")
	print(rnd_wordTensor) 

	for i,word in ipairs(words) do
		table.insert(tensors,{true_wordTensor[i],rnd_wordTensor[i]})		
	end
	return tensors
end


-- --------------------------------------------------------------------------------------
--testing call - Tensor functions
-- --------------------------------------------------------------------------------------
--print("generating get fullinput tensor logs ----------")
--print("printing size of word2index and index2word")
------print(#word2index)
------print(#index2word)
----
--sentence="Dispersion migration uranium"
--ten=utils.getFullInputTensors(sentence)


-- ----------------------------------------------------------------------------
-- Function to find predicted class
--test later
-- ----------------------------------------------------------------------------
function utils.argmax(v)
	local idx=1
	local max=v[1]
	for i=2,v:size(1) do
		if v[i]>max then
			max=v[i]
			idx=i
		end
	end
	return idx
end


-- ------------------------------------------------------------------------------
-- Function to find accuracy
--test later
-- ------------------------------------------------------------------------------
function utils.accuracy(pred,gold)
	return torch.eq(pred,gold):sum()/pred:size(1)
end


-- Function to load dev corpus
--not required for word emb - unsupervised task 
--uncomment 
--[[function utils.loadDevCorpus(config)
	local fptr=io.open(config.dev_file,'r')
	config.dev_text={}
	while true do ]]--

		--[[local pid=fptr:read()
		if pid==nil then
			break
		end
		local abstract=fptr:read()
		if abstract==nil then
			break
		end
		table.insert(config.dev_text,abstract)
		local abstract=fptr:read()]]--
		
		--uncomment
		--[[local abstract=fptr:read()
		if abstract==nil then
			break
		end
		table.insert(config.dev_text,abstract)]]--

		--[[local noOfSent=tonumber(fptr:read())
		for i=1,noOfSent do
			local sentence=fptr:read()
			table.insert(config.dev_text,sentence)
		end]]--
	--uncomment
	--[[
	end
	fptr.close()
end]]--

-- Function to load test corpus 
-- not required in word emb - unsupervised task 
--[[function utils.loadTestCorpus(config)
	local fptr=io.open(config.test_file,'r')
	config.test_text={}
	while true do ]]-- uncomment 

		--[[local pid=fptr:read()
		if pid==nil then
			break
		end
		local abstract=fptr:read()
		utils.processSentence(config,abstract)]]--
		
		--uncomment
		--[[local sentence=fptr:read()
		if sentence==nil then
			break
		end
		utils.processSentence(config,sentence)		
		]]--
		
		--[[local noOfSent=tonumber(fptr:read())
		for i=1,noOfSent do
			local sentence=fptr:read()
			table.insert(config.test_text,sentence)
		end]]--
	--uncomment 
	--[[end
	fptr:close()
end
]]--
return utils

