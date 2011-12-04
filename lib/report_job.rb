require "eventmachine"

class ReportJob


  def intialize(interval = 20)
    @interval = interval
  end


  def start
    EventMachine::run {
      EventMachine::add_periodic_timer(@interval) { puts "Hello !" }
    }

  end


end