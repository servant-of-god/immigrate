Promise = require('promise')
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
	
