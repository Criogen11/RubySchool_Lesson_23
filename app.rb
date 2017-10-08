# coding: utf-8
require 'rubygems'
require 'sinatra'
require 'pony'
require 'sqlite3'


      ###################
      ####BARBERSHOP#####
      ###################


#  Метод для подключения SQLite3 и включения режима вывода из базы данных результатов в виде хеша
#
#   def get_db 
#
#      db = SQLite3::Database.new 'BarberShop.sqlite'
#      db.result_as_hash = true   #   включение вывода в виде хеша
#      return db
#   end


configure do
  enable :sessions
  #   При инициализации приложения база данных будет создана если ее нет
  #db = SQLlite3::Database.new 'BarberShop.sqlite'
  #db.execute "Сдесь пишем код создания таблицы если ее еще не существует"
end



get '/contacts' do
  erb :contacts
end

get '/vizit' do
  erb :vizit
end 

 get '/admins' do
  erb :admins
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
  if (@login == 'admin' && @password == 'admin')
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
  hh = { :email_adress => 'Введите email адрес', :message => 'Введите сообщение' }
  @error = hh.select {|key,_| params[key] == ""}.values.join(", ")
  if @error != ''
    return erb :contacts
  end 

  db = SQLite3::Database.new 'BarberShop.sqlite'
  db.execute "INSERT INTO Contacts (Email, Message) VALUES ('#{@email_adress}', '#{@message}')"
  db.close

  erb "Спасибо за ваше обращение к нам!" 

end 

post '/vizit' do
  @user_name = params[:user_name]
  @phone = params[:phone]
  @date = params[:date]
  @barber = params[:barber]
  

  # валидация заполнения формы

  # хеш 
  hh = { :user_name => 'Введите имя', :phone => 'Введите телефон', :date => 'Введите дату и время', :barber => 'Выберите парикмахера'}

  @error = hh.select {|key,_| params[key] == ""}.values.join(", ")

  if @error != ''
    return erb :vizit
  end 

  db = SQLite3::Database.new 'BarberShop.sqlite'
  db.execute 'INSERT INTO Users (Name, Phone, DateStamp, Barber) 
              VALUES 
              (?, ?, ?, ?)', [@user_name, @phone, @date, @barber]
  db.close 

###  # для каждой пары ключ значение
###  hh.each do |key, value|
###    
###    # если параметр пуст
###    if params[key] == ''
###
###      # переменно error присвоить value из хеша hh
###      # (а value из хеша hh это сообщение об ошибке)
###      # тоесть переменной error присвоить сообщение об ошибке
###      @error = hh[key]
###
###      # вернуть представление vizit
###      return erb :vizit
###
###      # чтобы сохранить уже введнные значения в полях, в тегах инпут присваиваем value = "<%=@имя переменной %>"
###
###    end  
###  end

  erb "#{@user_name} вы записались к парикмахеру #{@barber} на стрижку в #{@date}"

end 


#  Обращение к базе данных

#db = SQLite3::Database.new 'Cars.sqlite'

#  Записываем в базу данных
#db.execute "INSERT INTO Cars (Name, Price) VALUES ('Audi', 12000)"

#  Чтение всей таблицы с выводом на экран
#db.execute "SELECT * FROM Cars" do |car|
#
#  puts car
#  puts "======="
#
#end  
#
#db.close



