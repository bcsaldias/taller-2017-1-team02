# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


Supplier.all.delete_all
suppliers = Supplier.create([
		{id: 1, api_prod: "http://integra17-1.ing.puc.cl/", api_dev: "http://dev.integra17-1.ing.puc.cl/", id_cloud_prod: "5910c0910e42840004f6e680", id_cloud_dev: nil} ,
		{id: 2, api_prod: "http://integra17-2.ing.puc.cl/", api_dev: "http://dev.integra17-2.ing.puc.cl/", id_cloud_prod: "5910c0910e42840004f6e681", id_cloud_dev: "590baa00d6b4ec0004902463"} ,
		#{id: 2, api_prod: "http://localhost:3000/", api_dev: "http://localhost:3000/"} ,
		{id: 3, api_prod: "http://integra17-3.ing.puc.cl/", api_dev: "http://dev.integra17-3.ing.puc.cl/", id_cloud_prod: nil, id_cloud_dev: nil} ,
		{id: 4, api_prod: "http://integra17-4.ing.puc.cl/", api_dev: "http://dev.integra17-4.ing.puc.cl/", id_cloud_prod: nil, id_cloud_dev: nil} ,
		{id: 5, api_prod: "http://integra17-5.ing.puc.cl/", api_dev: "http://dev.integra17-5.ing.puc.cl/", id_cloud_prod: "55910c0910e42840004f6e684", id_cloud_dev: "590baa00d6b4ec0004902466"} ,
		{id: 6, api_prod: "http://integra17-6.ing.puc.cl/", api_dev: "http://dev.integra17-6.ing.puc.cl/", id_cloud_prod: nil, id_cloud_dev: nil} ,
		{id: 7, api_prod: "http://integra17-7.ing.puc.cl/api/", api_dev: "http://dev.integra17-7.ing.puc.cl/api/", id_cloud_prod: "5910c0910e42840004f6e686", id_cloud_dev: "590baa00d6b4ec0004902468"} ,
		{id: 8, api_prod: "http://integra17-8.ing.puc.cl/", api_dev: "http://dev.integra17-8.ing.puc.cl/", id_cloud_prod: nil, id_cloud_dev: nil}
	])
