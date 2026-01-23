/**
 * http://usejsdoc.org/
 */
var mongo = require('mongodb').MongoClient, connection=null;

module.exports = {
		lazyConnection : function(url, callback) {
			console.log(url)
		if (this.connection) {
			console.log("cached connection")
			callback(this.connection)
		} else {
			mongo.connect(url, function(err, db_) {
				if (err) {
					callback({
						"status" : "fail",
						"cause" : err
					});
				} else {
					this.connection = {
							"status" : "success",
							"db" : db_
					}
					callback(this.connection);
				}
			});
		}
	}
}