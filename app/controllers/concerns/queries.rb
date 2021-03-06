require 'httparty'

module Queries
	include HTTParty

	def self.generate_authorization(  _method = 'GET',
			                          params = [''],
			                          base = 'INTEGRACION grupo2:')

		@key = Rails.configuration.environment_ids['warehouses_id']
		@data = _method + params.join('')
		_hash = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'),
		                                             @key, @data)).strip()

		return base+_hash
	end

	def self.get(next_path, authorization=false, params={})
		path = Rails.configuration.environment_ids['environment_path']+next_path
		header = {	'Content-Type' => 'application/json'}
		if authorization
			header = {	'Content-Type' => 'application/json',
						'Authorization'=> authorization }
		end
		@result = HTTParty.get(path, :headers => header, :query => params )
	end

	def self.put(next_path, authorization=false, body={}, params={})
		path = Rails.configuration.environment_ids['environment_path']+next_path
		header = {	'Content-Type' => 'application/json'}
		if authorization
			header = {	'Content-Type' => 'application/json',
						'Authorization'=> authorization }
		end
		@result = HTTParty.put(path,
		                        :body => body.to_json,
		                        :headers => header,
		                        :query => params)
	end

	def self.post(next_path, body={}, params={}, authorization=false)
		path = Rails.configuration.environment_ids['environment_path']+next_path
		header = {	'Content-Type' => 'application/json'}
		if authorization
			header = {	'Content-Type' => 'application/json',
						'Authorization'=> authorization }
		end

		@result = HTTParty.post(path,
		                        :body => body.to_json,
		                        :headers => header,
		                        :query => params)
	end

	def self.delete(next_path, authorization=false, body={})
		path = Rails.configuration.environment_ids['environment_path']+next_path
		header = {	'Content-Type' => 'application/json'}
		if authorization
			header = {	'Content-Type' => 'application/json',
						'Authorization'=> authorization }
		end
		@result = HTTParty.delete(path,
		                        :body => body.to_json,
		                        :headers => header)
	end

	def self.get_to_groups_api(next_path, supplier, access_token=false, params={})

		domain = supplier.get_url
		path = domain + next_path

		header = {	'Content-Type' => 'application/json', 
					'X-ACCESS-TOKEN' => Rails.configuration.environment_ids['team_id']}
		header["Token"] = access_token if access_token

		@result = HTTParty.get(path, headers: header, query: params )
	end

	def self.patch_to_groups_api(next_path, supplier, access_token=false, params={})
		domain = supplier.get_url
		path = domain + next_path
		header = {	'Content-Type' => 'application/json', 
					'X-ACCESS-TOKEN' => Rails.configuration.environment_ids['team_id']}
		header["Token"] = access_token if access_token
		@result = HTTParty.patch(path, headers: header, query: params )
	end

	def self.put_to_groups_api(next_path, supplier, access_token=false, params={}, body={})
		domain = supplier.get_url
		path = domain + next_path
		puts path
		header = {	'Content-Type' => 'application/json', 
					'X-ACCESS-TOKEN' => Rails.configuration.environment_ids['team_id']}
		header["Token"] = access_token if access_token
		puts body
		@result = HTTParty.put(path, headers: header, query: params, body: body.to_json )
		puts @result.body
		return @result
	end


end
