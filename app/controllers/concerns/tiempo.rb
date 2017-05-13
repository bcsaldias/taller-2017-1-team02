
module Tiempo

  def self.tiempo_a_milisegundos(mes, dia, hora, minutos)
  	tiempo = Time.new(2017, mes, dia, hora, minutos, 0) #=> 2002-10-31 02:02:02 +0200
  	milisegundos = 1000*tiempo.to_i
  	return milisegundos
  end
end