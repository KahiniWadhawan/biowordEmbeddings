-- Function to get all ngrams
function utils.getNgrams(doc,n,pad)
	local res={}
	local tokens=utils.padTokens(utils.splitByChar(doc,' '),pad)
	for i=1,(#tokens-n+1) do
		local word=''
		for j=i,(i+(n-1)) do
			word=word..tokens[j]..' '
		end
		word=utils.trim(word)
		table.insert(res,word)
	end
	return res
end

