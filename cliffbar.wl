import "entity.wl"
import "libwl/gl.wl"
import "drawDevice.wl"
import "libwl/mesh.wl"
import "libwl/image.wl"
import "libwl/fmt/tga.wl"
import "libwl/fmt/mdl.wl"
import "libwl/vec.wl"
import "libwl/file.wl"
import "libwl/random.wl"
import "libwl/collision.wl"

import "man.wl"

use "importc"
import(C) "math.h"

class Cliffbar : Entity {
    static GLMesh mesh
    static GLTexture texture

    bool dead
    
    bool isDead() return .dead

    float yummyNummies() return 10.0f
    float nummies() return 0.1

    vec4 getScale() return vec4(1, 1, 1, 1)

    this() {
        .qrotation = vec4(0,0,0,1)

        if(!mesh) {
            Mesh m = loadMdl(new StringFile(pack "res/cliffbar.mdl"))
            .mesh = new GLMesh(m)
        }

        if(!texture) {
            Image i = loadTGA(new StringFile(pack "res/cliffbar.tga"))
            .texture = new GLTexture(i)
        }
        .rotation = randomFloat() * 6 // 6 = 2PI (close enough)
        .position.v[0] = randomFloat() * 18.0f - 9.0f
        .position.v[2] = randomFloat() * 18.0f - 9.0f
    }

    void update(float dt) {
        DuckMan d = DuckMan.getInstance()
        OBox3 dhit = d.getHitbox()
        if(dhit.collides(.getHitbox()) and d.scale > 0.4) {
            d.eat(this)
            .dead = true
        }
        .rotation += 0.1
        .qrotation = vec4.createQuaternion(.rotation, vec4(0,1,0,0))
        .position.v[1] = (sin(.rotation) / 2.0f + 0.5) / 10.0f
    }

    vec4 getExtents() return vec4(0.5, 0.5, 0.5, 0)

    GLMesh getMesh() return mesh
    GLTexture getTexture() return texture
}

void initCliffbars() {
    for(int i = 0; i < 2; i++) {
        (Entity.add(new Cliffbar()))
    }
}
