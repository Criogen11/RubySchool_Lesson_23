require 'rubygems'
require 'sinatra'


      ###################
      ####BARBERSHOP#####
      ###################

configure do
  enable :sessions
end

get '/contacts' do
  erb :contacts
end

get '/vizit' do
  erb :vizit
end 

 

helpers do
  def username
    session[:identity] ? session[:identity] : 'Привет Гость!'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Для входа авторизируйтесь'
    halt erb(:login_form)
  end
end

get '/' do
	erb :registration	
  #erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  @login = params['username']
  @password = params['password']
  if (@login == 'TsV' && @password == '1985')
  session[:identity] = params['username'] 
  #where_user_came_from = session[:previous_url] || '/'
  #redirect to where_user_came_from
  @admin_page = "<li><a href=\"/admin\">Admin</a></li>"
  @user_vizit = File.read './public/user.txt'
  erb :admin
else
	@message = 'Вы ввели неправильный логин или пароль'
	erb :login_form
end
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end

post '/contacts' do
  @email_adress = params[:email_adress]
  @message = params[:message]
  if (@email_adress == '' && @message != '' )
     @err_email = "Вы не указали Email адрес"
    erb :contacts
  elsif (@email_adress != '' && @message == '') 
    @err_message = "Вы не ввели сообщение"
    erb :contacts
  else (@email_adress != '' && @message != '')
    @f = File.open './public/contacts.txt', 'a'
    @f.puts "\n #{@email_adress} \n  \n  #{@message}"
    @f.close
    @f = File.open './public/contacts.txt', 'a'
    @f.puts "\n --------------------------------------------------"
    @f.close
    @output = "Спасибо! Ваше сообщение отправлено."
    erb :contacts   
  end
end 

post '/vizit' do
  @user_name = params[:user_name]
  @phone = params[:phone]
  @date = params[:date]
  @barber = params[:barber]
  if (@user_name != '' && @phone != '' && @date != '' && @barber != '')
    @f = File.open './public/user.txt', 'a'
    @f.puts "\n #{@user_name}; #{@phone}; #{@date}; парикмахер: #{@barber} \n"
    @f.close
    @f = File.open './public/user.txt', 'a'
    @f.puts "\n -------------------------------------------------------------------------------------------------"
    @f.close
    @message = "#{@user_name}, спасибо что записались на стрижку! ждем вас #{@date} к парикмахеру #{@barber}!"
    erb :vizit
  elsif (@user_name == '' && @phone != '' && @date != '' && @barber != '')
    @name_error = "Вы не указали имя!"
    erb :vizit
  elsif (@user_name != '' && @phone == '' && @date != '' && @barber != '')
    @phone_error = "Вы не указали ваш телефон!"
    erb :vizit
  elsif (@user_name != '' && @phone != '' && @date == '' && @barber != '') 
    @date_error = "Вы не указали дату посещения!"
    erb :vizit
  elsif (@user_name != '' && @phone != '' && @date != '' && @barber == '')
    @barber_error = "Вы не выбрали парикмахера"
    erb :vizit
  end  
end 

