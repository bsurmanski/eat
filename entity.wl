import "libwl/vec.wl"
import "libwl/gl.wl"
import "libwl/collision.wl"
import "drawDevice.wl"

class Entity {
    vec4 position
    vec4 qrotation
    float rotation

    static Entity first

    Entity next
    weak Entity prev

    static void setFirst(Entity e) first = e
    static Entity getFirst() return first
    bool isDead() return false

    this() {
        .qrotation = vec4(0,0,0,1)
    }

    static void add(Entity e) {
        if(!first) {
            first = e
        } else {
            first.prev = e
            e.next = first
            first = e
        }
    }

    static void removeAll() {
        // ideally the refcounters would handle deleting all these
        first.next = null
        first = null
    }

    float nummies() return 0.01f
    float yummyNummies() return 0.0f
    bool areYouCookie() return false

    void update(float dt) {
    }

    GLMesh getMesh() return null
    GLTexture getTexture() return null
    float getScale() return 1.0f

    vec4 getExtents() {
        return vec4(1, 1, 1, 0)
    }

    OBox3 getHitbox() {
        mat4 rot = .qrotation.toMatrix()
        return OBox3(.position, .getExtents(), rot)
    }

    OBox3 getOHitbox() {
        return OBox3(.position, .getExtents(), mat4())
    }

    void draw(mat4 view) {
        GLDrawDevice dev = GLDrawDevice.getInstance()

        float scale = .getScale()

        mat4 mat = mat4()
        mat4 qmat = .qrotation.toMatrix()
        vec4 axis = vec4(0, 1, 0, 0)
        //mat = mat.rotate(.rotation, axis)
        mat = mat.scale(scale, scale, scale)
        mat = qmat.mul(mat)
        mat = mat.translate(.position)
        mat = view.mul(mat)

        dev.runMeshProgram(.getMesh(), .getTexture(), mat)


        if(dev.drawHitbox) dev.drawOBoundingBox(.getHitbox(), view)
    }
}

void updateEntities(float dt) {
    Entity e = Entity.first
    while(e) {
        e.update(dt)
        if(e.isDead()) {
            Entity del = e
            if(e.prev) e.prev.next = e.next
            if(e.next) e.next.prev = e.prev
            if(e == Entity.first) Entity.first = e.next
            e = e.next
            delete del
            continue
        }
        e = e.next
    }
}

void drawEntities(mat4 view) {
    Entity e = Entity.first
    while(e) {
        e.draw(view)
        e = e.next
    }
}
