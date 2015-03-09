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

class Crumb : Entity {
    static GLMesh mesh
    static GLTexture texture

    bool dead
    
    bool isDead() return .dead
    float nummies() return 0.005
    bool isSpecial() return true

    this() {
        .qrotation = vec4(0,0,0,1)

        if(!mesh) {
            Mesh m = loadMdl(new StringFile(pack "res/crumb.mdl"))
            .mesh = new GLMesh(m)
        }

        if(!texture) {
            Image i = loadTGA(new StringFile(pack "res/crumb.tga"))
            .texture = new GLTexture(i)
        }
        .rotation = randomFloat() * 6 // 6 = 2PI (close enough)
        .position.v[0] = randomFloat() * 18.0f - 9.0f
        .position.v[2] = randomFloat() * 18.0f - 9.0f
    }

    vec4 getScale() return vec4(1, 1, 1, 1)

    void update(float dt) {
        DuckMan d = DuckMan.getInstance()
        OBox3 dhit = d.getHitbox()
        if(dhit.collides(.getHitbox())) {
            d.eat(this)
            .dead = true
        }
        .rotation += 0.1
        .position.v[1] = (sin(.rotation) / 2.0f + 0.5) / 10.0f
    }

    vec4 getExtents() return vec4(0.2, 0.2, 0.2, 0)

    GLMesh getMesh() return mesh
    GLTexture getTexture() return texture
}

void initCrumbs() {
    for(int i = 0; i < 40; i++) {
        (Entity.add(new Crumb()))
    }
}
