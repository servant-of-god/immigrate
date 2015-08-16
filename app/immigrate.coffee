semver = require('semver')
Promise = require('promise')
fs = require('fs')
path = require('path')


readJsonFile = (fileName) -> JSON.parse(fs.readFileSync(fileName))


module.exports = (options = {}) -> new Promise (resolve, reject) ->
	options = normalizeOptions(options)

	try
		state = readJsonFile(options.immigrateJsonFile)
		isFresh = no
	catch
		state =
			version: '0.0.0'
		
		isFresh = yes

	migrationFiles = getSortedMigrationFiles(options, state)

	if isFresh and not options.migrateIfFresh
		migrationFiles = []
	
	if isFresh
		setupFile = findSetupFile(options)
		migrationFiles.unshift setupFile if setupFile
	
	executeMigrations(options, migrationFiles).then ->
		state.version = options.currentVersion

		writeImmigrateJsonFile(options.immigrateJsonFile, state)

		resolve(state)


writeImmigrateJsonFile = (fileName, state) ->
	stateJson = JSON.stringify(state, null, 2)

	fs.writeFileSync(fileName, stateJson)


normalizeOptions = (options) ->
	fillInDefaultOptions(options)

	options.packageJsonFile = findPackageJsonFile(options.packageJsonFile)

	if not options.currentVersion and not options.packageJsonFile
		throw new Error("Could not find package.json. Please provide either a
				valid packageJsonFile or currentVersion option parameter.")

	else if not options.currentVersion
		options.currentVersion = require(options.packageJsonFile).version

	baseDirectory = getBaseDirectory(options.packageJsonFile)

	try
		options.immigrateJsonFile = findFile(baseDirectory, options.immigrateJsonFile)
	catch
		options.immigrateJsonFile = path.join(baseDirectory, options.immigrateJsonFile)
	
	try
		options.migrationsDirectory = findFile(baseDirectory, options.migrationsDirectory)
	catch
		throw new Error("Could not find migrationsDirectory (#{options.migrationsDirectory})")

	return options


findPackageJsonFile = (packageJsonFile) ->
	if packageJsonFile
		packageJsonFile = path.resolve(packageJsonFile)
		if not fs.existsSync(packageJsonFile)
			throw new Error('Could not find the supplied package.json file. Leave option blank for auto-detection.')
		return packageJsonFile

	currentDirectory = path.dirname(module.parent.filename)
	searchParentDirectoryCount = 4

	for i in [1..searchParentDirectoryCount]
		currentPackageJsonFile = path.join(currentDirectory, 'package.json')
		if fs.existsSync(currentPackageJsonFile)
			return currentPackageJsonFile
		currentDirectory = path.join(currentDirectory, '../')
	return null


findFile = (baseDirectory, fileName) ->
	if fs.existsSync(fileName)
		return path.resolve(fileName)
	else if fs.existsSync(path.join(baseDirectory, fileName))
		return path.join(baseDirectory, fileName)
	
	throw new Error("Could not find file #{fileName}")


fillInDefaultOptions = (options) ->
	options.currentVersion ?= null
	options.packageJsonFile ?= null
	options.migrationsDirectory ?= "./migrations/"
	options.immigrateJsonFile ?= "./immigrate.json"
	options.migrateIfFresh ?= false
	options.context ?= null


getBaseDirectory = (packageJsonFile) ->
	if packageJsonFile
		return path.dirname(packageJsonFile)
	else
		return process.cwd()


getSortedMigrationFiles = (options, state) ->
	files = []

	for fileName in fs.readdirSync(options.migrationsDirectory)
		fileNameWithoutExtension = fileName.split('.')[..-2].join('.')
		if not semver.valid(fileNameWithoutExtension)
			continue

		filePath = path.join(options.migrationsDirectory, fileName)

		files.push({
			fileName: filePath
			version: semver.clean(fileNameWithoutExtension)
		})

	if state.version
		files = files.filter (file) ->
			return semver.gt(file.version, state.version)
	
	files = files.filter (file) ->
		return not semver.gt(file.version, options.currentVersion)

	files = files.sort (fileLeft, fileRight) ->
		return 1 if semver.gt(fileLeft.version, fileRight.version)
		return -1 if semver.lt(fileLeft.version, fileRight.version)
		return 0

	return files


findSetupFile = (options) ->
	for fileName in fs.readdirSync(options.migrationsDirectory)
		fileNameWithoutExtension = fileName.split('.')[..-2].join('.')
		if fileNameWithoutExtension is "setup"
			filePath = path.join(options.migrationsDirectory, fileName)
			return {
				fileName: filePath
				version: options.currentVersion
			}


executeMigrations = (options, migrationFiles) ->
	executeNextMigration = ->
		return Promise.resolve() if not migrationFiles.length

		file = migrationFiles.shift()

		migration = require(file.fileName)

		if typeof migration is "function"
			migration = migration.call(options.context, options.context)

		if typeof migration?.then is "function"
			return migration.then -> executeNextMigration()
		
		else return executeNextMigration()


	return executeNextMigration()


