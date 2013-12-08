require "sinatra"
require 'koala'
require 'sinatra/activerecord'
require './models/timetable'
require './models/ladder'  

require './config/environments' #database configuration

GOAL = 275
enable :sessions
set :raise_errors, false
set :show_exceptions, false


#configure do
  #DB = Sequel.connect( ENV["DATABASE_URL"] )
  #require './models/timetable'
  #require './models/ladder'
#end

# Scope defines what permissions that we are asking the user to grant.
# In this example, we are asking for the ability to publish stories
# about using the app, access to what the user likes, and to be able
# to use their pictures.  You should rewrite this scope with whatever
# permissions your app needs.
# See https://developers.facebook.com/docs/reference/api/permissions/
# for a full list of permissions
#FACEBOOK_SCOPE = 'user_likes,user_photos'
FACEBOOK_SCOPE = ''

unless ENV["FACEBOOK_APP_ID"] && ENV["FACEBOOK_SECRET"]
  abort("missing env vars: please set FACEBOOK_APP_ID and FACEBOOK_SECRET with your app credentials")
end

before do
  # HTTPS redirect
  if settings.environment == :production && request.scheme != 'https'
    redirect "https://#{request.env['HTTP_HOST']}"
  end
end

helpers do
  def host
    request.env['HTTP_HOST']
  end

  def scheme
    request.scheme
  end

  def url_no_scheme(path = '')
    "//#{host}#{path}"
  end

  def url(path = '')
    "#{scheme}://#{host}#{path}"
  end

  def authenticator
    @authenticator ||= Koala::Facebook::OAuth.new(ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_SECRET"], url("/auth/facebook/callback"))
  end

  # allow for javascript authentication
  def access_token_from_cookie
    authenticator.get_user_info_from_cookies(request.cookies)['access_token']
  rescue => err
    warn err.message
  end

  def access_token
    session[:access_token] || access_token_from_cookie
  end

  # HH

  def checkDate
    year = (Time.now.year).to_s
    days = (Date.parse("31/12/#{year}").mjd - DateTime.now.mjd)
  end

  def getMandarini(user)
    s = Hash.new
    s["today"] = 0
    tt = Timetable.where(:user_id => user['id'], :day => Time.now.day, :year => Time.now.year).first
    s["goal"] = GOAL
    if tt
      s["today"] = tt.today
    end
    s["total"] = Timetable.where(:user_id => user['id'], :year => Time.now.year).sum("today")
    days = checkDate

    if days >= 31
      s["message"] = "La sfida e' conclusa! Ci rivediamo il prossimo 1 Dicembre!"
    else
      s["message"] = "Mancano ancora #{days} giorni, coraggio!"
    end

    return s
  end

end

# the facebook session expired! reset ours and restart the process
error(Koala::Facebook::APIError) do
  session[:access_token] = nil
  redirect "/auth/facebook"
end

get "/" do
  # Get base API Connection
  @graph  = Koala::Facebook::API.new(access_token)

  # Get public details of current application
  @app  =  @graph.get_object(ENV["FACEBOOK_APP_ID"])

  @goal = GOAL
  @message = "Quanti #mandarini hai mangiato oggi?"
  @total_big = 0
  @today = 1
    
  if access_token
    @user    = @graph.get_object("me")
    @friends = @graph.get_connections('me', 'friends')

    @stats = getMandarini(@user)
    @today = @stats['today']
    @message = @stats["message"]
    # for other data you can always run fql
    @friends_using_app = @graph.fql_query("SELECT uid, name, is_app_user, pic_square FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1 = me()) AND is_app_user = 1")
    
    @total_big = Timetable.where(:user_id => @user['id'], :year => Time.now.year).sum("today")
  end

  
  if checkDate > 31
    erb :finish
  else
    erb :index
  end
end

# used by Canvas apps - redirect the POST to be a regular GET
post "/" do
  redirect "/"
end

# used to close the browser window opened to post to wall/send to friends
get "/close" do
  "<body onload='window.close();'/>"
end

# Doesn't actually sign out permanently, but good for testing
get "/preview/logged_out" do
  session[:access_token] = nil
  request.cookies.keys.each { |key, value| response.set_cookie(key, '') }
  redirect '/'
end


# Allows for direct oauth authentication
get "/auth/facebook" do
  session[:access_token] = nil
  redirect authenticator.url_for_oauth_code(:permissions => FACEBOOK_SCOPE)
end

get '/auth/facebook/callback' do
  session[:access_token] = authenticator.get_access_token(params[:code])
  redirect '/'
end

# HH
post '/more' do
  howmany = params[:howmany]
  userId = params[:who]


  if howmany.to_i >= 0
    @today = howmany.to_i
    @total = Timetable.where(:user_id => userId, :year => Time.now.year).sum("today")
    timetable = Timetable.where(:user_id => userId, :day => Time.now.day, :year => Time.now.year).order("day DESC").first
    @oldtotal = 0
    ladder = Ladder.where(:user_id => userId, :year => Time.now.year).order("year DESC").first

    unless @total
      @total = 0
    end

    if timetable
      @oldtotal = @total.to_i - timetable.today.to_i
      timetable.today = @today
    else
       timetable = Timetable.new(:user_id => userId, :day => Time.now.day, :year => Time.now.year, :today => @today)
    end
    
    if timetable.save
      if ladder
        ladder.total = @oldtotal + @today
      else
        ladder = Ladder.new(:user_id => userId, :year => Time.now.year, :total => @today, :goal => GOAL)
      end

      if ladder.save
        erb :response
      else
        erb :error
      end
    else
      erb :error
    end
  else
    erb :error
  end
end


