module Clockwork

  i = 0
  every(10.seconds, 'frequent.job') do 
    puts i
    puts "SHAKIRA"
    i += 1
  end
end