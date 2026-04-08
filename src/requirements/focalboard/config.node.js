module.exports = {
	config: {
		dbtype: postgres,
		dbconfig: postgresql://${BOARD_USER}:${DB_PASSWORD}localhost/boards?sslmode=enable&connect_timeout=10",
	}
};
