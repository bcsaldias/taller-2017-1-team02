# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

warehouses_dev = Warehouse.create([
		{id_cloud: "590baa76d6b4ec000490255d"} , #recepcion
		{id_cloud: "590baa76d6b4ec000490255e"} , #despacho
		{id_cloud: "590baa76d6b4ec000490255f"} , #general
		{id_cloud: "590baa76d6b4ec000490265d"} , #general
		{id_cloud: "590baa76d6b4ec000490265e"} 	 #pulmon
	])

#warehouses_prod = Warehouses.create([
#		{id_cloud: "590baa76d6b4ec000490255d"} , #recepcion
#		{id_cloud: "590baa76d6b4ec000490255e"} , #despacho
#		{id_cloud: "590baa76d6b4ec000490255f"} , #general
#		{id_cloud: "590baa76d6b4ec000490265d"} , #general
#		{id_cloud: "590baa76d6b4ec000490265e"} 	 #pulmon
#	])

Supplier.all.delete_all

suppliers = Supplier.create([
		{id: 1, api_prod: "http://integra17-1.ing.puc.cl/", api_dev: "http://dev.integra17-1.ing.puc.cl/", id_cloud:"5910c0910e42840004f6e680"} ,
		{id: 2, api_prod: "http://integra17-2.ing.puc.cl/", api_dev: "http://dev.integra17-2.ing.puc.cl/"} ,
		#{id: 2, api_prod: "http://localhost:3000/", api_dev: "http://localhost:3000/"} ,
		{id: 3, api_prod: "http://integra17-3.ing.puc.cl/", api_dev: "http://dev.integra17-3.ing.puc.cl/"} ,
		{id: 4, api_prod: "http://integra17-4.ing.puc.cl/", api_dev: "http://dev.integra17-4.ing.puc.cl/"} ,
		{id: 5, api_prod: "http://integra17-5.ing.puc.cl/", api_dev: "http://dev.integra17-5.ing.puc.cl/", id_cloud:"590baa00d6b4ec0004902463"} ,
		{id: 6, api_prod: "http://integra17-6.ing.puc.cl/", api_dev: "http://dev.integra17-6.ing.puc.cl/"} ,
		{id: 7, api_prod: "http://integra17-7.ing.puc.cl/", api_dev: "http://dev.integra17-7.ing.puc.cl/", id_cloud:"590baa00d6b4ec0004902468"} ,
		{id: 8, api_prod: "http://integra17-8.ing.puc.cl/", api_dev: "http://dev.integra17-8.ing.puc.cl/"}
	])

Product.all.delete_all
products = Product.create!([
	{category:'Materia prima',description:'Pollo',owner:false,sku:'1'} ,
	{category:'Materia prima',owner:true,price: 306,sku:'2',description:'Huevo'} ,
	{category:'Materia prima',description:'Maíz',owner:false,sku:'3'} ,
	{category:'Producto procesado',description:'Aceite de Maravilla',owner:false,sku:'4'} ,
	{category:'Producto procesado',description:'Yogur',owner:false,sku:'5'} ,
	{category:'Producto procesado',owner:true,price: 1542,sku:'6',description:'Crema'} ,
	{category:'Materia prima',description:'Leche',owner:false,sku:'7'} ,
	{category:'Materia prima',owner:true,price: 756,sku:'8',description:'Trigo'} ,
	{category:'Materia prima',description:'Carne',owner:false,sku:'9'} ,
	{category:'Producto procesado',description:'Pan Marraqueta',owner:false,sku:'10'} ,
	{category:'Producto procesado',description:'Margarina',owner:false,sku:'11'} ,
	{category:'Producto procesado',description:'Cereal Avena',owner:false,sku:'12'} ,
	{category:'Materia prima',description:'Arroz',owner:false,sku:'13'} ,
	{category:'Materia prima',owner:true,price: 888,sku:'14',description:'Cebada'} ,
	{category:'Materia prima',description:'Avena',owner:false,sku:'15'} ,
	{category:'Producto procesado',description:'Pasta de Trigo',owner:false,sku:'16'} ,
	{category:'Producto procesado',description:'Cereal Arroz',owner:false,sku:'17'} ,
	{category:'Producto procesado',description:'Pastel',owner:false,sku:'18'} ,
	{category:'Materia prima',description:'Sémola',owner:false,sku:'19'} ,
	{category:'Materia prima',owner:true,price: 516,sku:'20',description:'Cacao'} ,
	{category:'Producto procesado',description:'Mantequilla',owner:false,sku:'22'} ,
	{category:'Producto procesado',description:'Harina',owner:false,sku:'23'} ,
	{category:'Materia prima',description:'Azúcar',owner:false,sku:'25'} ,
	{category:'Materia prima',owner:true,price: 297,sku:'26',description:'Sal'} ,
	{category:'Materia prima',description:'Levadura',owner:false,sku:'27'} ,
	{category:'Producto procesado',description:'Cerveza',owner:false,sku:'34'} ,
	{category:'Materia prima',description:'Semillas Maravilla',owner:false,sku:'38'} ,
	{category:'Materia prima',owner:true,price: 699,sku:'39',description:'Uva'} ,
	{category:'Producto procesado',owner:true,price: 1788,sku:'40',description:'Queso'} ,
	{category:'Producto procesado',owner:true,price: 768,sku:'41',description:'Suero de Leche'} ,
	{category:'Producto procesado',description:'Cereal Maíz',owner:false,sku:'42'} ,
	{category:'Producto procesado',description:'Chocolate',owner:false,sku:'46'} ,
	{category:'Producto procesado',description:'Vino',owner:false,sku:'47'} ,
	{category:'Producto procesado',description:'Pasta de Sémola',owner:false,sku:'48'} ,
	{category:'Producto procesado',owner:true,price: 804,sku:'49',description:'Leche Descremada'} ,
	{category:'Producto procesado',description:'Arroz con Leche',owner:false,sku:'50'} ,
	{category:'Producto procesado',description:'Pan Hallulla',owner:false,sku:'51'} ,
	{category:'Producto procesado',description:'Harina Integral',owner:false,sku:'52'} ,
	{category:'Producto procesado',description:'Pan Integral',owner:false,sku:'53'} ,
	{category:'Producto procesado',description:'Hamburguesas',owner:false,sku:'54'} ,
	{category:'Producto procesado',description:'Galletas Integrales',owner:false,sku:'55'} ,
	{category:'Producto procesado',description:'Hamburguesas de Pollo',owner:false,sku:'56'}

]	)

Contact.all.delete_all
contacts = Contact.create([

	{supplier_id: 1,expected_production_time: 2.1760000000000002,min_production_batch: 300,production_unit_cost: 290,product_id:'1'} ,
	{supplier_id: 3,expected_production_time: 3.605,min_production_batch: 300,production_unit_cost: 290,product_id:'1'} ,
	{supplier_id: 2,expected_production_time: 2.5510000000000002,min_production_batch: 150,production_unit_cost: 102,product_id:'2'} ,
	{supplier_id: 4,expected_production_time: 2.0110000000000001,min_production_batch: 150,production_unit_cost: 102,product_id:'2'} ,
	{supplier_id: 6,expected_production_time: 2.375,min_production_batch: 150,production_unit_cost: 102,product_id:'2'} ,
	{supplier_id: 3,expected_production_time: 2.1719999999999997,min_production_batch: 30,production_unit_cost: 117,product_id:'3'} ,
	{supplier_id: 5,expected_production_time: 1.726,min_production_batch: 30,production_unit_cost: 117,product_id:'3'} ,
	{supplier_id: 4,expected_production_time: 2.7130000000000001,min_production_batch: 200,production_unit_cost: 412,product_id:'4'} ,
	{supplier_id: 6,expected_production_time: 2.6150000000000002,min_production_batch: 200,production_unit_cost: 412,product_id:'4'} ,
	{supplier_id: 8,expected_production_time: 1.2050000000000001,min_production_batch: 200,production_unit_cost: 412,product_id:'4'} ,
	{supplier_id: 5,expected_production_time: 3.1910000000000003,min_production_batch: 600,production_unit_cost: 428,product_id:'5'} ,
	{supplier_id: 6,expected_production_time: 2.9160000000000004,min_production_batch: 30,production_unit_cost: 514,product_id:'6'} ,
	{supplier_id: 8,expected_production_time: 2.4809999999999999,min_production_batch: 30,production_unit_cost: 514,product_id:'6'} ,
	{supplier_id: 2,expected_production_time: 2.1230000000000002,min_production_batch: 30,production_unit_cost: 514,product_id:'6'} ,
	{supplier_id: 1,expected_production_time: 1.5930000000000002,min_production_batch: 1000,production_unit_cost: 290,product_id:'7'} ,
	{supplier_id: 3,expected_production_time: 2.2149999999999999,min_production_batch: 1000,production_unit_cost: 290,product_id:'7'} ,
	{supplier_id: 5,expected_production_time: 1.4409999999999998,min_production_batch: 1000,production_unit_cost: 290,product_id:'7'} ,
	{supplier_id: 7,expected_production_time: 3.2610000000000001,min_production_batch: 1000,production_unit_cost: 290,product_id:'7'} ,
	{supplier_id: 2,expected_production_time: 1.516,min_production_batch: 100,production_unit_cost: 252,product_id:'8'} ,
	{supplier_id: 4,expected_production_time: 2.5310000000000001,min_production_batch: 100,production_unit_cost: 252,product_id:'8'} ,
	{supplier_id: 6,expected_production_time: 3.7730000000000001,min_production_batch: 100,production_unit_cost: 252,product_id:'8'} ,
	{supplier_id: 3,expected_production_time: 1.71,min_production_batch: 620,production_unit_cost: 350,product_id:'9'} ,
	{supplier_id: 5,expected_production_time: 2.8460000000000001,min_production_batch: 620,production_unit_cost: 350,product_id:'9'} ,
	{supplier_id: 4,expected_production_time: 2.7710000000000004,min_production_batch: 900,production_unit_cost: 1084,product_id:'10'} ,
	{supplier_id: 5,expected_production_time: 3.0739999999999998,min_production_batch: 900,production_unit_cost: 247,product_id:'11'} ,
	{supplier_id: 6,expected_production_time: 3.6230000000000002,min_production_batch: 400,production_unit_cost: 624,product_id:'12'} ,
	{supplier_id: 7,expected_production_time: 1.304,min_production_batch: 1000,production_unit_cost: 358,product_id:'13'} ,
	{supplier_id: 1,expected_production_time: 3.2560000000000002,min_production_batch: 1000,production_unit_cost: 358,product_id:'13'} ,
	{supplier_id: 3,expected_production_time: 3.1639999999999997,min_production_batch: 1000,production_unit_cost: 358,product_id:'13'} ,
	{supplier_id: 2,expected_production_time: 1.8159999999999998,min_production_batch: 1750,production_unit_cost: 296,product_id:'14'} ,
	{supplier_id: 4,expected_production_time: 1.22,min_production_batch: 1750,production_unit_cost: 296,product_id:'14'} ,
	{supplier_id: 3,expected_production_time: 2.6689999999999996,min_production_batch: 480,production_unit_cost: 276,product_id:'15'} ,
	{supplier_id: 5,expected_production_time: 1.4299999999999999,min_production_batch: 480,production_unit_cost: 276,product_id:'15'} ,
	{supplier_id: 4,expected_production_time: 2.4930000000000003,min_production_batch: 1000,production_unit_cost: 612,product_id:'16'} ,
	{supplier_id: 5,expected_production_time: 1.1579999999999999,min_production_batch: 1000,production_unit_cost: 821,product_id:'17'} ,
	{supplier_id: 6,expected_production_time: 2.48,min_production_batch: 200,production_unit_cost: 331,product_id:'18'} ,
	{supplier_id: 6,expected_production_time: 1.2849999999999999,min_production_batch: 1420,production_unit_cost: 116,product_id:'19'} ,
	{supplier_id: 8,expected_production_time: 1.881,min_production_batch: 1420,production_unit_cost: 116,product_id:'19'} ,
	{supplier_id: 2,expected_production_time: 3.4750000000000001,min_production_batch: 60,production_unit_cost: 172,product_id:'20'} ,
	{supplier_id: 4,expected_production_time: 1.9550000000000001,min_production_batch: 60,production_unit_cost: 172,product_id:'20'} ,
	{supplier_id: 6,expected_production_time: 3.3560000000000003,min_production_batch: 60,production_unit_cost: 172,product_id:'20'} ,
	{supplier_id: 8,expected_production_time: 2.258,min_production_batch: 60,production_unit_cost: 172,product_id:'20'} ,
	{supplier_id: 1,expected_production_time: 1.2830000000000001,min_production_batch: 400,production_unit_cost: 336,product_id:'22'} ,
	{supplier_id: 3,expected_production_time: 2.456,min_production_batch: 400,production_unit_cost: 336,product_id:'22'} ,
	{supplier_id: 5,expected_production_time: 1.8319999999999999,min_production_batch: 400,production_unit_cost: 336,product_id:'22'} ,
	{supplier_id: 6,expected_production_time: 1.5549999999999999,min_production_batch: 300,production_unit_cost: 364,product_id:'23'} ,
	{supplier_id: 7,expected_production_time: 1.196,min_production_batch: 300,production_unit_cost: 364,product_id:'23'} ,
	{supplier_id: 8,expected_production_time: 0.91000000000000003,min_production_batch: 300,production_unit_cost: 364,product_id:'23'} ,
	{supplier_id: 1,expected_production_time: 2.9119999999999999,min_production_batch: 300,production_unit_cost: 364,product_id:'23'} ,
	{supplier_id: 1,expected_production_time: 0.82099999999999995,min_production_batch: 560,production_unit_cost: 93,product_id:'25'} ,
	{supplier_id: 3,expected_production_time: 3.2539999999999996,min_production_batch: 560,production_unit_cost: 93,product_id:'25'} ,
	{supplier_id: 5,expected_production_time: 2.7850000000000001,min_production_batch: 560,production_unit_cost: 93,product_id:'25'} ,
	{supplier_id: 7,expected_production_time: 0.94499999999999995,min_production_batch: 560,production_unit_cost: 93,product_id:'25'} ,
	{supplier_id: 2,expected_production_time: 2.609,min_production_batch: 144,production_unit_cost: 99,product_id:'26'} ,
	{supplier_id: 4,expected_production_time: 1.242,min_production_batch: 144,production_unit_cost: 99,product_id:'26'} ,
	{supplier_id: 6,expected_production_time: 1.0920000000000001,min_production_batch: 144,production_unit_cost: 99,product_id:'26'} ,
	{supplier_id: 8,expected_production_time: 3.0589999999999997,min_production_batch: 144,production_unit_cost: 99,product_id:'26'} ,
	{supplier_id: 6,expected_production_time: 3.2089999999999996,min_production_batch: 620,production_unit_cost: 232,product_id:'27'} ,
	{supplier_id: 7,expected_production_time: 3.4389999999999996,min_production_batch: 620,production_unit_cost: 232,product_id:'27'} ,
	{supplier_id: 8,expected_production_time: 1.5659999999999998,min_production_batch: 620,production_unit_cost: 232,product_id:'27'} ,
	{supplier_id: 1,expected_production_time: 1.6259999999999999,min_production_batch: 700,production_unit_cost: 557,product_id:'34'} ,
	{supplier_id: 7,expected_production_time: 3.1280000000000001,min_production_batch: 30,production_unit_cost: 379,product_id:'38'} ,
	{supplier_id: 8,expected_production_time: 3.4619999999999997,min_production_batch: 30,production_unit_cost: 379,product_id:'38'} ,
	{supplier_id: 1,expected_production_time: 3.1589999999999998,min_production_batch: 250,production_unit_cost: 233,product_id:'39'} ,
	{supplier_id: 2,expected_production_time: 3.3310000000000004,min_production_batch: 250,production_unit_cost: 233,product_id:'39'} ,
	{supplier_id: 2,expected_production_time: 0.86499999999999999,min_production_batch: 900,production_unit_cost: 596,product_id:'40'} ,
	{supplier_id: 2,expected_production_time: 1.6869999999999998,min_production_batch: 200,production_unit_cost: 256,product_id:'41'} ,
	{supplier_id: 3,expected_production_time: 1.46,min_production_batch: 200,production_unit_cost: 256,product_id:'41'} ,
	{supplier_id: 7,expected_production_time: 2.0909999999999997,min_production_batch: 200,production_unit_cost: 256,product_id:'41'} ,
	{supplier_id: 8,expected_production_time: 2.7430000000000003,min_production_batch: 200,production_unit_cost: 812,product_id:'42'} ,
	{supplier_id: 1,expected_production_time: 1.8480000000000001,min_production_batch: 800,production_unit_cost: 424,product_id:'46'} ,
	{supplier_id: 7,expected_production_time: 1.236,min_production_batch: 1000,production_unit_cost: 550,product_id:'47'} ,
	{supplier_id: 3,expected_production_time: 1.665,min_production_batch: 500,production_unit_cost: 786,product_id:'48'} ,
	{supplier_id: 1,expected_production_time: 2.0459999999999998,min_production_batch: 200,production_unit_cost: 268,product_id:'49'} ,
	{supplier_id: 2,expected_production_time: 2.3680000000000003,min_production_batch: 200,production_unit_cost: 268,product_id:'49'} ,
	{supplier_id: 3,expected_production_time: 1.8459999999999999,min_production_batch: 200,production_unit_cost: 268,product_id:'49'} ,
	{supplier_id: 4,expected_production_time: 2.8319999999999999,min_production_batch: 350,production_unit_cost: 773,product_id:'50'} ,
	{supplier_id: 7,expected_production_time: 3.0610000000000004,min_production_batch: 600,production_unit_cost: 948,product_id:'51'} ,
	{supplier_id: 3,expected_production_time: 1.4430000000000001,min_production_batch: 890,production_unit_cost: 410,product_id:'52'} ,
	{supplier_id: 5,expected_production_time: 1.506,min_production_batch: 890,production_unit_cost: 410,product_id:'52'} ,
	{supplier_id: 7,expected_production_time: 1.8969999999999998,min_production_batch: 890,production_unit_cost: 410,product_id:'52'} ,
	{supplier_id: 8,expected_production_time: 2.3999999999999999,min_production_batch: 620,production_unit_cost: 934,product_id:'53'} ,
	{supplier_id: 4,expected_production_time: 0.85999999999999999,min_production_batch: 1800,production_unit_cost: 606,product_id:'54'} ,
	{supplier_id: 4,expected_production_time: 3.2829999999999999,min_production_batch: 950,production_unit_cost: 925,product_id:'55'} ,
	{supplier_id: 5,expected_production_time: 1.5330000000000001,min_production_batch: 620,production_unit_cost: 479,product_id:'56'}



])

Recipe.all.delete_all
recipies = Recipe.create([
	{needed_product_sku:'38',requirement: 190,final_product_sku:'4',final_product_unit:'Kg',requirement_unit:'Lts'} ,
	{needed_product_sku:'49',requirement: 228,final_product_sku:'5',final_product_unit:'Lts',requirement_unit:'Lts'} ,
	{needed_product_sku:'6',requirement: 228,final_product_sku:'5',final_product_unit:'Lts',requirement_unit:'Lts'} ,
	{needed_product_sku:'41',requirement: 194,final_product_sku:'5',final_product_unit:'Lts',requirement_unit:'Lts'} ,
	{needed_product_sku:'49',requirement: 100,final_product_sku:'6',final_product_unit:'Lts',requirement_unit:'Lts'} ,
	{needed_product_sku:'7',requirement: 300,final_product_sku:'6',final_product_unit:'Lts',requirement_unit:'Lts'} ,
	{needed_product_sku:'23',requirement: 342,final_product_sku:'10',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'26',requirement: 309,final_product_sku:'10',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'4',requirement: 100,final_product_sku:'10',final_product_unit:'Lts',requirement_unit:'Kg'} ,
	{needed_product_sku:'27',requirement: 279,final_product_sku:'10',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'4',requirement: 828,final_product_sku:'11',final_product_unit:'Lts',requirement_unit:'Kg'} ,
	{needed_product_sku:'25',requirement: 133,final_product_sku:'12',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'20',requirement: 147,final_product_sku:'12',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'15',requirement: 113,final_product_sku:'12',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'23',requirement: 330,final_product_sku:'16',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'26',requirement: 313,final_product_sku:'16',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'2',requirement: 383,final_product_sku:'16',final_product_unit:'Un',requirement_unit:'Kg'} ,
	{needed_product_sku:'25',requirement: 360,final_product_sku:'17',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'20',requirement: 350,final_product_sku:'17',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'13',requirement: 290,final_product_sku:'17',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'23',requirement: 72,final_product_sku:'18',final_product_unit:'Kg',requirement_unit:'Un'} ,
	{needed_product_sku:'2',requirement: 71,final_product_sku:'18',final_product_unit:'Un',requirement_unit:'Un'} ,
	{needed_product_sku:'7',requirement: 67,final_product_sku:'18',final_product_unit:'Lts',requirement_unit:'Un'} ,
	{needed_product_sku:'6',requirement: 380,final_product_sku:'22',final_product_unit:'Lts',requirement_unit:'Kg'} ,
	{needed_product_sku:'8',requirement: 309,final_product_sku:'23',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'14',requirement: 333,final_product_sku:'34',final_product_unit:'Kg',requirement_unit:'Lts'} ,
	{needed_product_sku:'27',requirement: 319,final_product_sku:'34',final_product_unit:'Kg',requirement_unit:'Lts'} ,
	{needed_product_sku:'7',requirement: 1000,final_product_sku:'40',final_product_unit:'Lts',requirement_unit:'Kg'} ,
	{needed_product_sku:'41',requirement: 800,final_product_sku:'40',final_product_unit:'Lts',requirement_unit:'Kg'} ,
	{needed_product_sku:'7',requirement: 2000,final_product_sku:'41',final_product_unit:'Lts',requirement_unit:'Lts'} ,
	{needed_product_sku:'25',requirement: 67,final_product_sku:'42',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'20',requirement: 71,final_product_sku:'42',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'3',requirement: 69,final_product_sku:'42',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'20',requirement: 296,final_product_sku:'46',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'25',requirement: 269,final_product_sku:'46',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'7',requirement: 251,final_product_sku:'46',final_product_unit:'Lts',requirement_unit:'Kg'} ,
	{needed_product_sku:'39',requirement: 495,final_product_sku:'47',final_product_unit:'Kg',requirement_unit:'Lts'} ,
	{needed_product_sku:'27',requirement: 570,final_product_sku:'47',final_product_unit:'Kg',requirement_unit:'Lts'} ,
	{needed_product_sku:'25',requirement: 1000,final_product_sku:'47',final_product_unit:'Kg',requirement_unit:'Lts'} ,
	{needed_product_sku:'19',requirement: 160,final_product_sku:'48',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'26',requirement: 172,final_product_sku:'48',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'2',requirement: 155,final_product_sku:'48',final_product_unit:'Un',requirement_unit:'Kg'} ,
	{needed_product_sku:'7',requirement: 222,final_product_sku:'49',final_product_unit:'Lts',requirement_unit:'Lts'} ,
	{needed_product_sku:'7',requirement: 200,final_product_sku:'50',final_product_unit:'Lts',requirement_unit:'Kg'} ,
	{needed_product_sku:'25',requirement: 41,final_product_sku:'50',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'13',requirement: 100,final_product_sku:'50',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'23',requirement: 800,final_product_sku:'51',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'26',requirement: 182,final_product_sku:'51',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'22',requirement: 200,final_product_sku:'51',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'27',requirement: 279,final_product_sku:'51',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'8',requirement: 1000,final_product_sku:'52',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'38',requirement: 20,final_product_sku:'52',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'52',requirement: 500,final_product_sku:'53',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'26',requirement: 63,final_product_sku:'53',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'38',requirement: 250,final_product_sku:'53',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'7',requirement: 651,final_product_sku:'53',final_product_unit:'Lts',requirement_unit:'Kg'} ,
	{needed_product_sku:'23',requirement: 15,final_product_sku:'53',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'9',requirement: 2154,final_product_sku:'54',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'26',requirement: 153,final_product_sku:'54',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'52',requirement: 1365,final_product_sku:'55',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'20',requirement: 96,final_product_sku:'55',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'23',requirement: 20,final_product_sku:'55',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'2',requirement: 560,final_product_sku:'55',final_product_unit:'Un',requirement_unit:'Kg'} ,
	{needed_product_sku:'1',requirement: 935,final_product_sku:'56',final_product_unit:'Kg',requirement_unit:'Kg'} ,
	{needed_product_sku:'26',requirement: 65,final_product_sku:'56',final_product_unit:'Kg',requirement_unit:'Kg'}
])
