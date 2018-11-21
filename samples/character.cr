require "../src/prism"

abstract class Character < GameObject
    @max_health : Int32
    @health : Int32

    getter health, max_health

    def initialize(position : Vector3f, @max_health : Int32)
        super()
        @health = @max_health
        self.transform.pos = position
    end

    # Raises/Lowers the maximum health of the object
    def raise_max_health(@max_health : Int32)
    end

    # Restore's the object's health to maximum
    def restore_health!
        @health = @max_health
    end

    # Checks if the object has no health
    def dead?
        @health <= 0
    end

    # Takes damage
    def damage!(by : Int32)
        @health -= by.abs
    end

    # Regains health
    def heal!(by : Int32)
        @health += by
        if @health > @max_health
            @health = @max_health
        end
    end
end