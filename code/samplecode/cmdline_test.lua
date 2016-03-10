cmd = torch.CmdLine()
cmd:text()
--cmd:text()
cmd:addTime('your project name','%F %T')
cmd:text('Training a simple network')
--cmd:text()
--Option values with default values.
--These can be set while running program to take different value
cmd:addTime('your project name','%F %T')
cmd:text('Options')
cmd:addTime('your project name','%F %T')
cmd:option('-seed',123,'initial random seed')
cmd:addTime('your project name','%F %T')
cmd:option('-booloption',false,'boolean option')
cmd:addTime('your project name','%F %T')
cmd:option('-stroption','mystring','string option')
--cmd:text()

-- parse input params
cmd:addTime('your project name','%F %T')
params = cmd:parse(arg)

params.rundir = cmd:string('experiment', params, {dir=true})
paths.mkdir(params.rundir)

-- create log file
cmd:log(params.rundir .. '/log', params)
