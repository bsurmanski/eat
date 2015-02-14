import "libwl/vec.wl"

undecorated double fabs(double x);

float box_dim_mtd(float apos, float adim, float bpos, float bdim) {
    float d1 = apos - (bpos + bdim / 2.0f) //dist of A's left point to B center
    float d2 = (apos + adim) - (bpos + bdim / 2.0f) // dist of A's right point to B center
    if(fabs(d1) > fabs(d2)) {
        return (bpos + bdim) - apos
    }
    //else
    return bpos - (apos + adim)
}

float box_dim_overlap(float apos, float adim, float bpos, float bdim) {
    return fabs(apos - bpos) < (adim + bdim);
}

struct Box2 {
    float[2] pos
    float[2] dim

    /*
    this(float[2] p, float[2] d) {
        .pos = p
        .dim = d
    }*/

    this(vec4 p, vec4 d) {
        .pos[0] = p.v[0] - d.v[0] / 2.0f
        .pos[1] = p.v[1] - d.v[1] / 2.0f

        .dim[0] = d.v[0]
        .dim[1] = d.v[1]
    }

    void setPosition(float[2] p)
        .pos = p

    void setDimension(float[2] d)
        .dim = d

    void setCenter(float[2] c) {
        for(int i = 0; i < 2; i++) {
            .pos[i] = c[i] - .dim[i] / 2.0f
        }
    }
    vec4 getCenter() {
        return vec4(.pos[0] + .dim[0] / 2.0f,
                    .pos[1] + .dim[1] / 2.0f,
                    0, 0)
    }

    void move(float[2] dv) {
        for(int i = 0; i < 2; i++) {
            .pos[i] += dv[i]
        }
    }

    bool collides(Box2 o) {
        for(int i = 0; i < 2; i++) {
            if(!box_dim_overlap(.pos[i], .dim[i], o.pos[i], o.dim[i]))
                return false
        }

        // all dimensions overlap, therefore, they collide
        return true
    }

    vec4 minTranslation(Box2 o) {
        vec4 ret
        for(int i = 0; i < 2; i++) {
            ret.v[i] = box_dim_mtd(.pos[i], .dim[i], o.pos[i], o.dim[i])
        }
        return ret
    }
}

struct Box3 {
    float[3] pos // center position 
    float[3] rad // half width

    /*
    this(float[3] p, float[3] d) {
        .pos = p
        .rad = d
    }*/

    this(vec4 p, vec4 d) {
        .pos = [p.v[0], p.v[1], p.v[2]]
        .rad = [d.v[0]/2.0f, d.v[1]/2.0f, d.v[2]/2.0f]
    }

    void setPosition(float[3] p)
        .pos = p

    void setDimension(float[3] d)
        .rad = d

    vec4 getCenter() return vec4(.pos[0], .pos[1], .pos[2], 0)

    void setCenter(float[3] c) {
        .pos = c
    }

    void move(float[3] dv) {
        for(int i = 0; i < 3; i++) {
            .pos[i] += dv[i]
        }
    }

    bool collides(Box3 o) {
        for(int i = 0; i < 3; i++) {
            if(!box_dim_overlap(.pos[i], .rad[i], o.pos[i], o.rad[i]))
                return false
        }

        // all dimensions overlap, therefore, they collide
        return true
    }

    vec4 minTranslation(Box3 o) {
        vec4 ret
        for(int i = 0; i < 3; i++) {
            ret.v[i] = box_dim_mtd(.pos[i], .rad[i], o.pos[i], o.rad[i])
        }
        return ret
    }
}

struct OBox3 {
    float[3] pos // center position 
    float[3] rad // half width
    mat4 matrix

    vec4 getCenter() return vec4(.pos[0], .pos[1], .pos[2], 0)

    this(vec4 p, vec4 r, mat4 m) {
        .pos = [p.x(), p.y(), p.z()]
        .rad = [r.x() / 2.0f, r.y() / 2.0f, r.z() / 2.0f]
        .matrix = m
    }

    // check a single axis
    bool isSeperatingAxis(OBox3 o, vec4 axis, vec4 diff) {
        float EPSILON = 0.00005 //close enough
        axis.v[0] += EPSILON
        axis.v[1] += EPSILON
        axis.v[2] += EPSILON
        axis = axis.normalized()
        float ra = axis.dot(.matrix.x()) * .rad[0] + axis.dot(.matrix.y()) * .rad[1] + axis.dot(.matrix.z()) * .rad[2]
        float rb = axis.dot(o.matrix.x()) * o.rad[0] + axis.dot(o.matrix.y()) * o.rad[1] + axis.dot(o.matrix.z()) * o.rad[2]
        return fabs(diff.dot(axis)) > fabs(ra) + fabs(rb)
    }

    bool collides(OBox3 o) {
        // use seperating axis theorem to check 15 axes for seperation

        vec4 diff = vec4(.pos[0] - o.pos[0], .pos[1] - o.pos[1], .pos[2] - o.pos[2], 0)
        vec4 tmp
        vec4 axis
        float ra
        float rb

        // this' axes
        axis = .matrix.x()
        ra = .rad[0]
        rb = axis.dot(o.matrix.x()) * o.rad[0] + axis.dot(o.matrix.y()) * o.rad[1] + axis.dot(o.matrix.z()) * o.rad[2]
        if(fabs(diff.dot(axis)) > ra + fabs(rb)) return false

        axis = .matrix.y()
        ra = .rad[1]
        rb = axis.dot(o.matrix.x()) * o.rad[0] + axis.dot(o.matrix.y()) * o.rad[1] + axis.dot(o.matrix.z()) * o.rad[2]
        if(fabs(diff.dot(axis)) > ra + fabs(rb)) return false

        axis = .matrix.z()
        ra = .rad[2]
        rb = axis.dot(o.matrix.x()) * o.rad[0] + axis.dot(o.matrix.y()) * o.rad[1] + axis.dot(o.matrix.z()) * o.rad[2]
        if(fabs(diff.dot(axis)) > ra + fabs(rb)) return false

        // o's axes
        axis = o.matrix.x()
        ra = o.rad[0]
        rb = axis.dot(.matrix.x()) * .rad[0] + axis.dot(.matrix.y()) * .rad[1] + axis.dot(.matrix.z()) * .rad[2]
        if(fabs(diff.dot(axis)) > ra + fabs(rb)) return false

        axis = o.matrix.y()
        ra = o.rad[1]
        rb = axis.dot(.matrix.x()) * .rad[0] + axis.dot(.matrix.y()) * .rad[1] + axis.dot(.matrix.z()) * .rad[2]
        if(fabs(diff.dot(axis)) > ra + fabs(rb)) return false

        axis = o.matrix.z()
        ra = o.rad[2]
        rb = axis.dot(.matrix.x()) * .rad[0] + axis.dot(.matrix.y()) * .rad[1] + axis.dot(.matrix.z()) * .rad[2]
        if(fabs(diff.dot(axis)) > ra + fabs(rb)) return false

        //edge axes
        tmp = .matrix.x()
        axis = tmp.cross(o.matrix.x())
        if(.isSeperatingAxis(o, axis, diff)) return false
        
        tmp = .matrix.y()
        axis = tmp.cross(o.matrix.x())
        if(.isSeperatingAxis(o, axis, diff)) return false

        tmp = .matrix.z()
        axis = tmp.cross(o.matrix.x())
        if(.isSeperatingAxis(o, axis, diff)) return false

        tmp = .matrix.x()
        axis = tmp.cross(o.matrix.y())
        if(.isSeperatingAxis(o, axis, diff)) return false

        tmp = .matrix.y()
        axis = tmp.cross(o.matrix.y())
        if(.isSeperatingAxis(o, axis, diff)) return false

        tmp = .matrix.z()
        axis = tmp.cross(o.matrix.y())
        if(.isSeperatingAxis(o, axis, diff)) return false

        tmp = .matrix.x()
        axis = tmp.cross(o.matrix.z())
        if(.isSeperatingAxis(o, axis, diff)) return false

        tmp = .matrix.y()
        axis = tmp.cross(o.matrix.z())
        if(.isSeperatingAxis(o, axis, diff)) return false

        tmp = .matrix.z()
        axis = tmp.cross(o.matrix.z())
        if(.isSeperatingAxis(o, axis, diff)) return false

        // no seperating axis found
        return true
    }
}

struct Ball2 {
    float[2] center
    float radius

    this(float[2] c, float r) {
        .center = c
        .radius = r
    }

    bool collides(Ball2 o) {
        vec4 c1 = vec4(.center[0], .center[1], 0, 0)        
        vec4 c2 = vec4(o.center[0], o.center[2], 0, 0)
        vec4 diff = c1.sub(c2)
        float rdsq = (.radius + o.radius) * (.radius + o.radius)
        return rdsq > diff.lensq()
    }

    void scale(float f)
        .radius *= f

    void setCenter(float[2] c)
        .center = c

    void setRadius(float r)
        .radius = r
}

struct Ball3 {
    float[3] center
    float radius

    this(float[3] c, float r) {
        .center = c
        .radius = r
    }

    bool collides(Ball3 o) {
        vec4 c1 = vec4(.center[0], .center[1], .center[2], 0)        
        vec4 c2 = vec4(o.center[0], o.center[2], o.center[3], 0)
        vec4 diff = c1.sub(c2)
        float rdsq = (.radius * .radius) + (o.radius * o.radius)
        return rdsq > diff.lensq()
    }

    void scale(float f)
        .radius *= f

    void setCenter(float[3] c)
        .center = c

    void setRadius(float r)
        .radius = r
}

struct Pill3 {
    float[3] position // center position of pill
    float radius // radius of cylinder and spheres
    float height // half of the pill height. from center to cylinder top

    this(vec4 p, float r, float h) {
        .position = [p.v[0], p.v[1], p.v[2]]
        .radius = r
        .height = h / 2.0f
    }

    vec4 getCenter() 
        return vec4(.position[0], .position[1], .position[2], 0)

    bool collides(Pill3 o) {
        vec4 c1 = .getCenter()
        vec4 c2 = o.getCenter()

        vec4 diff = c1.sub(c2)
        float distsq = diff.lensq()
        if(fabs(c1.v[1] - c2.v[1]) < .height + o.height) {
            // if pills are side by side, see if sides are hitting
            return distsq < 
                   (.radius * .radius) + (o.radius * o.radius)
        } else if(c1.v[1] > c2.v[1]) {
            // else if c1 is on top of c2
            return ((c1.v[1] - .height) - (c2.v[1] + o.height)) <
                     .radius + o.radius
        } else {
            // else if c2 is on top of c1
            return ((c2.v[1] - o.height) - (c1.v[1] + .height)) <
                     .radius + o.radius
        }

        return false
    }
}
