immigrate = require('../app/immigrate')
expect = require("chai").expect
path = require('path')
fs = require('fs')
clearRequire = require('clear-require')

packageJsonFile = './test/package.json'
customImmigrateJsonFile = './test/custom-immigrate.json'
immigrateJsonFile = './test/immigrate.json'
resultJsonFile = './test/result.json'
setupFile = './test/migrations/setup.coffee'
testDirectory = './test/'
currentVersionFake = '999.999.999'


readJsonFile = (fileName) -> JSON.parse(fs.readFileSync(fileName))

createSetupFile = ->
	fs.writeFileSync(setupFile, "module.exports = require('../helpers').recordVersionLater('setup', 300)")


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
		setupFile
	]

	for fileName in filesToRemove
		if fs.existsSync(fileName)
			fs.unlinkSync(fileName)
	clearRequire.all()


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
			expect(resultJson.executedVersions.length).to.be.above(3)

	
	it "Accepts v-prefix for version files", ->
		return immigrate({
			currentVersion: '0.0.1'
		}).then -> immigrate().then ->
			resultJson = readJsonFile(resultJsonFile)
			expect(resultJson.executedVersions).to.include('1.2.1')


	it "Accepts prefixless version files", ->
		return immigrate({
			currentVersion: '0.0.1'
		}).then -> immigrate().then ->
			resultJson = readJsonFile(resultJsonFile)
			expect(resultJson.executedVersions).to.include('1.0.1')


	it "Accepts .js file extension", ->
		return immigrate({
			currentVersion: '0.0.1'
		}).then -> immigrate().then ->
			resultJson = readJsonFile(resultJsonFile)
			expect(resultJson.executedVersions).to.include('1.0.1')

	

	it "Accepts .coffee file extension", ->
		return immigrate({
			currentVersion: '0.0.1'
		}).then -> immigrate().then ->
			resultJson = readJsonFile(resultJsonFile)
			expect(resultJson.executedVersions).to.include('1.2.0')


	it "Proper promise recognition and chaining", ->
		return immigrate({
			currentVersion: '0.0.1'
		}).then -> immigrate().then ->
			resultJson = readJsonFile(resultJsonFile)
			expect(resultJson.executedVersions).to.deep.equal(['1.0.1', '1.2.0', '1.2.1', '1.2.2'])


	it "Handles migrateIfFresh and setup for first execution", ->
		createSetupFile()

		return immigrate({migrateIfFresh:true}).then ->
			resultJson = readJsonFile(resultJsonFile)
			expect(resultJson.executedVersions).to.deep.equal(['setup' ,'1.0.1', '1.2.0', '1.2.1', '1.2.2'])


	it "Only runs setup on first execution", ->
		createSetupFile()
		return immigrate().then ->
			resultJson = readJsonFile(resultJsonFile)
			expect(resultJson.executedVersions).to.include('setup')
			expect(resultJson.executedVersions).to.have.length(1)


	it "Does not run setup file again after first execution", ->
		createSetupFile()
		return immigrate({
			currentVersion: '0.0.1'
		}).then ->
			fs.unlinkSync(resultJsonFile)

			return immigrate().then ->
				resultJson = readJsonFile(resultJsonFile)
				expect(resultJson.executedVersions).to.not.include('setup')


	it "Only executes files in version upgrade range", ->
		return immigrate({
			currentVersion: '1.2.0'
		}).then ->
			fs.unlinkSync(resultJsonFile)

			return immigrate().then ->
				resultJson = readJsonFile(resultJsonFile)
				expect(resultJson.executedVersions).to.deep.equal(['1.2.1', '1.2.2',])
	

	it "Creates immigrate.json even if no scripts are executed", ->
		return immigrate({currentVersion: '99.99.99'}).then ->
			immigrateJson = readJsonFile(immigrateJsonFile)
			expect(immigrateJson.version).to.equal('99.99.99')
	
	
	it "Makes context accessible to version files", ->
		return immigrate({context: {foo: 'bar'}}).then ->
			resultJson = readJsonFile(resultJsonFile)
			expect(resultJson['context-found'].to.be.true)
			expect(resultJson['argument-found'].to.be.true)

	
	it "Handles absolute packageJsonFile path", ->
		return immigrate({
			packageJsonFile: path.resolve(packageJsonFile)
		}).then (result) ->
			packageJson = readJsonFile(packageJsonFile)
			expect(result.version).to.equal(packageJson.version)
	

	it "Handles absolute migrationsDirectory path", ->
		createSetupFile()

		return immigrate({
			migrationsDirectory: path.resolve(migrationsDirectory)
		}).then ->
			resultJson = readJsonFile(resultJsonFile)
			expect(resultJson.executedVersions).to.include('setup')



	it "Handles absolute immigrateJsonFile path", ->
		return immigrate({
			currentVersion: currentVersionFake
			immigrateJsonFile: path.resolve(immigrateJsonFile)
		}).then ->
			immigrateJson = readJsonFile(immigrateJsonFile)
			expect(immigrateJson.version).to.equal(currentVersionFake)

