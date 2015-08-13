Promise = require('promise')
fs = require('fs')
path = require('path')

module.exports = (options = {}) -> new Promise (resolve, reject) ->
	result = {}

	options.packageJsonFile or= './package.json'
	options.migrationsDirectory or= "./migrations/"
	options.immigrateJsonFile or= "./immigrate.json"
	options.migrateIfFresh ?= true
	options.context ?= null

	if not options.currentVersion
		packageJsonPath = path.resolve(options.packageJsonFile)
		options.currentVersion = require(packageJsonPath).version

	result.version = options.currentVersion

	resultJson = JSON.stringify(result, null, 2)

	fs.writeFile options.immigrateJsonFile, resultJson, (error) ->
		resolve(result)


	
