
module Tiempo

  def self.tiempo_a_milisegundos(mes, dia, hora, minutos, ano = 2017)
  	tiempo = Time.new(ano, mes, dia, hora, minutos, 0) #=> 2002-10-31 02:02:02 +0200
    # to_i retorna milisegs desde 1970 utc=0 independiente del Timezone local
    milisegundos = 1000*tiempo.to_i
  	return milisegundos
  end

  # Detiene el proceso por cierta cantidad de segundos cuando req_actual > req_max
  def self.sleep_if_to_many_requests(req_actual, req_max, sleep_time = 15)
    if req_actual > req_max
      sleep(sleep_time)
    end
    return 0
  end

  # Returns true if numbers are very similar
  def small_difference?(n1, n2)
    (n1-n2).abs < 1
  end

end
