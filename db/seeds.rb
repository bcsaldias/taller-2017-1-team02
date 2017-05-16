# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Warehouse.all.delete_all
warehouses_prod = Warehouse.create([
		{id_cloud: "5910c0b90e42840004f6e74a"} , #recepcion
		{id_cloud: "5910c0b90e42840004f6e74b"} , #despacho
		{id_cloud: "5910c0b90e42840004f6e770"} , #general
		{id_cloud: "5910c0b90e42840004f6e74c"} , #general
		{id_cloud: "5910c0b90e42840004f6e771"} 	 #pulmon
	])