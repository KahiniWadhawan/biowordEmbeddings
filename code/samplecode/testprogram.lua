require 'torch'
require 'nn'


function process_input()
	--inp_pos="cat chills on a mat"
	local inp_pos=torch.Tensor(4,5)
	local inp_rnd=torch.Tensor(4,5)

	for i=1,4 do 
		for j=1,5 do
			if j%2==0 then 
				inp_pos[i][j]=0
			else
				inp_pos[i][j]=1
			end
		end
	end
	print("inp pos")
	print(inp_pos) 
	--inp_rnd="cat jeju on a mat"
	for i=1,4 do 
		for j=1,5 do
			if j==2 then
				if i%2==0 then
					inp_rnd[i][j]=0
				else
					inp_rnd[i][j]=1
				end
			else 
				if j%2==0 then 
					inp_rnd[i][j]=0
				else
					inp_rnd[i][j]=1
				end
			end
		end
	end 
	print("inp_rnd")
	print(inp_rnd)
	return inp_pos,inp_rnd
end 


function build_model()
	--window approach by Conan - linear, hardTanh and linear layer 
	seql1 = nn.Sequential()
	--self.model:add(lookupTable)
	--self.model.modules[1]:add(nn.LookupTable(self.vocab_size,self.wdim))
	--seql1:add(nn.LookupTable(self.vocab_size,self.wdim))
	concatDim=1
	seql1:add(nn.Reshape(concatDim))
	hiddenUnits=2
	seql1:add(nn.Linear(concatDim, hiddenUnits))
	--if params.tanh then self.model:add(nn.Tanh()) else self.model:add(nn.HardTanh()) end
	seql1:add(nn.HardTanh())
	numClasses=1
	seql1:add(nn.Linear(hiddenUnits, numClasses))
	--adding softmax - it forces probabilities to sum to 1 
	--self.model:add(nn.LogSoftMax())
	
	--self.criterion=nn.ClassNLLCriterion()
	--local criterion = params.hinge and nn.MultiMarginCriterion() or nn.ClassNLLCriterion()
	
	seql2=seql1:clone('weight','bias')

	prlt=nn.ParallelTable()
	prlt:add(seql1)
	prlt:add(seql2)

	model=nn.Sequential()
	model:add(prlt)

	crit=nn.MarginRankingCriterion(0.5)

end 

function train(input)
	--build model 
	--build_model()   --builds global vars: model & crit 
	learningRate=0.01

	--feval=function(x)
	--input=process_input()
	--label = y = 1 for this case 
	label=1
	 -- estimate f
	local output=model:forward(input)
	print("output")
	print(output)
	local err=crit:forward(output,label)
	print("err")
	print(err)
	--estimate df/dW
	local bk=crit:backward(output,label)
	--model:zeroGradParameters()
	model:backward(input,bk) -- Backprop
	model:updateParameters(learningRate)

end 




--process input 
input_table = process_input()
--build model 
build_model(input_table)


for i=1,2 do
 train(input_table)
 out=model:forward(input_table)
 print("out")
 print(out[1],out[2])

end


--check wht the complex model does with input 
-- check how it reshapes ? 



