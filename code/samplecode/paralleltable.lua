require 'torch'
require 'nn'

mlp= nn.ParallelTable()
mlp:add(nn.Linear(10,2))
mlp:add(nn.Linear(5,3))

x=torch.randn(10)
y=torch.rand(5)
input = {x,y}
print('input')
print(input)
--pred=mlp:forward{x,y}
pred=mlp:forward(input)
print('pred :: ')
print(pred)
print('loop :: ')
for i,k in pairs(pred) do print(i,k); end

