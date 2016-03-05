require 'torch'
require 'nn'

x = torch.Tensor(4,4)
 for i = 1, 4 do
    for j = 1, 4 do
       x[i][j] = (i-1)*4+j
    end
 end
 print(x)

print(nn.Reshape(2,8):forward(x))
