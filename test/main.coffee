immigrate = require('../app/immigrate')
expect = require("chai").expect
path = require('path')
fs = require('fs')

packageJsonFile = './package.json'
customImmigrateJsonFile = './custom-immigrate.json'
immigrateJsonFile = './immigrate.json'
resultJsonFile = './result.json'
currentVersionFake = '999.999.999'

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
			packageJson = require(packageJsonFile)
			expect(result.version).to.equal(packageJson.version)


	it "Writes last version to immigrate.json", ->
		return immigrate().then ->
			packageJson = require(packageJsonFile)
			immigrateJson = require(immigrateJsonFile)
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
			packageJsonFile: path.join(__dirname, packageJsonFile)
		})

		return promise.then (result) ->
			expect(result.version).to.equal(currentVersionFake)
	

	it "custom options.immigrateJsonFile contains result", ->
		promise = immigrate({
			immigrateJsonFile: customImmigrateJsonFile
		})

		return promise.then ->
			packageJson = require(packageJsonFile)
			immigrateJson = require(customImmigrateJsonFile)
			expect(packageJson.version).to.equal(immigrateJson.version)


	it "Migrates initially if options.migrateIfFresh is true", ->
		promise = immigrate({
			migrateIfFresh: true
		})

		return promise.then (result) ->
			packageJson = require(packageJsonFile)
			immigrateJson = require(immigrateJsonFile)
			resultJson = require(resultJsonFile)

			expect(packageJson.version).to.equal(immigrateJson.version)
			expect(resultJson.migrations).to.be.above(0)

	
