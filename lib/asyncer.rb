class Asyncer
  @@mutex = Mutex.new
  @@queue = Queue.new
  @@thread = nil

  def self.exec(&blk)
    start if !@@thread&.alive?
    @@queue << blk
  end

  def self.start
    @@mutex.synchronize do
      if !@@thread&.alive?
        @@thread = Thread.new { listen }
      end
    end
  end

  def self.listen
    while true
      blk = @@queue.pop
      blk.call
    end
  end
end
