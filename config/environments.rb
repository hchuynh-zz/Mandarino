#The environment variable DATABASE_URL should be in the following format:
# => postgres://{user}:{password}@{host}:{port}/path
configure :production, :development do
	db = URI.parse('postgres://gxtdqrmdwmtzdw:fnstoD9k50gKHe-RkNBM2p3rXK@ec2-174-129-21-42.compute-1.amazonaws.com:5432/de977o0trtuuu8')

	ActiveRecord::Base.establish_connection(
			:adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
			:host     => db.host,
			:username => db.user,
			:password => db.password,
			:database => db.path[1..-1],
			:encoding => 'utf8'
	)
end