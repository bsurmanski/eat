import "libwl/file.wl"

undecorated int printf(char^ fmt, ...);

class Collider {
    //XXX linked list of physics object
    float boundingRadius
    ColliderBounds first

    this(float boundingRadius) {
        .boundingRadius = boundingRadius
    }

    ~this() {
        .first = null
    }

    void add(ColliderBounds phy) {
        phy.next = .first
        .first = phy
    }
}

const int PHY_SPHERE = 0
const int PHY_CAPSULE = 1
const int PHY_BOX = 2

class ColliderBounds {
    ColliderBounds next
    float[3] position 

    ~this() {
        .next = null
    }

    bool isSphere() return false
    bool isBox() return false
    ColliderBox asBox() return null
    ColliderSphere asSphere() return null
}

class ColliderBox : ColliderBounds {
    float[3] dimension
    float[3] rotation
    ColliderBox asBox() return this

    this(float[3] pos, float[3] dim, float[3] rot) {
        .position = pos
        .dimension = dim
        .rotation = rot
    }

}

class ColliderSphere : ColliderBounds {
    float radius
    ColliderSphere asSphere() return this
    this(float[3] pos, float radius) {
        .position = pos
        .radius = radius
    }
}

struct PHYHeader {
    char[3] magic
    uint8 version
    uint16 nspheres
    uint16 ncapsules
    uint16 nboxes
    char[2] padding
    float boundingRadius
    char[16] name
}

struct PHYSphere {
    float[3] position
    float radius
}

struct PHYBox {
    float[3] position
    float[3] dimension
    float[3] rotation
}

Collider loadCollider(InputInterface file) {

    PHYHeader head
    file.read(&head, PHYHeader.sizeof, 1)
    if(head.magic[0] != 'P' or
        head.magic[1] != 'H' or
        head.magic[2] != 'Y') {
        printf("ERROR: invalid PHY format\n")
    }

    Collider physics = new Collider(head.boundingRadius)

    for(int i = 0; i < head.nspheres; i++) {
        PHYSphere sphere
        file.read(&sphere, PHYSphere.sizeof, 1)
        ColliderSphere psphere = new ColliderSphere(sphere.position, sphere.radius)
        physics.add(psphere)
    }

    for(int i = 0; i < head.ncapsules; i++) {
        //XXX
    }

    for(int i = 0; i < head.nboxes; i++) {
        PHYBox box
        file.read(&box, PHYBox.sizeof, 1)
        ColliderBox pbox = new ColliderBox(box.position, box.dimension, box.rotation)
        physics.add(pbox)
    }

    return physics
}
