import "libwl/gl.wl"
import "drawDevice.wl"
import "entity.wl"
import "libwl/fmt/tga.wl"
import "libwl/fmt/mdl.wl"
import "libwl/mesh.wl"
import "libwl/image.wl"
import "libwl/file.wl"
import "libwl/vec.wl"
import "libwl/collision.wl"
import "content.wl"

use "importc"
import(C) "math.h"
import(C) "SDL/SDL_mixer.h"

float max(float a, float b) {
    if(a < b) return b
    return a
}

float min(float a, float b) {
    if(a > b) return b
    return a
}

class DuckMan : Entity {
    static GLMesh mesh
    static GLTexture texture
    static Mix_Chunk^ hop
    static Mix_Chunk^ munch
    bool moved
    float scale
    bool dead
    float nummyTimer

    static DuckMan instance
    static DuckMan getInstance() {
        return instance
    }

    bool isDead() return .dead

    this() {
        .qrotation = vec4(0,0,0,1)

        instance = this

        Content content = Content.getInstance()
        .texture = content.getTexture("pillduck")
        .mesh = content.getMesh("pillduck")
        .collider = content.getCollider("pillduck")
        hop = Mix_LoadWAV_RW(SDL_RWFromFile("res/hop.wav", "rb"), 1)
        munch = Mix_LoadWAV_RW(SDL_RWFromFile("res/munch.wav", "rb"), 1)
        Mix_VolumeChunk(hop, 30)
        Mix_VolumeChunk(munch, 70)

        .scale = 0.01
        .position = vec4(0, 0, 0, 1)
    }

    void reset() {
        .dead = false
        .nummyTimer = 0
        .scale = 0.1
        .position = vec4(0, 0, 0, 1)
    }

    vec4 getExtents() {
        vec4 dim = vec4(1.8, 2.5, 1.8, 0)
        return dim.mul(.scale)
    }

    vec4 getScale() return vec4(.scale, .scale, .scale, 0)

    void eat(Entity e) {
        Mix_PlayChannelTimed(-1, .munch, 0, -1)
        .scale += e.nummies()
        .nummyTimer += e.yummyNummies()

        printf("%f\n", .scale)
        //win
        if(e.areYouCookie()) {
        }
    }

    void update(float dt) {
        static float tick

        // cos is derivitive of sin; and *2 frequency since func is abs(sin)
        bool inflection = cos(tick * 20.0f) < 0.0f and cos((tick + dt) * 20.0f) > 0.0f

        tick += dt

        float targety = 0.0f
        if(.moved) {
            float jumpheight = min(2 * .scale, 0.5)
            targety = jumpheight * fabs(sin(tick * 10.0f))
        }
        .position.v[1] = (.position.v[1] + (targety - .position.v[1]) * 0.6f)
        if(inflection and .moved) {
            Mix_PlayChannelTimed(-1, .hop, 0, -1)
        }
        .moved = false

        if(.nummyTimer > 0.0f) {
            .nummyTimer -= dt
        }

        // keep the dude in the boundaries
        if(.position.v[0] > 10 - .scale/2) .position.v[0] = 10 - .scale/2
        if(.position.v[0] < -10 + .scale/2) .position.v[0] = -10 + .scale/2
        if(.position.v[2] > 10 - .scale/2) .position.v[2] = 10 - .scale/2
        if(.position.v[2] < -10 + .scale/2) .position.v[2] = -10 + .scale/2
    }

    void rotate(float f) {
        .rotation += f
        .qrotation = vec4.createQuaternion(.rotation, vec4(0, 1, 0, 0))
    }

    vec4 getDv() {
        vec4 axis = vec4(0, 1, 0, 0)
        vec4 dv = vec4(0, 0, -0.2 * sqrtf(.scale), 0)
        mat4 matrix = mat4()
        matrix = matrix.rotate(.rotation, axis)
        dv = matrix.vmul(dv)
        if(.nummyTimer > 0.0f) {
            dv = dv.mul(1.5f)
        }
        return dv
    }

    void step() {
        vec4 dv = .getDv()

        .position = .position.add(dv)
        .moved = true
    }

    void draw(mat4 view) {
        GLDrawDevice dev = GLDrawDevice.getInstance()

        vec4 scale = .getScale()

        mat4 mat = mat4()
        vec4 axis = vec4(0, 1, 0, 0)
        mat = mat.rotate(.rotation, axis)
        mat = mat.scale(scale.x(), scale.y(), scale.z())
        mat = mat.translate(.position)
        mat = view.mul(mat)

        dev.runMeshProgram(.getMesh(), .getTexture(), mat)

        if(dev.drawHitbox) dev.drawOBoundingBox(.getHitbox(), view)
    }

    GLMesh getMesh() return mesh
    GLTexture getTexture() return texture
}
