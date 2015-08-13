Promise = require('promise')
fs = require('fs')
path = require('path')

module.exports = (options = {}) -> new Promise (resolve, reject) ->
	result = {}

	options.migrationsDirectory or= "./migrations/"
	options.immigrateJsonFile or= "./immigrate.json"
	options.migrateIfFresh ?= false
	options.context ?= null

	if not options.currentVersion
		options.packageJsonFile or= findPackageJsonFile()
		if not options.packageJsonFile
			throw new Error("Could not find package.json.
							 Please provide either a packageJsonFile or currentVersion option parameter")

		packageJsonPath = path.resolve(options.packageJsonFile)
		options.currentVersion = require(packageJsonPath).version

	result.version = options.currentVersion

	resultJson = JSON.stringify(result, null, 2)

	fs.writeFile options.immigrateJsonFile, resultJson, (error) ->
		resolve(result)


findPackageJsonFile = ->
	currentDirectory = path.dirname(module.parent.filename)
	for i in [1..4]
		currentPackageJsonFile = path.join(currentDirectory, 'package.json')
		if fs.existsSync(currentPackageJsonFile)
			return currentPackageJsonFile
		currentDirectory = path.join(currentDirectory, '../')
