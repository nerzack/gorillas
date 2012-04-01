class Building
  constructor:(context) ->
    @context = context
    @width = 90 + Math.floor(Math.random()*40)
    @base_height = 100
    @randomize_color()

  position_at_x:() ->
    return @x

  position_at_y:() ->
    return  640-@height

  end_position:() ->
    return @position_at_x()+@width

  draw:(@x, @y) ->
    @context.fillStyle = @color
    @height = @base_height + y
    @context.fillRect @position_at_x(), @position_at_y(), @width, @height
    @build_windows(@position_at_x(), @position_at_y())

  build_windows:(x, y) ->
    times = Math.round (@height)/31
    window_positions = [ 10, 25, 40, 55, 70, 85 ]
    current_distance = 30
    total_height = 30
    row = 1
    loop
      break if times < row
      @create_window x+position, 620+total_height-@height for position in window_positions
      total_height += current_distance
      row++

  create_window:(x, y) ->
    @randomize_window_color()
    @context.fillStyle = @color
    @context.fillRect x, y, 8, 16

  randomize_color:() ->
    colors = [ '#C0C0C0', '#800000', '#00FFFF' ]
    random = Math.floor(Math.random()*colors.length)
    @color = colors[random]

  randomize_window_color:() ->
    colors = [ '#808080', '#FFFF00' ]
    random = Math.floor(Math.random()*5)
    @color = if random > 0 then colors[1] else colors[random]

class Sun
  constructor:(context) ->
    @mouth = true
    @context = context
    @color = '#FFFF00'
    @width = 40
    @y = 100

  position: ->
    1024/2

  draw:() ->
    @draw_circle()
    @rays()
    @eyes()
    @smile()

  draw_circle:() ->
    @context.fillStyle = @color
    @context.beginPath()
    @context.arc @position(), @y, @width, 0, Math.PI*2, true
    @context.closePath()
    @context.fill()

  eyes:() ->
    @context.fillStyle = '#000000'
    @context.beginPath()
    @context.arc @position()-10, @y-10, 5, 0, Math.PI*2,  true
    @context.arc @position()+10, @y-10, 5, 0, Math.PI*2,  true
    @context.fill()

  smile:() ->
    @context.strokeStyle = '#000000'
    @context.beginPath()
    @context.arc @position(), @y+20, @width/4, 0, Math.PI,  false
    @context.stroke()

  rays:() ->
    @context.strokeStyle = @color
    @context.beginPath()
    @context.lineWidth = 1
    @draw_ray(360*z/36) for z in [0...50]
    @context.stroke()

  draw_ray:(a) ->
    @context.moveTo @position(), @y
    coords = @coordinates(@position(), @y, 65, a)
    @context.lineTo coords.x, coords.y

  coordinates:(x, y, d, a) ->
    x: x + d * Math.cos(a),
    y: y + d * Math.sin(a)

class Painter
  constructor: ->
    @canvas = document.getElementById "gorillas"
    @context = @canvas.getContext "2d"
    @color = '#00FFFF'
    @padding = 1
    @buildings = []

  draw_buildings:()->
    position = 0
    for [1...10]
      building = @draw_building(position)
      position = building.end_position() + @padding

  draw_building:(x) ->
    building = new Building(@context)

    y = Math.floor(Math.random()*300)
    building.draw(x, y)
    @buildings.push building
    return building

  draw_the_sun: ->
    sun = new Sun(@context)
    sun.draw()

  set_color:(color) ->
    @color = color

  draw_gorillas: ->
    building = @buildings[Math.floor(Math.random()*3)]
    @player_1 = new Gorilla(@context)
    @player_1.draw(building.position_at_x(), building.position_at_y())
    building = @buildings[Math.floor(Math.random()*6)+3]
    @player_2 = new Gorilla(@context)
    @player_2.draw(building.position_at_x(), building.position_at_y())

  throw_banana:(force, angle, player) ->
    if player == 2
      angle = -angle
      force = -force if player == 2
    this['player_' + player].throw_banana(force, angle)

class Gorilla
  constructor:(@context) ->
    @context = context

  image: ->
    image = new Image()
    image.src = 'images/gorilla.png'
    image

  draw:(x, y) ->
    @x = x+30
    @y = y-40
    @context.drawImage(@image(), @x, @y, 40, 40)

  throw_banana:(force, angle) ->
    banana = new Banana(@context, @x+30, @y-30)
    banana.throw(force, angle)

class Banana
  constructor:(context, initial_x, initial_y) ->
    @context = context
    @initx = initial_x
    @inity = initial_y
    @x = 0
    @y = 0
    @g = 9.8

  throw:(force, angle) ->
    @force = force
    @angle = angle
    @calculate_initial_position()

    setTimeout (=> @draw_frame()), 150

  draw: ->
    @context.drawImage @image(), @initx+@x, @inity-@y

  draw_frame: ->
    @draw()
    @calculate_projection()

    setTimeout (=> @draw_frame()), 150

  calculate_initial_position: ->
    radian = @angle*Math.PI/180
    @dx = @force/Math.cos(radian)
    @dy = @force/Math.sin(radian)

  calculate_projection:() ->
    @x += @dx
    @dy -= @g
    @y += @dy

  image:() ->
    image = new Image()
    image.src = 'images/banana.png'
    return image


window.onload = ->
  @painter = new Painter
  @painter.draw_the_sun()
  @painter.draw_buildings()

  @painter.draw_gorillas()
  @painter.throw_banana(30, 45, 1)
