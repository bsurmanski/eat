import "entity.wl"
import "libwl/gl.wl"
import "libwl/mesh.wl"
import "libwl/image.wl"
import "libwl/fmt/tga.wl"
import "libwl/fmt/mdl.wl"
import "libwl/vec.wl"
import "libwl/file.wl"
import "libwl/random.wl"
import "libwl/collision.wl"
import "drawDevice.wl"
import "man.wl"

use "importc"
import(C) "math.h"

class Mouse : Entity {
    static const int STATE_ROTATE = 0
    static const int STATE_MOVE = 1
    static GLMesh mesh
    static GLTexture texture
    float timer
    int spin
    bool dead

    this() {
        .qrotation = vec4(0,0,0,1)

        .spin = 1
        if(!mesh) {
            Mesh m = loadMdl(new StringFile(pack "res/mouse.mdl"))
            .mesh = new GLMesh(m)
        }

        if(!texture) {
            Image i = loadTGA(new StringFile(pack "res/mouse.tga"))
            .texture = new GLTexture(i)
        }
        .rotation = randomFloat() * 6 // 6 = 2PI (close enough)

        .position.v[0] = randomFloat() * 20.0f - 10.0f
        .position.v[2] = randomFloat() * 20.0f - 10.0f
    }

    float nummies() return 0.15

    bool isDead() return .dead

    void update(float dt) {
        .timer -= dt
        if(.timer <= 0) {
            .spin = -.spin
            .timer = randomFloat() * 3
        }

        DuckMan d = DuckMan.getInstance()
        OBox3 dhit = d.getHitbox()
        if(dhit.collides(.getHitbox())) {
            if(d.scale * 2.2 > 1.6) {
                d.eat(this)
                .dead = true
            } else {
                d.dead = true
            }
        }

        .rotation += 0.15 * .spin
        vec4 dv = vec4(0, 0, 0.10, 0)

        mat4 matrix = mat4()
        matrix = matrix.rotate(.rotation, vec4(0, 1, 0, 0))
        dv = matrix.vmul(dv)

        if(.position.v[0] < -9.0f || .position.v[0] > 9.0f ||
            .position.v[2] < -9.0f || .position.v[2] > 9.0f) {
            if(dv.dot(.position) > 0) {
                .timer /= 2.0f
                .rotation = .rotation - 3.1415926;

                return
            }
        }

        .qrotation = vec4.createQuaternion(.rotation, vec4(0,1,0,0))

        .position = .position.add(dv)
    }

    vec4 getExtents() return vec4(1, 1, 1, 0)

    GLMesh getMesh() return mesh
    GLTexture getTexture() return texture
}

void initMice() {
    for(int i = 0; i < 2; i++) {
        (Entity.add(new Mouse()))
    }
}
