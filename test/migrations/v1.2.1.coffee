helpers = require('../helpers')
module.exports = ->
	helpers.recordVersion('context-found') if this?.foo
	helpers.recordVersionLater('1.2.1', 100)
