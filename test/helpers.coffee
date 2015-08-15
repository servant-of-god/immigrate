fs = require('fs')
path = require('path')


recordFileName = path.resolve('./test/result.json')


recordVersion = (version) ->
	try
		recordFileJson = require(recordFileName)
	catch
		recordFileJson = { executedVersions: [] }
	
	recordFileJson[version] = true
	recordFileJson.executedVersions.push(version)

	fs.writeFileSync(recordFileName, JSON.stringify(recordFileJson))
	

module.exports  = {
	recordVersion
}
	
