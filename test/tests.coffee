immigrate = require('../app/immigrate')
expect = require("chai").expect
path = require('path')
fs = require('fs')

packageJsonFile = './test/package.json'
customImmigrateJsonFile = './test/custom-immigrate.json'
immigrateJsonFile = './test/immigrate.json'
resultJsonFile = './test/result.json'
testDirectory = './test/'
currentVersionFake = '999.999.999'


readJsonFile = (fileName) -> JSON.parse(fs.readFileSync(fileName))


fromTestDirectory = (fileName) ->
	return path.relative(testDirectory, fileName)


cleanUp = ->
	fs.writeFileSync(resultJsonFile, JSON.stringify({
		migrations: 0
	}))

	filesToRemove = [
		immigrateJsonFile
		customImmigrateJsonFile
		resultJsonFile
	]

	for fileName in filesToRemove
		if fs.existsSync(fileName)
			fs.unlinkSync(fileName)


before -> cleanUp()


afterEach -> cleanUp()


describe "Option Parameters", ->
	it "Detects version from package.json if no options supplied", () ->
		return immigrate().then (result) ->
			packageJson = readJsonFile(packageJsonFile)
			expect(result.version).to.equal(packageJson.version)


	it "Writes last version to immigrate.json", ->
		return immigrate().then ->
			packageJson = readJsonFile(packageJsonFile)
			immigrateJson = readJsonFile(immigrateJsonFile)
			expect(packageJson.version).to.equal(immigrateJson.version)


	it "options.currentVersion overwrites default ./package.json version", ->
		promise = immigrate({
			currentVersion: currentVersionFake
		})

		return promise.then (result) ->
			expect(result.version).to.equal(currentVersionFake)
	

	it "options.currentVersion overwrites options.packageJsonFile", ->
		promise = immigrate({
			currentVersion: currentVersionFake
			packageJsonFile:packageJsonFile
		})

		return promise.then (result) ->
			expect(result.version).to.equal(currentVersionFake)
	

	it "custom options.immigrateJsonFile contains result", ->
		promise = immigrate({
			immigrateJsonFile: fromTestDirectory(customImmigrateJsonFile)
		})

		return promise.then ->
			packageJson = readJsonFile(packageJsonFile)
			immigrateJson = readJsonFile(customImmigrateJsonFile)
			expect(packageJson.version).to.equal(immigrateJson.version)


	it "Migrates initially if options.migrateIfFresh is true", ->
		promise = immigrate({
			migrateIfFresh: true
		})

		return promise.then (result) ->
			packageJson = readJsonFile(packageJsonFile)
			immigrateJson = readJsonFile(immigrateJsonFile)
			resultJson = readJsonFile(resultJsonFile)

			expect(packageJson.version).to.equal(immigrateJson.version)
			expect(resultJson.migrations).to.be.above(0)

	
