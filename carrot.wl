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

class Carrot : Entity {
    static GLMesh mesh
    static GLTexture texture

    bool dead
    
    bool isDead() return .dead
    vec4 getScale() return vec4(1, 1, 1, 1)
    float nummies() return 0.15
    GLMesh getMesh() return mesh
    GLTexture getTexture() return texture
    vec4 getExtents() return vec4(0.4, 0.60, 1.80, 0)

    this() {
        .qrotation = vec4.createQuaternion(0.1, vec4(0, 1, 0, 0))

        if(!mesh) {
            Mesh m = loadMdl(new StringFile(pack "res/carrot.mdl"))
            .mesh = new GLMesh(m)
        }

        if(!texture) {
            Image i = loadTGA(new StringFile(pack "res/carrot.tga"))
            .texture = new GLTexture(i)
        }
        .rotation = randomFloat() * 6 // 6 = 2PI (close enough)
        .position.v[0] = randomFloat() * 18.0f - 9.0f
        .position.v[2] = randomFloat() * 18.0f - 9.0f
    }

    void update(float dt) {
        DuckMan d = DuckMan.getInstance()
        OBox3 dhit = d.getHitbox()
        if(dhit.collides(.getHitbox())) {
            if(d.scale * 2.2 > 1.5)  {
                d.eat(this)
                .dead = true
            } else {
            }
        }
    }
}

void initCarrots() {
    for(int i = 0; i < 3; i++) {
        (Entity.add(new Carrot()))
    }
}
