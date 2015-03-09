import "libwl/vec.wl"
import "libwl/gl.wl"
import "libwl/collision.wl"
import "collider.wl"
import "drawDevice.wl"

class Entity {
    GLMesh someMesh
    GLTexture someTexture
    Collider collider

    vec4 position
    vec4 qrotation
    vec4 scale
    float rotation

    static Entity first

    Entity next
    weak Entity prev

    static void setFirst(Entity e) first = e
    static Entity getFirst() return first
    bool isDead() return false
    bool isSpecial() return false

    this() {
        .qrotation = vec4(0,0,0,1)
        .scale = vec4(1, 1, 1, 1)
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

    GLMesh getMesh() return .someMesh
    GLTexture getTexture() return .someTexture 
    vec4 getScale() return .scale

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

    OBox3 getOBox(ColliderBox box) {
        vec4 scale = .getScale()
        vec4 pos = vec4(box.position[0] * scale.x() + .position.x(),
                        box.position[1] * scale.y() + .position.y(),
                        box.position[2] * scale.z() + .position.z(), 1)
        vec4 rad = vec4(box.dimension[0] * scale.x(), box.dimension[1] * scale.y(),
                        box.dimension[2] * scale.z(), 0)
        vec4 quat = vec4(box.rotation[0],
                         box.rotation[1],
                         box.rotation[2],
                         1 - (box.rotation[0] + box.rotation[1] + box.rotation[2]))
        mat4 rot = quat.toMatrix()
        return OBox3(pos, rad, rot)
    }

    bool collides(Entity o) {
        if(!.collider or !o.collider) return false

        vec4 scale1 = .getScale()
        vec4 scale2 = o.getScale()
        float radiusSum = .collider.boundingRadius * scale1.len() + o.collider.boundingRadius * scale2.len()
        vec4 diff = .position.sub(o.position)
        float distSq = diff.lensq()

        // if bounding ball around objects do not intersect,
        // none of the bounding boxes intersect
        if(distSq > radiusSum * radiusSum) return false

        // check each bounding box against each other
        ColliderBounds bounds1 = .collider.first
        while(bounds1) {
            OBox3 box1 = .getOBox(bounds1.asBox())
            ColliderBounds bounds2 = o.collider.first
            while(bounds2) {
                OBox3 box2 = o.getOBox(bounds2.asBox())
                if(box1.collides(box2)) {
                    return true
                }
                bounds2 = bounds2.next
            }
            bounds1 = bounds1.next
        }
        return false
    }

    void draw(mat4 view) {
        GLDrawDevice dev = GLDrawDevice.getInstance()

        mat4 mat = mat4()
        mat4 qmat = .qrotation.toMatrix()
        vec4 axis = vec4(0, 1, 0, 0)
        //mat = mat.scale(scale, scale, scale)
        vec4 scale = .getScale()
        mat = mat.scale(scale.x(), scale.y(), scale.z())
        mat = qmat.mul(mat)
        mat = mat.translate(.position)
        mat = view.mul(mat)

        dev.runMeshProgram(.getMesh(), .getTexture(), mat)

        //if(dev.drawHitbox) dev.drawOBoundingBox(.getHitbox(), view)
        if(.collider) {
            ColliderBounds bounds = .collider.first
            while(bounds) {
                OBox3 box = .getOBox(bounds.asBox())
                dev.drawOBoundingBox(box, view)
                bounds = bounds.next
            }
        }
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

void drawNormalEntities(mat4 view) {
    Entity e = Entity.first
    while(e) {
        if(!e.isSpecial()) e.draw(view)
        e = e.next
    }
}

void drawSpecialEntities(mat4 view) {
    Entity e = Entity.first
    while(e) {
        if(e.isSpecial()) e.draw(view)
        e = e.next
    }
}
