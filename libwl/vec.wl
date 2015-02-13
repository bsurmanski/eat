use "importc"
import(C) "math.h"

undecorated int printf(char^ fmt, ...);

struct vec4 {
    float[4] v

    this(float x, float y, float z, float w) {
        .v = [x, y, z, w]
    }

    /*
    this(vec4 o) {
        .v = [o.x(), o.y(), o.z(), o.w()]
    }*/

    static vec4 createQuaternion(float angle, vec4 axis) {
        vec4 ret
        float scale = sin(angle / 2.0f);
        ret.v[0] = axis.x() * scale;
        ret.v[1] = axis.y() * scale;
        ret.v[2] = axis.z() * scale;
        ret.v[3] = cos(angle / 2.0f);
        return ret
    }

    float get(int i) return .v[i]
    void set(int i, float val) .v[i] = val
    float x() return .v[0]
    float y() return .v[1]
    float z() return .v[2]
    float w() return .v[3]

    float dot(vec4 o) return .x() * o.x() + .y() * o.y() + .z() * o.z() + .w() * o.w()
    vec4 add(vec4 o) return vec4(.x() + o.x(), .y() + o.y(), .z() + o.z(), .w() + o.w());
    vec4 sub(vec4 o) return vec4(.x() - o.x(), .y() - o.y(), .z() - o.z(), .w() - o.w());
    vec4 mul(float f) return vec4(.x() * f, .y() * f, .z() * f, .w() * f);
    vec4 div(float f) return vec4(.x() / f, .y() / f, .z() / f, .w() / f);
    float lensq() return .x() * .x() + .y() * .y() + .z() * .z() + .w() * .w()
    float len() return sqrt(.lensq())
    vec4 normalized() return .div(.len())

    vec4 cross(vec4 o) {
        vec4 ret;
        ret.v[0] = .y() * o.z() - .z() * o.y()
        ret.v[1] = .z() * o.x() - .x() * o.z()
        ret.v[2] = .x() * o.y() - .y() * o.x()
        ret.v[3] = 0
        return ret
    }

    vec4 proj(vec4 o) {
        float numer = .dot(o) // length sq
        float denom = o.dot(o)
        return .mul(numer / denom)
    }

    vec4 orth(vec4 o) {
        vec4 r = .proj(o)
        return .sub(r)
    }

    vec4 conjugate() {
        return vec4(-.x(), -.y(), -.z(), .w())
    }

    vec4 inverse() {
        float inv_norm = 1.0f / .lensq()
        return vec4(-.x() * inv_norm, -.y() * inv_norm, -.z() * inv_norm, .w() * inv_norm)
    }

    vec4 real() {
        return vec4(0, 0, 0, .w())
    }

    vec4 imaginary() {
        return vec4(.x(), .y(), .z(), 0)
    }

    vec4 quaternion_rotate(float angle, vec4 axis) {
    }

    // quaternion multiply
    vec4 qmul(vec4 o) {
        return vec4(.w() * o.x() + .x() * o.w() + .y() * o.z() - .z() - o.y(),
                    .w() * o.y() + .y() * o.w() + .z() * o.x() - .x() - o.z(),
                    .w() * o.z() + .z() * o.w() + .x() * o.y() - .y() - o.x(),
                    .w() * o.w() - .x() * o.x() - .y() * o.y() - .z() - o.z())
    }

    mat4 toMatrix() {
        float ww = .w() * .w()
        float wx2 = 2.0f * .w() * .x()
        float wy2 = 2.0f * .w() * .y()
        float wz2 = 2.0f * .w() * .z()
        float xx = .x() * .x()
        float xy2 = 2.0f * .x() * .y()
        float xz2 = 2.0f * .y() * .z()
        float yy = .y() * .y()
        float yz2 = 2.0f * .y() * .z()
        float zz = .z() * .z()

        mat4 ret
        ret.xx(ww + xx - yy - zz)
        ret.xy(xy2 + wz2)
        ret.xz(xz2 - wy2)
        ret.xw(0.0f)

        ret.yx(xy2 - wz2)
        ret.yy(ww - xx + yy - zz)
        ret.yz(yz2 + wx2)
        ret.yw(0.0f)

        ret.zx(xz2 + wy2)
        ret.zy(yz2 - wx2)
        ret.zz(ww - xx - yy + zz)
        ret.zw(0.0f)

        ret.wx(0.0f)
        ret.wy(0.0f)
        ret.wz(0.0f)
        ret.ww(1.0f)
        return ret
    }

    float^ ptr() {
        return .v.ptr
    }

    void print() {
        printf("%f %f %f %f\n", .x(), .y(), .z(), .w())
    }
}

// row major matrix
struct mat4 {
    float[16] v

    this() {
        .v[0] = 1
        .v[1] = 0
        .v[2] = 0
        .v[3] = 0

        .v[4] = 0
        .v[5] = 1
        .v[6] = 0
        .v[7] = 0

        .v[8] = 0
        .v[9] = 0
        .v[10] = 1
        .v[11] = 0

        .v[12] = 0
        .v[13] = 0
        .v[14] = 0
        .v[15] = 1
    }

    float xx() return .v[0]
    float xy() return .v[4]
    float xz() return .v[8]
    float xw() return .v[12]
    float yx() return .v[1]
    float yy() return .v[5]
    float yz() return .v[9]
    float yw() return .v[13]
    float zx() return .v[2]
    float zy() return .v[6]
    float zz() return .v[10]
    float zw() return .v[14]
    float wx() return .v[3]
    float wy() return .v[7]
    float wz() return .v[11]
    float ww() {return .v[15]}

    void xx(float v) .v[0] = v
    void xy(float v) .v[4] = v
    void xz(float v) .v[8] = v
    void xw(float v) .v[12] = v
    void yx(float v) .v[1] = v
    void yy(float v) .v[5] = v
    void yz(float v) .v[9] = v
    void yw(float v) .v[13] = v
    void zx(float v) .v[2] = v
    void zy(float v) .v[6] = v
    void zz(float v) .v[10] = v
    void zw(float v) .v[14] = v
    void wx(float v) .v[3] = v
    void wy(float v) .v[7] = v
    void wz(float v) .v[11] = v
    void ww(float v) .v[15] = v

    vec4 x() return vec4(.xx(), .xy(), .xz(), .xw())
    vec4 y() return vec4(.yx(), .yy(), .yz(), .yw())
    vec4 z() return vec4(.zx(), .zy(), .zz(), .zw())
    vec4 w() return vec4(.wx(), .wy(), .wz(), .ww())

    float^ ptr() return .v.ptr

    float get(int i, int j) return .v[i+j*4]
    void set(int i, int j, float val) .v[i+j*4] = val

    mat4 mul(mat4 o) {
        mat4 ret
        for(int j = 0; j < 4; j++) {
            for(int i = 0; i < 4; i++) {
                ret.v[j*4+i] = 0.0f
                for(int k = 0; k < 4; k++) {
                    ret.v[j*4+i] += .v[j*4+k] * o.v[k*4+i]
                }
            }
        }
        return ret
    }

    vec4 vmul(vec4 o) {
        vec4 ret
        for(int j = 0; j < 4; j++) {
            ret.v[j] = 0.0f
            for(int i = 0; i < 4; i++) {
                ret.v[j] += .get(i, j) * o.get(i)
            }
        }
        return ret
    }

    mat4 translate(vec4 o) {
        mat4 m = mat4()
        m.set(3,0, o.get(0))
        m.set(3,1, o.get(1))
        m.set(3,2, o.get(2))
        return m.mul(^this)
    }

    mat4 rotate(float angle, vec4 r) {
        mat4 m
        r = r.normalized()
        float c
        float s
        float t
        s = sinf(angle)
        c = cosf(angle)
        t = 1.0f - c

        m.v[0] = t * r.v[0] * r.v[0] + c
        m.v[1] = t * r.v[0] * r.v[1] - s * r.v[2]
        m.v[2] = t * r.v[0] * r.v[2] + s * r.v[1]

        m.v[3] = 0.0f

        m.v[4] = t * r.v[0] * r.v[1] + s * r.v[2]
        m.v[5] = t * r.v[1] * r.v[1] + c
        m.v[6] = t * r.v[1] * r.v[2] - s * r.v[0]

        m.v[7] = 0.0f

        m.v[8]  = t * r.v[0] * r.v[2] - s * r.v[1]
        m.v[9]  = t * r.v[1] * r.v[2] + s * r.v[0]
        m.v[10] = t * r.v[2] * r.v[2] + c

        m.v[11] = 0.0f

        m.v[12] = 0.0f
        m.v[13] = 0.0f
        m.v[14] = 0.0f

        m.v[15] = 1.0f

        return m.mul(^this)
    }

    mat4 scale(float x, float y, float z) {
        mat4 m = mat4()
        m.v[0] = x
        m.v[5] = y
        m.v[10] = z
        return m.mul(^this)
    }

    void print() {
        for(int i = 0; i < 16; i++) {
            printf("%f ", .v[i])
            if((i+1) % 4 == 0) printf("\n")
        }
    }
}

mat4 getFrustumMatrix(float l, float r, float b, float t, float n, float f) {
    mat4 m
    m.v[0] = 2.0f * n / (r - l)
    m.v[1] = 0.0f
    m.v[2] = (r + l) / (r - l)
    m.v[3] = 0.0f

    m.v[4] = 0.0f
    m.v[5] = (2.0f * n) / (t - b)
    m.v[6] = (t + b) / (t - b)
    m.v[7] = 0.0f

    m.v[8]  = 0.0f
    m.v[9]  = 0.0f
    m.v[10] = -(f + n) / (f - n)
    m.v[11] = -(2.0f * f * n) / (f - n)

    m.v[12] = 0.0f
    m.v[13] = 0.0f
    m.v[14] = -1.0f
    m.v[15] = 0.0f

    return m
}
