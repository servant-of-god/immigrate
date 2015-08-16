helpers = require('../helpers')
module.exports = ->
	recordVersion('context-found') if @foo?
	helpers.recordVersionLater('1.2.1', 350)
