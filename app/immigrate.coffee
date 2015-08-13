Promise = require('promise')
fs = require('fs')
path = require('path')

module.exports = (options = {}) -> new Promise (resolve, reject) ->
	result = {}

	options.packageJsonFile or= findPackageJsonFile()
	if not fs.existsSync(options.packageJsonFile)
		options.packageJsonFile = null

	baseDirectory = if options.packageJsonFile then path.dirname(options.packageJsonFile) else path.resolve(process.cwd())

	options.migrationsDirectory or= path.join(baseDirectory, "migrations/")
	options.immigrateJsonFile or= path.join(baseDirectory, "immigrate.json")
	options.migrateIfFresh ?= false
	options.context ?= null

	if not options.currentVersion
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
	return null
