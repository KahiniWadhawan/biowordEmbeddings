require 'torch'

local utils = require '../mainNN/neuralNet/torch/main/utils'

-- --------------------------------------------
-- creating vocab and word index
-- -------------------------------------------
-- test block for buildVocab
--print("generating buildvocab logs ----------")
-- should create a config.utils_inputFiles_DIR param to pass to buildVocab
-- from whereever it called from
--inputFiles_DIR = '../../../../../../data/tokenizedFiles/TextWinTokenFiles/'
--vocab={}
--index2word={}
--word2index={}
inputFiles_DIR = 'toy/'
print('--------------------------START ----------------------')
utils.buildVocab(inputFiles_DIR)
print('-------------------------END-------------------------')
print("printing vocab and word2index complete")
print(vocab)
print(index2word)
print(word2index)


-- --------------------------------------------------------------------------------------
--testing call - Tensor functions
-- --------------------------------------------------------------------------------------
--print("generating get fullinput tensor logs ----------")
--print("printing size of word2index and index2word")
------print(#word2index)
------print(#index2word)
----
sentence="Dispersion migration uranium"
--ten=utils.getFullInputTensors(sentence)

local optim_state={learningRate=0.01}
--params,grad_params=self.model:getParameters()


batch={}
batch_size = 20
local iteration = 0
max_epochs = 1

for epoch=1,max_epochs do
    print('Epoch '..epoch..' ...')
    local epoch_start=sys.clock()
    local cur_line=0
    local epoch_loss=0

    for i,line in ipairs(corpus_text) do
        local tensors=utils.getFullInputTensors(line)
        print('inside for ipairs corpus_text & line :: ')
        print(i)
        print(line)
        print(#tensors)
        for j,tensor in ipairs(tensors) do
            --table.insert(self.batch,tensor[1]) --updating batch table with ex tensors upto batch size
            table.insert(batch,tensor) --updating batch table with tensor - true and rnd word tensors
            --self.label_tensors[#self.batch]=tensor[2] --revisit - we don't need labels
            --print('inside for loop - tensors & j :: ')
            --print(j)
            --if (j<#tensors and #batch==batch_size) or j == #tensors then
            if #batch==batch_size then
                print('one batch formed')
                print(batch)
                -- Train this batch
                local batch_start=sys.clock()
                iteration=iteration+1

                -- Call the optimizer
                local _,loss=optim.sgd(feval,params,optim_state)
                local train_loss = loss[1] -- the loss is inside a list, pop it
                epoch_loss=epoch_loss+train_loss

                if iteration%10==0 then collectgarbage() end

                -- clean the current batch
                for k in pairs(batch) do
                    batch[k]=nil
                end
            end
        end
    end
end
print(corpus_text)


function Senna:train()
    print('Training...')
    local start=sys.clock()
    local cur_batch_row=0
    local iteration=0
    local optim_state={learningRate=self.learning_rate}
    params,grad_params=self.model:getParameters()

    local idx=torch.randperm(#self.train_word_tensors)
    self.best_dev_model=self.model
    self.best_dev_score=-1.0
    for epoch=1,self.max_epochs do
        print('Epoch '..epoch..' ...')
        local epoch_start=sys.clock()
        local epoch_loss=0
        local iteration=0
        for i=1,#self.train_word_tensors do
            if i%20==0 then
                xlua.progress(i,#self.train_word_tensors)
            end
            local id=idx[i]
            for k=1,#self.train_pos_lab_tensors[id] do
                local input={self.train_word_tensors[id],self.train_pos_lab_tensors[id][k][1]}
                local label=self.train_pos_lab_tensors[id][k][2]
                -- estimate f
                local output=self.model:forward(input)
                local err=self.criterion:forward(output,label)
                epoch_loss=epoch_loss+err
                -- estimate df/dW
                local bk=self.criterion:backward(output,label)
                self.model:backward(input,bk) -- Backprop
                self.model:updateParameters(self.learning_rate)
                if grad_params:norm()>params.clip then
                    grad_params:mul(params.clip/grad_params:norm())
                end
                iteration=iteration+1
            end
        end
        xlua.progress(#self.train_word_tensors,#self.train_word_tensors)
        -- Compute dev. score
        print('Computing dev score ...')
        local tp,tn,fp,fn=0,0,0,0
        for i=1,#self.dev_word_tensors do
            xlua.progress(i,#self.dev_word_tensors)
            for k=1,#self.dev_pos_lab_tensors[i] do
                local input_tensor={self.dev_word_tensors[i],self.dev_pos_lab_tensors[i][k][1]}
                local target_tensor=self.dev_pos_lab_tensors[i][k][2]
                local output=self.model:forward(input_tensor)
                local pred=1
                if output[1]<output[2] then
                    pred=2
                end
                if pred==1 and target_tensor[1]==1 then
                    tn=tn+1
                elseif pred==1 and target_tensor[1]==2 then
                    fn=fn+1
                elseif pred==2 and target_tensor[1]==1 then
                    fp=fp+1
                else
                    tp=tp+1
                end
            end
        end
        xlua.progress(#self.dev_word_tensors,#self.dev_word_tensors)
        print(string.format('%d %d %d %d',tp,fp,tn,fn))
        local precision,recall=(tp/(tp+fp)),(tp/(tp+fn))
        local fscore=((2*precision*recall)/(precision+recall))
        print(string.format("Epoch %d done in %.2f minutes. loss=%f Dev Score=(P=%.2f R=%.2f F=%.2f)\n",epoch,((sys.clock()-epoch_start)/60),(epoch_loss/iteration),precision,recall,fscore))
        if fscore>self.best_dev_score then
            self.best_dev_score=fscore
            self.best_dev_model=self.model:clone()
        end
    end

    -- Do the final testing
    print('Computing test score ...')
    local tp,tn,fp,fn=0,0,0,0
    local start=sys.clock()
    for i=1,#self.test_word_tensors do
        xlua.progress(i,#self.test_word_tensors)
        for k=1,#self.test_pos_lab_tensors[i] do
            local input_tensor={self.test_word_tensors[i],self.test_pos_lab_tensors[i][k][1]}
            local target_tensor=self.test_pos_lab_tensors[i][k][2]
            local output=self.best_dev_model:forward(input_tensor)
            local pred=1
            if output[1]<output[2] then
                pred=2
            end
            if pred==1 and target_tensor[1]==1 then
                tn=tn+1
            elseif pred==1 and target_tensor[1]==2 then
                fn=fn+1
            elseif pred==2 and target_tensor[1]==1 then
                fp=fp+1
            else
                tp=tp+1
            end
        end
    end
    xlua.progress(#self.test_word_tensors,#self.test_word_tensors)
    print(string.format('%d %d %d %d',tp,fp,tn,fn))
    local precision,recall=(tp/(tp+fp)),(tp/(tp+fn))
    local fscore=((2*precision*recall)/(precision+recall))
    print(string.format('Test Score=(P=%.2f R=%.2f F=%.2f)',precision,recall,fscore))
    print(string.format("Testing Done in %.2f minutes.",((sys.clock()-start)/60)))
    print(string.format("Done in %.2f seconds.",sys.clock()-start))
end



