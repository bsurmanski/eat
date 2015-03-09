import "entity.wl"
import "man.wl"
import "libwl/vec.wl"

class Prop : Entity {
    bool dead

    this() {
        .qrotation = vec4(0,0,0,1)
    }

    void update(float dt) {
        DuckMan man = DuckMan.getInstance()
        if(.collides(man)) {
            man.position = man.position.sub(man.getDv())
            printf("WOW\n")
        }
    }

    bool isDead() return .dead
}
