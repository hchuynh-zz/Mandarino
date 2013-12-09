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
use Rack::Session::Cookie, secret: 'PUT_A_GOOD_SECRET_IN_HERE'

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
  #if settings.environment == :production && request.scheme != 'https'
   # redirect "https://#{request.env['HTTP_HOST']}"
  #end
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

  def getLadder
    ladder = Ladder.where(:year => Time.now.year).order("total DESC")
  end

end

# the facebook session expired! reset ours and restart the process
error(Koala::Facebook::APIError) do
  session['access_token'] = nil
  redirect "/login"
end

#get "/" do
  #if access_token
  #  session[:access_token] = nil
  #  redirect "/auth/facebook"
  #else
  #   "<script>window.top.location = '"+authenticator.url_for_oauth_code(:permissions => FACEBOOK_SCOPE)+"'</script>"
  #end

  #session[:access_token] = nil
 # redirect "/auth/facebook"
  #redirect "/app"
#end

get "/" do
  # Get base API Connection
  @graph  = Koala::Facebook::API.new(session['access_token'])

  # Get public details of current application
  @app  =  @graph.get_object(ENV["FACEBOOK_APP_ID"])

  @goal = GOAL
  @message = "Quanti #mandarini hai mangiato oggi?"
  @total = 0
  @today = 1
    
  if session['access_token']
    @user    = @graph.get_object("me")
    
    @friends = @graph.get_connections('me', 'friends')

    @stats = getMandarini(@user)
    @today = @stats['today']
    @message = @stats["message"]
    # for other data you can always run fql
    @friends_using_app = @graph.fql_query("SELECT uid, name, is_app_user, pic_square FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1 = me()) AND is_app_user = 1")
    @total = Timetable.where(:user_id => @user['id'], :year => Time.now.year).sum("today")
  else
    redirect "/login"
  end

  @ladder = getLadder
  
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

# Allows for direct oauth authentication

get "/login" do
  session['oauth'] = Koala::Facebook::OAuth.new(ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_SECRET"], "#{request.base_url}/callback" )
  # redirect to facebook to get your code
  redirect session['oauth'].url_for_oauth_code()
end

get "/logout" do
  session['oauth'] = nil
  session['access_token'] = nil
  #request.cookies.keys.each { |key, value| response.set_cookie(key, '') }
  redirect '/'
end

get '/callback' do
  session['access_token'] = session['oauth'].get_access_token(params[:code])
  redirect '/'
end

# HH
post '/more' do
  howmany = params[:howmany]
  userId = params[:who]
  username = params[:username]


  if howmany.to_i >= 0
    @today = howmany.to_i
    @total = Timetable.where(:user_id => userId, :year => Time.now.year).sum("today")
    timetable = Timetable.where(:user_id => userId, :day => Time.now.day, :year => Time.now.year).order("day DESC").first
    @oldtotal = @total
    ladder = Ladder.where(:user_id => userId, :username => username, :year => Time.now.year).order("year DESC").first

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
        ladder = Ladder.new(:user_id => userId, :username => username, :year => Time.now.year, :total => @today, :goal => GOAL)
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


