--[[
Ronan Collobert - Ranking Criterion example 

]]--

require 'nn'


--p1_mlp= nn.Linear(5,2)
----p1_mlp= nn.Linear(2,1)
--p2_mlp= p1_mlp:clone('weight','bias')
--
--prl=nn.ParallelTable()
--prl:add(p1_mlp)
--prl:add(p2_mlp)
--
--mlp1=nn.Sequential()
--mlp1:add(prl)
----mlp1:add(nn.DotProduct())   --in pur case we don't want this. this is just a method of computing score
--
--mlp2=mlp1:clone('weight','bias')

--kahini to test WordEmb.lua model
mlp1 = nn.Sequential()
mlp1:add(nn.Linear(5,2))
mlp2=mlp1:clone('weight','bias')
--kahini

mlpa=nn.Sequential()
prla=nn.ParallelTable()
prla:add(mlp1)
prla:add(mlp2)
mlpa:add(prla)

crit=nn.MarginRankingCriterion(0.1)

x=torch.randn(5)
y=torch.randn(5)
z=torch.randn(5)

--x = torch.Tensor({1,1,1,1,1})
--x=torch.Tensor({1})
--y = torch.Tensor({4, 5, 6})
--y=torch.Tensor({0.5,-0.2,0.5,0.6,0.7})  --positive sample score 
--y=torch.Tensor({0.5})
--z=torch.Tensor({0.6,0.6,0.7,0.2,0.1})   --negative sample score 
--z=torch.Tensor({0.3})
-- Use a typical generic gradient update function
function gradUpdate(mlp, x, y, criterion, learningRate)
 local pred = mlp:forward(x)
 local err = criterion:forward(pred, y)
 local gradCriterion = criterion:backward(pred, y)
 mlp:zeroGradParameters()
 mlp:backward(x, gradCriterion)
 print("inside")
 mlp:updateParameters(learningRate)
end

print('listing modules')
--print(mlp1:listModules())

for i,module in ipairs(mlpa:listModules()) do
   print(module)
end

--tensor = torch.Tensor(x)
for i=1,2000 do
 gradUpdate(mlpa,{{x,y},{x,z}},1,crit,0.01)
 --gradUpdate(mlpa,tensor,1,crit,0.01)
 if true then 
      o1=mlp1:forward{x,y}[1];
      o2=mlp2:forward{x,z}[1];
      o=crit:forward(mlpa:forward{{x,y},{x,z}},1)
      --o=crit:forward(mlpa:forward(tensor),1)
      print(o1,o2,o)
      --print(o)
  end
end

print "--"

--[[for i=1,100 do
 gradUpdate(mlpa,{{x,y},{x,z}},-1,crit,0.01)
 if true then 
      o1=mlp1:forward{x,y}[1]; 
      o2=mlp2:forward{x,z}[1]; 
      o=crit:forward(mlpa:forward{{x,y},{x,z}},-1)
      --print(o1,o2,o)
  end
end ]]--


