Promise = require('promise')
fs = require('fs')
path = require('path')


readJsonFile = (fileName) -> JSON.parse(fs.readFileSync(fileName))


recordFileName = path.resolve('./test/result.json')


recordVersion = (version) ->
	try
		recordFileJson = readJsonFile(recordFileName)
	catch
		recordFileJson = { executedVersions: [] }
	
	recordFileJson[version] = true
	recordFileJson.executedVersions.push(version)

	fs.writeFileSync(recordFileName, JSON.stringify(recordFileJson))
	

recordVersionLater = (version, timeout) ->
	return new Promise (resolve, reject) ->
		timeoutCallback = ->
			recordVersion(version)
			resolve(version)

		setTimeout(timeoutCallback, timeout)

		
module.exports  = {
	recordVersion
	recordVersionLater
}
	
