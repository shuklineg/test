require_relative 'libs/train.rb'
require_relative 'libs/passenger_train.rb'
require_relative 'libs/cargo_train.rb'
require_relative 'libs/car.rb'
require_relative 'libs/passenger_car.rb'
require_relative 'libs/cargo_car.rb'
require_relative 'libs/station.rb'
require_relative 'libs/route.rb'

require_relative 'libs/ui/menu'

class App
  include Menu

  attr_reader :stations, :routes, :trains

  def initialize
    @stations = []
    @routes = []
    @trains = []
  end

  def run
    show_menu(MAIN_MENU, 'Главное меню')
  end

  def stations_menu
    show_menu(STATIONS_MENU, 'Меню станций')
  end

  def routes_menu
    show_menu(ROUTES_MENU, 'Меню маршрутов')
  end

  def trains_menu
    show_menu(TRAINS_MENU, 'Меню Поездов')
  end

  def list_stations
    print_list('Список станций', @stations)
  end

  def list_station_trains
    return if message_if('Нет станций', @stations.empty?)

    station = select_from_list('Введите номер станции', @stations)
    print_list("Cписок поездов на станции #{station.name}", station.trains)
  end

  def add_station
    station_name = get_answer('Введите название станции')

    @stations << Station.new(station_name)
  end

  def list_routes
    print_list('Список маршрутов', @routes)
  end

  def add_route
    return if message_if('Станций слишком мало', @stations.size < 2)

    title_elm('Создание маршрута')
    starting_station = select_from_list('Введите номер станции начала маршрута', @stations)
    ending_stations = @stations - [starting_station]
    end_station = select_from_list('Введите номер станции конца маршрута', ending_stations)

    @routes << Route.new(starting_station, end_station)
  end

  def add_station_to_route
    route = select_from_list('Введите номер маршрута для редактирования', @routes)
    stations = @stations - route.schedule
    return if message_if('Нет доступных станций', stations.empty?)

    station = select_from_list('Введите номер станции', stations)
    route.add_station(station)
  end

  def remove_station_from_route
    route = select_from_list('Введите номер маршрута для редактирования', @routes)
    stations = route.stops
    return if message_if('В маршруте нет станций', stations.empty?)

    station = select_from_list('Введите номер станции', stations)
    return unless yes_no("Удалить станцию #{station.name}?", false)

    station.trains.each { |train| train.move_forward if train.route == route }
    route.remove_station(station)
  end

  def list_trains
    print_list('Список маршрутов', @trains)
  end

  def add_train
    train_number = get_answer('Введите номер поезда').to_i

    train_types = %w[Пассажирский Грузовой]
    case select_from_list('Выберите тип поезда', train_types)
    when train_types[0]
      @trains << PassengerTrain.new(train_number)
    when train_types[1]
      @trains << CargoTrain.new(train_number)
    end
  end

  def set_route_to_train
    return if message_if('Нет маршрутов', @routes.empty?)
    return if message_if('Нет поездов', @trains.empty?)

    train = select_from_list('Выберите поезд', @trains)
    route = select_from_list('Выберите маршрут', @routes)

    train.route = route
  end

  def move_train
    return if message_if('Нет поездов', @trains.empty?)

    train = select_from_list('Выберите поезд', @trains)
    return if message_if('Поезд не находится на маршруте', train.route.nil?)

    direction = %w[Вперед Назад]
    case select_from_list('Направление движения', direction)
    when direction[0]
      train.move_forward
    when direction[1]
      train.move_backward
    end
  end

  def train_cars
    return if message_if('Нет поездов', @trains.empty?)

    train = select_from_list('Выберите поезд', @trains)

    action = ['Добавить вагон', 'Удалить вагон']
    case select_from_list('Изменить состав', action)
    when action[0]
      train.hook(CargoCar.new) if train.is_a? CargoTrain
      train.hook(PassengerCar.new) if train.is_a? PassengerTrain
    when action[1]
      car = select_from_list('Выберите вагон', train.cars)
      message_if('Нет вагонов', car.nil?)
      train.unhook(car)
    end
  end
end

App.new.run
